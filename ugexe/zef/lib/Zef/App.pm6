use Zef::Config;
use Zef::Distribution;
use Zef::Distribution::Local;
use Zef::Fetch;
use Zef::ContentStorage;
use Zef::Extract;
use Zef::Test;

our %CONFIG = ZEF-CONFIG();

class Zef::App {
    has $.cache;
    has $.indexer;
    has $.fetcher;
    has $.storage;
    has $.extractor;
    has $.tester;

    has @!ignore = <Test NativeCall lib MONKEY-TYPING nqp>;
    has $!lock = Lock.new;

    has Bool $.verbose       = False;
    has Bool $.force         = False;
    has Bool $.depends       = True;
    has Bool $.build-depends = True;
    has Bool $.test-depends  = True;

    proto method new(|) {*}

    multi method new(:$extractor where !*.defined, :@extractors = |%CONFIG<Extract>, |c) {
        samewith( :extractor(Zef::Extract.new( :backends(|@extractors) )), |c );
    }

    multi method new(:$tester where !*.defined, :@testers = |%CONFIG<Test>, |c) {
        samewith( :tester(Zef::Test.new( :backends(|@testers) )), |c );
    }

    multi method new(:$cache where !*.defined, |c) {
        samewith( :cache("{%CONFIG<Store>}/store"), |c)
    }

    multi method new(:$fetcher where !*.defined, :@fetchers = |%CONFIG<Fetch>, |c) {
        samewith( :fetcher(Zef::Fetch.new( :backends(|@fetchers) )), |c );
    }

    multi method new(:$storage where !*.defined, :@storages = |%CONFIG<ContentStorage>, |c) {
        samewith( :storage(Zef::ContentStorage.new( :backends(|@storages) )), |c );
    }

    multi method new(:$cache!, :$fetcher!, :$storage!, :$extractor!, :$tester!, *%_) {
        mkdir $cache unless $cache.IO.e;

        $storage.cache   //= $cache;
        $storage.fetcher //= $fetcher;

        self.bless(:$cache, :$fetcher, :$storage, :$extractor, :$tester, |%_);
    }

    method candidates(Bool :$upgrade, *@identities) {
        my &stdout = ?$!verbose ?? -> $o {$o.say} !! -> $ { };
        # Once metacpan can return results again this will need to be modified so as not to
        # duplicate an identity that shows up from multiple ContentStorages.
        #
        # XXX: :$update means to *not* take the first matching candidate encountered, but
        # the highest version that matches from all available storages (break out of ::LocalCache)

        # This entire structure sucks as much as the previous recursive one. really want something like
        # a single assignment (like a gather loop) where the body of the block can access whats already been taken
        # which would make it easier to find identities that may have already been found. It also needs to not just
        # match against the name or identity, but check $dist.contains-spec so if 2 modules depend on say:
        # URI::Escape and another on URI (but both refer to URI distribution) then they get treated as a single request
        # (currently only works if they are requested on different iterations of the `while` loop, so requesting
        # `install URI::Escape URI` will still see them both)
        #
        # TODO: just redo this thing such that .candidates returns empty matches for identities it did not find
        # so we don't have to iterate @candidates>>.dist.contains-spec every iteration of while(@wants)
        my @wants = |@identities; # @wants contains the current iteration of identities
        my @needs;                # keeps trac
        my @candidates;
        while ( +@wants ) {
            my @wanted = @wants.splice(0);
            my @todo   = @wanted.grep(* ~~ none(|@!ignore)).unique;
            @needs     = (|@needs, |@todo).unique;

            say "Searching for {'dependencies ' if state $once++}{@todo.join(', ')}" if ?$!verbose;
            for $!storage.candidates(|@todo, :$upgrade) -> $candis {
                for $candis -> $candi {
                    if $candi.dist.identity ~~ none(|@candidates.map(*.dist.identity)) {
                        @candidates.push: $candi;
                        say "[{$candi.recommended-by}] found {$candi.dist.name}" if ?$!verbose;
                        # todo: alternatives, i.e. not a Str but [Str, Str]
                        # todo: abstract the depends/build-depends/test-depends shit
                        @wants.append(|unique(grep *.chars, grep *.defined,
                            ($candi.dist.depends       if ?$!depends).Slip,
                            ($candi.dist.test-depends  if ?$!test-depends).Slip,
                            ($candi.dist.build-depends if ?$!build-depends).Slip));
                    }
                }
            }
        }

        if +@needs !== +@candidates {
            my @missing = @needs.grep(* !~~ any(@candidates>>.requested-as));
            +@missing >= +@needs
                ?? say("Could not find distributions for the following requests:\n{@missing.sort.join(', ')}")
                !! say(   "Found too many results :(\n\nFOUND:\n{@candidates.map(*.dist.identity).sort.join(', ')}\n"
                        ~ "WANTED: {@needs.sort.join(', ')}");
            die unless ?$!force;
        }

        $ = @candidates;
    }


