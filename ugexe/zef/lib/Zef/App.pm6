unit class Zef::App;

use Zef::Distribution::Local;
use Zef::Manifest;

use Zef::Roles::Installing;
use Zef::Roles::Precompiling;
use Zef::Roles::Processing;
use Zef::Roles::Testing;
use Zef::Roles::Hooking;

use Zef::Authority::P6C;
use Zef::CLI::StatusBar;
use Zef::CLI::STDMux;
use Zef::Utils::PathTools;
use Zef::Utils::SystemInfo;


#| Test modules in the specified directories
multi MAIN('test', *@repos, :$lib, Int :$jobs, Bool :$v, 
    Bool :$boring, Bool :$shuffle, Bool :$force, Bool :$no-wrap) is export(:test, :install) {
    

    @repos .= push($*CWD) unless @repos;
    @repos  = @repos.map: { $_.IO.is-absolute ?? $_ !! $_.IO.abspath }

    my $dists = gather for @repos -> $path {
        state @perl6lib; # store paths to be used in PERL6LIB in subsequent `depends` processes
        my $dist = Zef::Distribution::Local.new(
            path     => $path.IO, 
            includes => $lib.cache.unique,
            perl6lib => @perl6lib.unique,
        );
        $dist does Zef::Roles::Processing[:$jobs, :$force] unless $dist.does(Zef::Roles::Processing);
        $dist does Zef::Roles::Hooking unless $dist.does(Zef::Roles::Hooking);
        $dist does Zef::Roles::Testing;

        $dist.queue-processes: $($dist.hook-cmds(TEST, :before));
        $dist.queue-processes($($dist.test-cmds.cache));
        $dist.queue-processes: $($dist.hook-cmds(TEST, :after));

        @perl6lib.push: $dist.precomp-path.absolute;

        take $dist;
    };


    my $tested-dists = CLI-WAITING-BAR {
        my @finished;
        for $dists.cache -> $dist-todo {
            my $max-width = $MAX-TERM-COLS if ?$no-wrap;
            procs2stdout(:$max-width, $dist-todo.processes) if $v;
            my $promise = $dist-todo.start-processes;
            $promise.result; # osx bug RT125758
            await $promise;
            @finished.push: $dist-todo;
        }
        @finished;
    }, "Testing", :$boring;


    my @r;
    for $tested-dists.cache -> $test-dist {
        my @results;
        for $test-dist.processes -> $group {
            for $group.cache -> $proc {
                for $proc.cache -> $item {
                    my $sub-result = { :ok($item.ok), :id($item.id.IO.basename) };
                    @results.push($sub-result);

                    if !$force && !$sub-result<ok> {
                        print "!!!> Test failure. Aborting.\n";
                        exit 254;
                    }
                }
            }
        }
        my $result = { :ok(all(@results>><ok>)), :unit-id($test-dist.name) :results(@results) }
        @r.push($result);
    }
    verbose('Testing', @r);


    return $tested-dists;
}


multi MAIN('smoke', :$ignore, Bool :$no-wrap, :$projects-file is copy, Bool :$dry,
    Bool :$report, Bool :$v, Bool :$boring, Bool :$shuffle, Int :$jobs) is export(:smoke) {
    say "===> Smoke testing started: [{time}]";

    temp $projects-file = packages(:$ignore, :packages-file($projects-file));
    my @packages = from-json($projects-file.IO.slurp).cache;

    say "===> Filtered module count: {@packages.elems}";

    # todo: save to a custom CURLI so the install command can automatically ignore modules
    # that have already been tested to satisfy earlier dependencies.
    for @packages -> $result {
        # todo: fix first argument so it invokes the bin wrapper directly if it can find it,
        # else try to invoke $*PROGRAM?
        my @args = 'zef', '--boring', "--projects-file={$projects-file}";
        @args.push('-v')           if $v;
        @args.push('--report')     if $report;
        @args.push('--dry')        if $dry;
        @args.push('--shuffle')    if $shuffle;
        @args.push('--no-wrap')    if $no-wrap;
        @args.push("--jobs=$jobs") if $jobs;
        @args.push("--ignore=$_")  for $ignore.grep(*.so).cache;

        say "===> Smoking next: {$result.<name>}";
        my $proc = run(@args.grep(*.so).cache, 'install', $result.<name>, :out);

        say $_ for $proc.out.lines;
    }

    say "===> Smoke testing ended [{time}]";
}