    method fetch(*@candidates) {
        my &stdout = ?$!verbose ?? -> $o {$o.say} !! -> $ { };
        my @saved = eager gather for @candidates -> $candi {
            my $dist         = $candi.dist;
            my $from         = $candi.recommended-by;
            my $requested-as = $candi.requested-as;
            my $uri          = $candi.uri;

            my $sanitized-name = $dist.name.subst(':', '-', :g);
            my $extract-to = $!cache.IO.child($sanitized-name);
            my $save-as    = $!cache.IO.child($uri.IO.basename);

            say "Fetching `{$requested-as}` as {$dist.identity}";

            # $candi.uri will always point to where $candi.dist should be copied from.
            # It could be a file or url; $dist.source-url contains where the source was
            # originally located but we may want to use a local copy (while retaining
            # the original source-url for some other purpose like updating)

            if ?$uri && $uri.IO.e {
                # todo: include a FileFetcher that is something like:
                # `method fetch($to, $from) { Zef::Utils::FileSystem::copy-files($to, $from) }`
                # so that any hook related behavior can be centralized in Zef::Fetch instead of
                # also being in this "to fetch or not to fetch?" conditional
                say "[$from] Found on local file system at $uri" if ?$!verbose;
            }
            else {
                say "[$from] {$uri} --> $save-as" if ?$!verbose;
                my $location = $!fetcher.fetch($uri, $save-as, :&stdout);

                # should probably break this out into its out method
                say "[{$!extractor.^name}] Extracting: {$save-as}" if ?$!verbose;
                $location = try { $!extractor.extract($location, $extract-to) } || $location;
                say "Extracted to: {$location}" if ?$!verbose;

                # Our `Zef::Distribution $dist` can be upraded to a `Zef::Distribution::Local`
                # as .fetch/.extract has copied the Distribution to a local path somewhere.
                # The "upgraded" functionality is generally related to turning relative paths
                # to the absolute paths on the current file system (in `provides`/`resources` for example)
                $candi.dist does Zef::Distribution::Local(~$location);
            }

            take $candi;
        }

        # Calls optional `.store` method on all ContentStorage plugins so they may
        # choose to cache the dist or simply cache the meta data of what is installed.
        # Should go in its own phase/lifecycle event
        $!storage.store(|@saved.map(*.dist));

        @saved;
    }


    # xxx: needs some love
    method test(:@includes, *@paths) {
        % = @paths.classify: -> $path {
            say "Start test phase for: $path";

            my &stdout = ?$!verbose ?? -> $o {$o.say} !! -> $ { };

            my $result = $!tester.test($path, :includes(@includes.grep(*.so)), :&stdout);

            if !$result {
                die "Aborting due to test failure at: {$path} (use :force to override)" unless ?$!force;
                say "Test failure at: {$path}. Continuing anyway with :force"
            }
            else {
                say "Testing passed for {$path}";
            }

            # should really return a hash of passes and failures
            ?$result
        }
    }


    # xxx: needs some love
    method search(*@identities, *%fields) {
        $!storage.search(|@identities, |%fields);
    }


    method install(:$install-to = ['site'], Bool :$fetch, Bool :$test, Bool :$dry, Bool :$upgrade, *@wants, *%_) {
        my &notice = ?$!force ?? &say !! &die;

        state @can-install-ids = $*REPO.repo-chain.unique( :as(*.id) )\
            .grep(*.?can-install)\
            .map({.id});

        my @target-curs = $install-to\
            .map({ ($_ ~~ CompUnit::Repository) ?? $_ !! CompUnit::RepositoryRegistry.repository-for-name($_) })\
            .grep(*.defined)\
            .grep({ .id ~~ any(@can-install-ids) });

        # XXX: Each loop block below essentially represents a phase, so they will probably
        # be moved into their own method/module related directly to their phase. For now
        # lumping them here allows us to easily move functionality between phases until we
        # find the perfect balance/structure.

        # Search Phase:
        # Search ContentStorages to locate each Candidate needed to fulfill the requested identities
        my @candidates = |self.candidates(|@wants, :$upgrade, |%_).unique;


        # Fetch Stage:
        # Use the results from searching ContentStorages and download/fetch the distributions they point at
        my @dists = eager gather for @candidates -> $store {
            take $_.dist for |self.fetch($store, |%_);
        }


        # Filter Stage:
        # Handle stuff like removing distributions that are already installed, that don't have
        # an allowable license, etc. It faces the same "fetch an alternative if available on failure"
        # problem outlined below under `Sort Phase` (a depends on [A, B] where A gets filtered out
        # below because it has the wrong license means we don't need anything that depends on A but
        # *do* need to replace those items with things depended on by B [which replaces A])
        my @filtered-dists = eager gather DIST: for @dists -> $dist {
            say "[DEBUG] Filtering {$dist.name}" if ?$!verbose;
            if ?$dist.is-installed {
                my $reported-id = ?$!verbose ?? $dist.identity !! $dist.name;
                unless ?$!force {
                    say "{$reported-id} is already installed. Skipping... (use :force to override)";
                    next;
                }

                say "{$reported-id} is already installed. Continuing anyway with :force";
            }

            # todo: Change config.json to `"Filter" : { "License" : "xxx" }`)
            given %CONFIG<License> {
                CATCH { default {
                    say $_.message;
                    die    "Allowed licenses: {%CONFIG<License>.<whitelist>.join(',')    || 'n/a'}\n"
                        ~  "Disallowed licenses: {%CONFIG<License>.<blacklist>.join(',') || 'n/a'}";
                } }
                when .<blacklist>.?chars && any(|.<blacklist>) ~~ any('*', $dist.license // '') {
                    notice "License blacklist configuration exists and matches {$dist.license // 'n/a'} for {$dist.name}";
                }
                when .<whitelist>.?chars && any(|.<whitelist>) ~~ none('*', $dist.license // '') {
                    notice "License whitelist configuration exists and does not match {$dist.license // 'n/a'} for {$dist.name}";
                }
            }

            take $dist;
        }


        # Sort Phase:
        # This ideally also handles creating alternate build orders when a `depends` includes
        # alternative dependencies. Then if the first build order fails it can try to fall back
        # to the next possible build order. However such functionality may not be useful this late
        # as at this point we expect to have already fetched/filtered the distributions... so either
        # we fetch all alternatives (most of which would probably would not use) or do this in a way
        # that allows us to return to a previous state in our plan (xxx: Zef::Plan is planned)
        my @sorted-dists = self.plan-order(@filtered-dists, |%_);

        # Build Phase:
        # Attach appropriate metadata so we can do --dry runs using -I/some/dep/path
        # and can install after we know they pass any required tests
        my @installable-dists = eager gather for @sorted-dists -> $dist {
            say "[DEBUG] Processing {$dist.name}" if ?$!verbose;

            my @dep-specs = unique(grep *.defined,
                ($dist.depends-specs       if ?$!depends).Slip,
                ($dist.test-depends-specs  if ?$!test-depends).Slip,
                ($dist.build-depends-specs if ?$!build-depends).Slip);

            # this could probably be done in the topological-sort itself
            $dist.metainfo<includes> = eager gather DEPSPEC: for @dep-specs -> $spec {
                for @filtered-dists -> $fd {
                    if $fd.contains-spec($spec) {
                        take $fd.IO.child('lib').absolute;
                        take $_ for |$fd.metainfo<includes>;
                        next DEPSPEC;
                    }
                }
            }

            notice "Build.pm hook failed" if $dist.IO.child('Build.pm').e && !legacy-hook($dist);

            take $dist if ?$test ?? self.test($dist.path, :includes(|$dist.metainfo<includes>)) !! True;
        }

        # Install Phase:
        # Ideally `--dry` uses a special unique CompUnit::Repository that is meant to be deleted entirely
        # and contain only the modules needed for this specific run/plan
        for @installable-dists -> $dist {
            for @target-curs -> $cur {
                if ?$dry {
                    say "{$dist.name}#{$dist.path} processed successfully";
                }
                else {
                    #$!lock.protect({
                    say "Installing {$dist.name}#{$dist.path} to {$cur.short-id}#{~$cur}";
                    $cur.install($dist, $dist.sources(:absolute), $dist.scripts, $dist.resources, :$!force);
                    #});
                }
            }
        }

        # Report phase:
        # Handle exit codes for various option permutations like --force
        # Inform user of what was tested/built/installed and what failed
        # Optionally report to any cpan testers type service (testers.perl6.org)
        unless $dry {
            if @installable-dists.flatmap(*.scripts.keys).unique -> @bins {
                say "\n{+@bins} bin/ script{+@bins>1??'s'!!''}{+@bins&&?$!verbose??' ['~@bins~']'!!''} installed to:"
                ~   "\n\t" ~ @target-curs.map(*.prefix.child('bin')).join("\n");
            }
        }
    }