multi MAIN('uninstall', *@names, :$auth, :$ver, :$from = %*CUSTOM_LIB<site>, Bool :$v) {
    my $ok;
    my $nok;

    for $from.cache -> $cur {
        with CompUnitRepo::Local::Installation.new($cur) -> $curli {
            my $mani = Zef::Manifest.new(:cur($curli), :create);
            for @names.cache -> $name {
                for $curli.candidates($name, :$auth, :$ver) -> $candi {
                    my $dist = Distribution.new(:name($candi<name>), :auth($candi<auth>), :ver($candi<ver>));

                    if $mani.uninstall($dist) -> @deleted {
                        say "===> [{$dist.name}] Deleted files: " ~ @deleted>>.IO>>.basename.join(',') if $v;
                        say "===> Uninstalled {$dist.name} successfully";
                        $ok++;
                    }
                    else {
                        say "!!!> Uninstall for {$dist.name} failed";
                        $nok++;
                    }
                }
            }
        }
    }

    say "!!!> Nothing to do." unless $ok || $nok;
    exit $nok.so ?? $nok !! 0;
}

#| Install with business logic
multi MAIN('install', *@modules, :$lib, :$ignore, :$save-to = $*TMPDIR, :$projects-file is copy, 
    Bool :$no-test, Bool :$force, Int :$jobs, Bool :$report, Bool :$v, Bool :$dry,
    Bool :$skip-depends, Bool :$skip-build-depends, Bool :$skip-test-depends,
    Bool :$shuffle, Bool :$no-wrap, Bool :$boring) is export(:install) {

    # todo:
    # Change workflow so we can check the packages file and remove already installed modules 
    # if needed, so that we don't attempt a possibly pointless `git pull`.
    # Cannot just use :ignore, as this removes modules that depend on anything ignored.
    # Add :skip to act like ignore, but not follow depends?

    # FETCHING
    my $fetched = &MAIN('get', @modules, :ignore($ignore.cache),
        :$save-to, :$projects-file,
        :$boring, :$jobs,
        :$skip-depends, :$skip-build-depends
        :skip-test-depends(($no-test || $skip-test-depends) ?? True !! False),
    );



    # VALIDATION
    # Ignore anything we downloaded that doesn't have a META.info in its root directory
    my @m = $fetched.cache.grep(*.<ok>.so);
    verbose('META.info availability', @m);

    # An array of `path`s to each modules repo (local directory, 1 per module) and their meta files
    my @repos = @m.grep(*.<ok>.so).map: { $_.<path>.IO.is-absolute ?? $_.<path> !! $_.<path>.IO.abspath }

    # META file check
    my @metas = eager gather for @repos -> $repo-path {
        if $repo-path.IO.child('META.info').IO.e {
            take $repo-path.IO.child('META.info');
        }
        elsif $repo-path.IO.child('META6.json').IO.e {
            take $repo-path.IO.child('META6.json');
        }
    }
    my @failed-metas = @metas.grep: {!$_.IO.child('META.info').IO.e &&  !$_.IO.child('META6.json').IO.e }\
        unless @metas.elems == @repos.elems;
    die "!!!> Aborting. Missing META info for: {@failed-metas}" if !$force && @failed-metas.elems;


    # Prevent processing modules that are already installed with the same or greater version.
    # Version '*' is always installed for now.
    # TEMPORARY - need to refactor as to not create Zef::Distribution::Local for a path multiple times
    my @dists     = @repos.map:   { Zef::Distribution::Local.new(path => $_.IO)            }
    my @wanted    = @dists.grep:  { $_.wanted || ($force && $_.name ~~ any(@modules.cache)) }
    my @installed = @dists.grep:  { $_.name !~~ any(@wanted>>.name)                        }
    @wanted       = @wanted.grep: { $_.name ~~ none(@installed)                            } if @installed.elems;

    if @wanted.elems != @dists.elems {
        print "===> The following modules are already up to date: {@installed.map(*.name).join(', ')}\n";
        if !$force {
            @repos = @repos.grep: { none(@installed.map(*.path).grep(*.ACCEPTS($_.IO)))         }
            @metas = @metas.grep: { none(@installed.map(*.path).grep(*.ACCEPTS($_.dirname.IO))) }
        }
        print "===> ...but using --force\n" if ?$force;
        print "===> Nothing to do.\n" and exit 0 unless @repos.elems && @metas.elems;
    }

    # BUIDLING
    my $built = &MAIN('build', @repos, :save-to('blib/lib'), :$lib, :$v, :$boring, :$jobs, :$no-wrap)\
        or print "???> Nothing to build.\n";

    my @failed-builds = eager gather for $built.cache -> $b {
        $b.map({ $_.processes.grep({ $_.nok }).map(-> $proc { take $proc }) });
    }
    die "!!!> Aborting. Build failures for: {@failed-builds.map(*.id)}" if !$report && !$force && @failed-builds.elems;

    # TESTING
    unless $no-test {
        # force the tests so we can report them. *then* we will bail out
        my $tested = &MAIN('test', @repos, :lib('blib/lib'), :$lib, 
            :$v, :$boring, :$jobs, :$shuffle, :force, :$no-wrap
        );
        my @failed-tests = eager gather for $tested.cache -> $t {
            $t.map({ $_.processes.grep({ $_.nok }).map(-> $proc { take $proc }) });
        }
        die "!!!> Aborting. Test failures for: {@failed-tests.map(*.id)}" if !$report && !$force && @failed-tests.elems;

        # Send a build/test report
        if ?$report {
            my $reported = CLI-WAITING-BAR {
                Zef::Authority::P6C.new.report(
                    @metas,
                    test-results  => $tested,
                    build-results => $built,
                );
            }, "Reporting", :$boring;

            verbose('Reporting', $reported.cache);
            my @ok = $reported.cache.grep(*.<report-id>.so).cache;
            print "===> Report{'s' if $reported.cache.elems > 1} can be seen shortly at:\n" if @ok;
            print "\thttp://testers.perl6.org/reports/$_.html\n" for @ok.map({ $_.<id> });
        }

        my @failed <== grep *.so <== $tested>>.failures;
        my @passed <== grep *.so <== $tested>>.passes;

        if @failed.elems {
            !$force
                ?? do { print "!!!> {@failed.elems} packages failed testing. Aborting.\n" and exit @failed.elems }
                !! do { print "!==> {@failed.elems} packages failed testing. [but using --force to continue]\n"  };
        }
        elsif !@passed.elems {
            print "???> No tests.\n";
        }
    }


    my $install = do {
        my $results = CLI-WAITING-BAR {
            my @finished;
            for $built.cache -> $dist {
                # todo: check against $tested to make sure tests were passed
                # currently we call &MAIN for each phase, thus creating a new
                # Zef::Distribution::Local object for each phase. This means the roles
                # do not carry over. The fix should work around is.

                # todo: refactor
                # some of these roles may already be applied. in such situations 
                # we don't want to duplicate the functionality.
                $dist does Zef::Roles::Processing[:$jobs, :$force] unless $dist.does(Zef::Roles::Processing);
                $dist does Zef::Roles::Hooking unless $dist.does(Zef::Roles::Hooking);
                $dist does Zef::Roles::Installing;

                my $max-width = $MAX-TERM-COLS if ?$no-wrap;

                my $before-procs = $dist.queue-processes: $($dist.hook-cmds(INSTALL, :before));
                procs2stdout(:$max-width, $before-procs) if $v;

                my $promise1 = $dist.start-processes;
                $promise1.result; # osx bug RT125758
                await $promise1;

                @finished.push: $dist.install(:$force);
                
                my $after-procs  = $dist.queue-processes: $($dist.hook-cmds(INSTALL, :after));
                procs2stdout(:$max-width, $after-procs) if $v;
                my $promise2 = $dist.start-processes;
                $promise2.result; # osx bug RT125758
                await $promise2;
            }
            @finished;
        }, "Installing", :$boring;

        my @tried   = $results.grep({ !$_.<skipped> }).flat;
        my @skipped = $results.grep({ ?$_.<skipped> }).flat;

        verbose('Install', @tried)                     if @tried.elems;
        verbose('Skip (already installed!)', @skipped) if @skipped.elems;
        $results;
    } unless ?$dry;

    exit ?$dry ?? 0 !! $install.cache.grep({ !$_<ok> }).elems;
}