    method plan-order(@dists, *%_) {
        my @tree;
        my $visit = sub ($dist, $from? = '') {
            return if ($dist.metainfo<marked> // 0) == 1;
            if ($dist.metainfo<marked> // 0) == 0 {
                $dist.metainfo<marked> = 1;

                my @deps = unique(grep *.defined,
                    ($dist.depends-specs       if ?$!depends).Slip,
                    ($dist.test-depends-specs  if ?$!test-depends).Slip,
                    ($dist.build-depends-specs if ?$!build-depends).Slip);

                for @deps -> $m {
                    for @dists.grep(*.spec-matcher($m)) -> $m2 {
                        $visit($m2, $dist);
                    }
                }
                @tree.append($dist);
            }
        };

        for @dists -> $dist {
            $visit($dist, 'olaf') if ($dist.metainfo<marked> // 0) == 0;
        }

        $ = @tree>>.metainfo<marked>:delete;
        return @tree;
    }
}


# todo: write a real hooking implementation to CU::R::I instead of the current practice
# of writing an installer specific (literally) Build.pm
sub legacy-hook($dist) {
    my $builder-path = $dist.IO.child('Build.pm');

    # if panda is declared as a dependency then there is no need to fix the code, although
    # it would still be wise for the author to change their code as outlined in $legacy-fixer-code
    unless $dist.depends.first(/'panda' | 'Panda::'/)
        || $dist.build-depends.first(/'panda' | 'Panda::'/)
        || $dist.test-depends.first(/'panda' | 'Panda::'/)
        || IS-INSTALLED('Panda::Builder') {

        my $legacy-fixer-code = q:to/END_LEGACY_FIX/;
            class Build {
                method isa($what) {
                    return True if $what.^name eq 'Panda::Builder';
                    callsame;
                }
            END_LEGACY_FIX

        my $legacy-code = $builder-path.IO.slurp;
        $legacy-code.subst-mutate(/'use Panda::' \w+ ';'/, '', :g);
        $legacy-code.subst-mutate('class Build is Panda::Builder {', "{$legacy-fixer-code}\n");
        $builder-path = "{$builder-path.absolute}.zef".IO;
        try { $builder-path.spurt($legacy-code) } || $builder-path.subst-mutate(/'.zef'$/, '');
    }

    my $cmd = "require <{$builder-path.basename}>; "
            ~ "try ::('Build').new.build('{$dist.IO.absolute}'); "
            ~ '$!.defined ?? exit(1) !! exit(0)';

    my $result;
    try {
        use Zef::Shell;
        CATCH { default { $result = False; } }
        my @includes = $dist.metainfo<includes>.map: { "-I{$_}" }
        my $proc = zrun($*EXECUTABLE, '-Ilib/.precomp', '-I.', '-Ilib', |@includes, '-e', "$cmd", :cwd($dist.path), :out, :err);
        my @out = $proc.out.lines;
        my @err = $proc.err.lines;
        $ = $proc.out.close;
        $ = $proc.err.close;
        $result = ?$proc;
    }
    $builder-path.IO.unlink if $builder-path.ends-with('.zef') && "{$builder-path}".IO.e;
    $ = $result;
}