#| Install local freshness
multi MAIN('local-install', *@modules) is export {
    say "NYI";
}


#! Download a single module and change into its directory
multi MAIN('look', $module, Bool :$v, :$save-to = $*CWD.IO.child(time)) is export(:look) { 
    my $auth = Zef::Authority::P6C.new;
    my @g = $auth.get: $module, :$save-to;
    verbose('Fetching', @g);


    if @g.[0].<ok>.so {
        say "===> Shell-ing into directory: {@g.[0].<path>}";
        chdir @g.[0].<path>;
        shell(%*ENV<SHELL> // %*ENV<ComSpec>);
        exit 0 if $*CWD.IO.path eq @g.[0].<path>;
    }


    # Failed to get the module or change directories
    say "!!!> Failed to fetch module or change into the target directory...";
    exit 1;
}


#| Get the freshness
multi MAIN('get', *@modules, :$ignore, :$save-to = $*TMPDIR, :$projects-file is copy, 
    Int :$jobs, Bool :$v, Bool :$boring, Bool :$skip-depends, 
    Bool :$skip-test-depends, Bool :$skip-build-depends) is export(:get :install) {


    # Download the requested modules from some authority
    # todo: allow turning dependency auth-download off
    my $fetched = CLI-WAITING-BAR {
        temp $projects-file = packages(:$ignore, :packages-file($projects-file));
        Zef::Authority::P6C.new(:$projects-file).get(
            @modules, :ignore($ignore.cache), :$save-to, :depends(!$skip-depends),
            :test-depends(!$skip-test-depends), :build-depends(!$skip-test-depends),
        );
    }, "Fetching", :$boring;

    verbose('Fetching', $fetched);

    unless $fetched.cache {
        say "!!!> No matching candidates found.";
        exit 1;
    }

    return $fetched;
}


#| Build modules in the specified directory
multi MAIN('build', *@repos, :$lib, :$ignore, :$save-to = 'blib/lib', Bool :$v, Bool :$no-wrap,
    Int :$jobs, Bool :$boring, Bool :$force = True) is export(:build :install) {
    @repos .= push($*CWD) unless @repos;
    @repos  = @repos.map({ $_.IO.is-absolute ?? $_ !! $_.IO.abspath }).cache;


    my $dists = gather for @repos -> $path {
        state @perl6lib; # store paths to be used in -I in subsequent `depends` processes
        my $dist = Zef::Distribution::Local.new(
            path         => $path.IO, 
            precomp-path => (?$save-to.IO.is-relative
                ?? $save-to.IO.absolute($path).IO
                !! $save-to.IO.abspath.IO
            ),
            includes     => $lib.cache.unique,
            perl6lib     => @perl6lib.unique,
        );
        $dist does Zef::Roles::Processing[:$jobs, :$force];
        $dist does Zef::Roles::Precompiling;
        $dist does Zef::Roles::Hooking;

        $dist.queue-processes: $($dist.hook-cmds(BUILD, :before));
        $dist.queue-processes($($_)) for $dist.precomp-cmds.cache;
        $dist.queue-processes: $($dist.hook-cmds(BUILD, :after));

        @perl6lib.push: $dist.precomp-path.absolute;

        take $dist;
    };

    my $precompiled-dists = CLI-WAITING-BAR {
        my @finished;
        for $dists.cache -> $dist-todo {
            my $max-width = $MAX-TERM-COLS if ?$no-wrap;
            procs2stdout(:$max-width, $dist-todo.processes) if $v;
            my $promise = $dist-todo.start-processes;
            $promise.result; # osx bug RT125758
            await $promise;
            @finished.push: $dist-todo;
        }
        @finished;
    }, "Precompiling", :$boring;

    my @r;
    for $precompiled-dists.cache -> $precomp-dist {
        my @results;
        for $precomp-dist.processes -> $group {
            for $group.cache -> $proc {
                for $proc.cache -> $item {
                    my $sub-result = { :ok($item.ok), :id($item.id.IO.basename) };
                    @results.push($sub-result);

                    if !$force && !$sub-result<ok> {
                        print "!!!> Precompilation failure. Aborting.\n";
                        exit 254;
                    }
                }
            }
        }
        my $result = { :ok(all(@results>><ok>)), :unit-id($precomp-dist.name) :results(@results) }
        @r.push($result);
    }
    verbose('Precompiling', @r);

    return $precompiled-dists;
}

# todo: non-exact matches on non-version fields
# todo: restrict fields to those found in a todo: Zef::META type module
multi MAIN('search', :$projects-file is copy, :$ignore, Bool :$v, *@names, *%fields) is export(:search) {
    # Filter the projects.json file
    my $results = CLI-WAITING-BAR { 
        temp $projects-file = packages(:force, :$ignore, :packages-file($projects-file));
        Zef::Authority::P6C.new(:$projects-file).search(|@names, |%fields).cache;
    }, "Querying for: name = {@names.join('|')}{~%fields}";

    say "===> Found " ~ $results.cache.elems ~ " results";
    my @rows = eager gather for $results.cache {
        once { take [<ID Package Version Description>] }
        take ["{state $id += 1}", $_.<name>,  ($_.<ver> // $_.<version> // '*'), ($_.<description> // '')]
    }

    my @widths     = _get_column_widths(@rows);
    my @fixed-rows = @rows.map({ _row2str(@widths, @$_, max-width => $MAX-TERM-COLS) });
    my $width      = [+] _get_column_widths(@fixed-rows);
    my $sep        = '-' x $width;

    if @fixed-rows.end {
        say "{$sep}\n{@fixed-rows[0]}\n{$sep}";
        .say for @fixed-rows[1..*];
        say $sep;
    }

    exit ?@rows ?? 0 !! 1;
}



# todo: use the auto-sizing table formatting
multi MAIN('info', *@modules, :$projects-file is copy, :$ignore, Bool :$v, Bool :$boring) is export(:info) {
    my @packages;
    my $results = CLI-WAITING-BAR { 
        temp $projects-file = packages(:force, :$ignore, :packages-file($projects-file));
        my $auth = Zef::Authority::P6C.new(:$projects-file);
        @packages = $auth.projects.cache;
        $auth.search(|@modules).cache;
    }, "Querying for: name = {@modules.join('|')}";


    say "===> Found " ~ $results.cache.elems ~ " results";

    for $results.cache -> $meta {
        print "[{$meta.<name>}]\n";

        print "# Version: {$meta.<version> // $meta.<vers> // '*'}\n";

        print "# Auth:\t {$meta.<auth>}\n" if $meta.<auth>;
        print "# Authority:\t {$meta.<auth>}\n" if $meta.<auth>;
        print "# Author:\t {$meta.<author>}\n" if $meta.<author>;
        print "# Authors:\t {$meta.<authors>.cache.join(', ')}\n" if $meta.<authors>.cache.elems;

        print "# Description:\t {$meta.<description>}\n" if $meta.<description>;

        print "# Source-url:\t {$meta.<source-url>}\n" if $meta.<source-url>;
        print "# Source:\t {$meta.<source>}\n" if $meta.<source>;

        if $meta.<provides> {
            print "# Provides: {$meta.<provides>.cache.elems} items\n";
            if $v { print "#\t$_\n" for $meta.<provides>.keys }
        }

        if $meta.<support> {
            print "# Support:\n";
            for $meta.<support>.kv -> $k, $v {
                print "#   $k:\t$v\n";
            }
        }

        if $meta.<depends> {
            print "# Depends: {$meta.<depends>.cache.elems} items\n";
            for $meta.<depends>.kv -> $k, $v { 
                print "#   $k)\t$v\n";
            }
        }

        if $meta.<depends> && $v {
            my $deps = Zef::Utils::Depends.new(projects => @packages.cache)\
                .topological-sort($meta);

            for $deps.cache.kv -> $i1, $level {
                FIRST { print "# Depends-chain:\n" }
                for $level.cache.kv -> $i2, $dep {
                    print "#   $i1\.$i2) $dep\n";
                }
            }
        }
    }
}

# this should go into Zef::Authority
sub packages(Bool :$force, :$ignore, :$boring, :$packages-file) {
    use Zef::Utils::JSON;
    my $file = $packages-file // $*TMPDIR.child("p6c-packages.{~time}.{(1..10000).pick(1)}.json");
    state $p6c = Zef::Authority::P6C.new(:projects-files($file));
    once { $p6c.update-projects unless $p6c.projects.elems }

    my @packages = $p6c.projects.cache;
    print "===> Module count: {@packages.elems}\n";
    if $ignore.cache.elems {
        @packages = @packages\
            .grep({ $_.<name>:exists })\
            .grep({ $_.<name> ~~ none($ignore.grep(*.so)) })\
            .grep({ any($_.<depends>.grep(*.so))       ~~ none($ignore.grep(*.so)) })\
            .grep({ any($_.<test-depends>.grep(*.so))  ~~ none($ignore.grep(*.so)) })\
            .grep({ any($_.<build-depends>.grep(*.so)) ~~ none($ignore.grep(*.so)) })\
            .pick(*);
    }

    print "===> Filtered module count: {@packages.elems}\n";
    my $json = to-json(@packages);
    $file.IO.spurt($json);
    print "===> Package file: $file\n";
    return ~$file;
}

# will be replaced soon
sub verbose($phase, $work) {
    my %r = $work.cache.grep(*.so).classify({ ?$_.hash.<ok> ?? 'ok' !! 'nok' }).hash;
    if %r<ok>  -> @ok  { print "===> $phase OK for: {@ok>><unit-id>.join(', ')}\n" }
    if %r<nok> -> @nok {
        for @nok -> $failed {
            FIRST { print "!!!> $phase FAILED: {@nok>><unit-id>}\n" }
            my $to-print = "!> {$failed<unit-id>}";
            with $failed<results> -> $f { $to-print ~= ": {$f.grep(!*<ok>)>><id>.join(', ')}" }
            $to-print ~= "\n";
            print $to-print;
        }
    }
    return { :ok(%r<ok>.elems), :nok(%r<nok>.elems) }
}


# returns formatted row
sub _row2str (@widths, @cells, Int :$max-width) {
    my $format = @widths.map({"%-{$_}s"}).join('|');
    return _widther(sprintf( $format, @cells.map({ $_ // '' }) ), :$max-width);
}


# Iterate over ([1,2,3],[2,3,4,5],[33,4,3,2]) to find the longest string in each column
sub _get_column_widths ( *@rows ) is export {
    return @rows[0].keys.map: { @rows>>[$_]>>.chars.max }
}
