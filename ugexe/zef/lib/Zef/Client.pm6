use Zef::Config;
use Zef::Distribution;
use Zef::Distribution::Local;
use Zef::Fetch;
use Zef::ContentStorage;
use Zef::Extract;
use Zef::Test;

class Zef::Client {
    has $.cache;
    has $.indexer;
    has $.fetcher;
    has $.storage;
    has $.extractor;
    has $.tester;

    has $.config;

    has @.exclude;
    has @!ignore = <Test NativeCall lib MONKEY-TYPING nqp>;

    has Bool $.verbose       is rw = False;
    has Bool $.force         is rw = False;
    has Bool $.depends       is rw = True;
    has Bool $.build-depends is rw = True;
    has Bool $.test-depends  is rw = True;

    method new(
        :cache(:$zcache),
        :fetcher(:$zfetcher),
        :storage(:$zstorage),
        :extractor(:$zextractor),
        :tester(:$ztester),
        :$config,
        *%_
        ) {
        my $cache := ?$zcache ?? $zcache !! ?$config<StoreDir>
            ?? $config<StoreDir>
            !! die "Zef::Client requires a cache parameter";
        my $fetcher := ?$zfetcher ?? $zfetcher !! ?$config<Fetch>
            ?? Zef::Fetch.new(:backends(|$config<Fetch>))
            !! die "Zef::Client requires a fetcher parameter";
        my $extractor := ?$zextractor ?? $zextractor !! ?$config<Extract>
            ?? Zef::Extract.new(:backends(|$config<Extract>))
            !! die "Zef::Client requires an extractor parameter";
        my $tester := ?$ztester ?? $ztester !! ?$config<Test>
            ?? Zef::Test.new(:backends(|$config<Test>))
            !! die "Zef::Client requires a tester parameter";
        my $storage := ?$zstorage ?? $zstorage !! ?$config<ContentStorage>
            ?? Zef::ContentStorage.new(:backends(|$config<ContentStorage>))
            !! die "Zef::Client requires a storage parameter";

        mkdir $cache unless $cache.IO.e;

        $storage.cache   //= $cache;
        $storage.fetcher //= $fetcher;

        self.bless(:$cache, :$fetcher, :$storage, :$extractor, :$tester, :$config, |%_);
    }

    method candidates(Bool :$upgrade, *@identities) {
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

        # First we resolve local paths and URIs, because these refer to a specific distribution, but we won't know
        # what that distribution's identity is until we fetch it and examine the META6. By knowing the identity of
        # these distributions before the ContentStorage.candidate search loop (after this block of code) we can
        # skip fetching any dependencies by name that these paths or URIs fulfill

        # - LOCAL PATHS
        for @wants.grep({.starts-with('.' | '/')}, :p).reverse {
            @needs.push: Candidate.new(:uri(.value.IO.absolute), :as(.value));
            @wants[.key]:delete;
        }

        # - URNs
        # Note that URNs like Foo-Bar:ver('1.2.3') also matches as a URI.
        # So if something is a URN, assume its not a URI (for our purposes)
        for @wants.grep({!Zef::Identity($_)}, :p).reverse -> $kv {
            if my $uri = Zef::Utils::URI($kv.value) and !$uri.is-relative {
                @needs.push: Candidate.new(:uri($kv.value), :as($kv.value));
                @wants[$kv.key]:delete;
            }
        }

        # fetch dependencies for URIs and Paths (which will be identities)
        for self.fetch(|@needs) -> $candi {
            @candidates.push($candi);
            @wants.append(|unique(grep *.chars, grep *.defined,
                ($candi.dist.depends       if ?$!depends).Slip,
                ($candi.dist.test-depends  if ?$!test-depends).Slip,
                ($candi.dist.build-depends if ?$!build-depends).Slip));
        }

        # - IDENTITIES
        # ContentStorage.candidate search loop
        # The above chunk of code is for "finding" a distribution that we know the exact location of. This is for
        # finding identities (like you would type on the command line, `use` in your code, or put in your `depends`)
        my $exclude = any(|@!exclude);
        my $is-dependency = 0;
        while @wants.splice.grep(*.defined) -> @wanted {
            my @todo = @wanted.grep(* ~~ none(|@!ignore)).grep(-> $id {
                my $spec = Zef::Distribution::DependencySpecification.new($id);
                so !@candidates.first(*.dist.contains-spec($spec))
            }).unique;
            next unless +@todo;
            @needs = (|@needs, |@todo).grep(* !~~ $exclude).unique;

            say "Searching for {'dependencies ' if $is-dependency++}{@todo.join(', ')}";

            for $!storage.candidates(|@todo, :$upgrade) -> $candis {
                for $candis.grep({ .dist.identity ~~ none(|@candidates.map(*.dist.identity)) }) -> $candi {
                    # conditional is to handle --depsonly (installing only deps)
                    if $candi.as !~~ $exclude {
                        @candidates.push($candi);
                        say "[{$candi.from}] found {$candi.dist.name}" if ?$!verbose;
                    }

                    # todo: alternatives, i.e. not a Str but [Str, Str]
                    # todo: abstract the depends/build-depends/test-depends shit
                    @wants.append(|unique(grep *.chars, grep *.defined,
                        ($candi.dist.depends       if ?$!depends).Slip,
                        ($candi.dist.test-depends  if ?$!test-depends).Slip,
                        ($candi.dist.build-depends if ?$!build-depends).Slip));
                }
            }
        }

        # For now we use unique on the `as` field so if someone has both p6c and cpan
        # enabled that they only get 1 result for a specific requested instead of 1 from each.
        # In the future this won't be neccesary because they *should* match on identities, but
        # right now metacpan has some of the versions/auths screwy. This means a dist on both
        # may be exactly the same, but metacpan reports the auth or version slightly different
        # causing it to be treated as a unique result.
        # XXX: this check (and anything that dies really) should be moved to `.install`
        my @chosen = @candidates.unique(:as(*.as));
        if +@needs !== +@chosen {
            # if @needs has more elements than @missing its probably a bug related to:
            my @missing = @needs.grep(* !~~ any(@candidates>>.as));
            +@missing >= +@needs
                ?? say("Could not find distributions for the following requests:\n{@missing.sort.join(', ')}")
                !! say(   "Found too many results :(\n\nGot:\n{@candidates.map(*.dist.name).sort.join(', ')}\n"
                        ~ "Expected: {@needs.sort.join(', ')}");
            die "use --force to continue" unless ?$!force;
        }

        $ = @chosen;
    }


    method fetch(*@candidates) {
        my $stdout = Supplier.new;
        my &out = ?$!verbose ?? -> $o {$o.say} !! -> $ { };
        $stdout.Supply.tap(&out);

        my $stderr = Supplier.new;
        my &err = ?$!verbose ?? -> $e {$e.say} !! -> $ { };
        $stderr.Supply.tap(&err);

        my @saved = eager gather for @candidates -> $candi {
            my $from     = $candi.from;
            my $as       = $candi.as;
            my $uri      = $candi.uri;
            my $tmp      = $!config<TempDir>.IO;
            my $stage-at = $tmp.child($uri.IO.basename);
            die "failed to create directory: {$tmp.absolute}"
                unless ($tmp.IO.e || mkdir($tmp));

            # $candi.uri will always point to where $candi.dist should be copied from.
            # It could be a file or url; $dist.source-url contains where the source was
            # originally located but we may want to use a local copy (while retaining
            # the original source-url for some other purpose like updating)

            say "{?$from??qq|[$from] |!!''}{$uri} staging at: $stage-at" if ?$!verbose;

            my $save-to    = $!fetcher.fetch($uri, $stage-at, :$stdout, :$stderr);
            my $relpath    = $stage-at.relative($tmp);
            my $extract-to = $!cache.IO.child($relpath);

            say "$uri saved to $save-to" if ?$!verbose;

            # should probably break this out into its out method
            say "[{$!extractor.^name}] Extracting: {$save-to} to {$extract-to}" if ?$!verbose;
            my $dist-dir = $!extractor.extract($save-to, $extract-to);
            say "Extracted to: {$dist-dir}" if ?$!verbose;

            # $candi.dist may already contain a distribution object, but we reassign it as a
            # Zef::Distribution::Local so that it has .path/.IO methods. These could be
            # applied via a role, but this way also allows us to use the distribution's
            # meta data instead of the (possibly out-of-date) meta data content storage found
            my $dist        = Zef::Distribution::Local.new(~$dist-dir);
            my $local-candi = $candi.clone(:$dist);
            # XXX: the above used to just be `$candi.dist = $dist` where dist is rw

            say "{$local-candi.dist.identity} fulfills the request for {$local-candi.as}";

            take $local-candi;
        }

        $stdout.done;
        $stderr.done;

        # Calls optional `.store` method on all ContentStorage plugins so they may
        # choose to cache the dist or simply cache the meta data of what is installed.
        # Should go in its own phase/lifecycle event
        $!storage.store(|@saved.map(*.dist));

        @saved;
    }

    # xxx: needs some love. also an entire specification
    method build(*@candidates) {
        my @built = eager gather for @candidates -> $candi {
            my $dist := $candi.dist;
            take($candi) && next() unless $dist.IO.child('Build.pm').e;

            my $result = legacy-hook($candi);

            if !$result {
                die "Aborting due to build failure: {$candi.dist.?identity // $candi.uri}"
                ~   "(use --force to override)" unless ?$!force;
                say "build failure: {$candi.dist.?identity // $candi.uri}. "
                ~   "Continuing anyway with --force"
            }
            else {
                say "Build passed for {$candi.dist.?identity // $candi.uri}";
            }

            $candi does role :: { has $.build-results = ?$result };

            take $candi;
        }
    }

    # xxx: needs some love
    method test(:@includes, *@candidates) {
        my $stdout = Supplier.new;
        my &out = ?$!verbose ?? -> $o {$o.say} !! -> $ { };
        $stdout.Supply.tap(&out);

        my $stderr = Supplier.new;
        my &err = ?$!verbose ?? -> $e {$e.say} !! -> $ { };
        $stderr.Supply.tap(&err);

        my @tested = eager gather for @candidates -> $candi {
            say "Start test phase for: {$candi.dist.?identity // $candi.uri}";

            my @result = $!tester.test($candi.dist.path, :includes($candi.dist.metainfo<includes>), :$stdout, :$stderr);

            if @result.grep(*.not).elems {
                die "Aborting due to test failure: {$candi.dist.?identity // $candi.uri} "
                ~   "(use --force to override)" unless ?$!force;
                say "Test failure: {$candi.dist.?identity // $candi.uri}. "
                ~   "Continuing anyway with --force"
            }
            else {
                say "Testing passed for {$candi.dist.?identity // $candi.uri}";
            }

            # This method of attaching meta information will eventually be replaced
            # with a `Plan`/`Result` class, but its great for fleshing out a design now
            $candi does role :: { has $.test-results = |@result };

            take $candi;
        }

        $stdout.done;
        $stderr.done;

        @tested
    }


    # xxx: needs some love
    method search(*@identities, *%fields) {
        $!storage.search(|@identities, |%fields);
    }


    method install(
        CompUnit::Repository :@to!, # target CompUnit::Repository
        Bool :$fetch = True,        # try fetching whats missing
        Bool :$test  = True,        # run tests
        Bool :$dry,                 # do everything *but* actually install
        Bool :$upgrade,             # NYI
        *@candidates,
        *%_
        ) {
        my &notice = ?$!force ?? &say !! &die;
        my (@curs, @cant-install);
        @to.map: { my $group := $_.?can-install ?? @curs !! @cant-install; $group.push($_) }
        say "You specified the following CompUnit::Repository install targets that don't appear writeable/installable:\n"
            ~ "\t{@cant-install.join(', ')}" if +@cant-install;
        die "Need a valid installation target to continue" unless ?$dry || (+@curs - +@cant-install) > 0;

        # XXX: Each loop block below essentially represents a phase, so they will probably
        # be moved into their own method/module related directly to their phase. For now
        # lumping them here allows us to easily move functionality between phases until we
        # find the perfect balance/structure.
        die "Must specify something to install" unless +@candidates;

        # Fetch Stage:
        # Use the results from searching ContentStorages and download/fetch the distributions they point at
        my @fetched-candidates = eager gather for @candidates -> $store {
            # xxx: paths and uris we already fetched (saves us from copying 1 extra time)
            take $store and next if $store.dist.^name.contains('Zef::Distribution::Local');
            # todo: send |@candidates to fetch instead of each $store one at a time
            take $_ for |self.fetch($store, |%_);
        }
        die "Failed to fetch any candidates. No reason to proceed" unless +@fetched-candidates;


        # This could really go in the filter stage (thats where it got moved from!) but
        # this lets us give a better error message if all candidates are installed. We can
        # also put logic related to checking if its installed in *specific* CURs
        my @needed-candidates = eager gather for @fetched-candidates -> $candi {
            my $dist := $candi.dist;
            say "===> Probing for {$dist.name}" if ?$!verbose;
            if ?self.is-installed($candi.dist, at => @to) {
                unless ?$!force {
                    say "{$!verbose??'['~$candi.as~'] '!!''}{$dist.identity} "
                    ~   "is already installed. Skipping... (use :force to override)";
                    next;
                }
                say "{$!verbose??'['~$candi.as~'] '!!''}{$dist.identity} is already installed. "
                ~   "Continuing anyway with :force";
            }
            take $candi;
        }
        die "All candidates appear to be installed already. Aborting!" unless $!force || +@needed-candidates;


        # Filter Stage:
        # Handle stuff like removing distributions that are already installed, that don't have
        # an allowable license, etc. It faces the same "fetch an alternative if available on failure"
        # problem outlined below under `Sort Phase` (a depends on [A, B] where A gets filtered out
        # below because it has the wrong license means we don't need anything that depends on A but
        # *do* need to replace those items with things depended on by B [which replaces A])
        my @filtered-candidates = eager gather for @needed-candidates -> $candi {
            my $dist := $candi.dist;
            say "===> Filtering {$dist.name}" if ?$!verbose;
            # todo: Change config.json to `"Filter" : { "License" : "xxx" }`)
            given $!config<License> {
                CATCH { default {
                    say $_.message;
                    die "Allowed licenses: {$!config<License>.<whitelist>.join(',')    || 'n/a'}\n"
                    ~   "Disallowed licenses: {$!config<License>.<blacklist>.join(',') || 'n/a'}";
                } }
                when .<blacklist>.?chars && any(|.<blacklist>) ~~ any('*', $dist.license // '') {
                    notice "License blacklist configuration exists and matches {$dist.license // 'n/a'} for {$dist.name}";
                }
                when .<whitelist>.?chars && any(|.<whitelist>) ~~ none('*', $dist.license // '') {
                    notice "License whitelist configuration exists and does not match {$dist.license // 'n/a'} for {$dist.name}";
                }
            }

            take $candi;
        }
        die "All candidates have been filtered out. No reason to proceed" unless +@filtered-candidates;


        # Sort Phase:
        # This ideally also handles creating alternate build orders when a `depends` includes
        # alternative dependencies. Then if the first build order fails it can try to fall back
        # to the next possible build order. However such functionality may not be useful this late
        # as at this point we expect to have already fetched/filtered the distributions... so either
        # we fetch all alternatives (most of which would probably would not use) or do this in a way
        # that allows us to return to a previous state in our plan (xxx: Zef::Plan is planned)
        my @sorted-candidates = self.sort-candidates(@filtered-candidates, |%_);
        die "Something went terribly wrong determining the build order" unless +@sorted-candidates;


        # Setup(?) Phase:
        # Attach appropriate metadata so we can do --dry runs using -I/some/dep/path
        # and can install after we know they pass any required tests
        my @linked-candidates = self.link-candidates(|@sorted-candidates);
        die "Something went terribly wrong linking the distributions" unless +@linked-candidates;


        # Build Phase:
        my @built-candidates = self.build(|@linked-candidates);
        die "No installable candidates remain after `build` failures" unless +@built-candidates;


        # Test Phase:
        my @tested-candidates = gather for @built-candidates -> $candi {
            next() R, take($candi) unless ?$test;

            my $tested = self.test($candi);
            my $failed = $tested.map(*.test-results.grep(!*.so).elems).sum;

            take $candi unless ?$failed && !$!force;
        }
        # actually we *do* want to proceed here later so that the Report phase can know about the failed tests/build
        die "All candidates failed building and/or testing. No reason to proceed" unless +@tested-candidates;

        # Install Phase:
        # Ideally `--dry` uses a special unique CompUnit::Repository that is meant to be deleted entirely
        # and contain only the modules needed for this specific run/plan
        my @installed-candidates = gather for @tested-candidates -> $candi {
            take $candi if @curs.grep: -> $cur {
                my $dist = $candi.dist;
                # CURI.install is bugged; $dist.provides/files will both get modified and fuck up
                # any subsequent .install as the fuck up involves changing the data structures
                temp $dist.provides = $dist.provides;
                temp $dist.files    = $dist.files;

                if ?$dry {
                    say "{$dist.identity}{$!verbose??q|#|~$dist.path!!''} processed successfully";
                }
                else {
                    #$!lock.protect({
                    say "Installing {$dist.identity}{?$!verbose??qq| to $cur|!!''}";
                    try $cur.install($dist, $dist.sources(:absolute), $dist.scripts, $dist.resources, :$!force);
                    #});
                }
            }
        }

        # Report phase:
        # Handle exit codes for various option permutations like --force
        # Inform user of what was tested/built/installed and what failed
        # Optionally report to any cpan testers type service (testers.perl6.org)
        unless $dry {
            if @installed-candidates.map(*.dist).flatmap(*.scripts.keys).unique -> @bins {
                say "\n{+@bins} bin/ script{+@bins>1??'s'!!''}{+@bins&&?$!verbose??' ['~@bins~']'!!''} installed to:"
                ~   "\n\t" ~ @curs.map(*.prefix.child('bin')).join("\n");
            }
        }

        @installed-candidates;
    }

    method uninstall(CompUnit::Repository :@from!, *@identities) {
        my @specs = @identities.map: { Zef::Distribution::DependencySpecification.new($_) }
        eager gather for self.list-installed(|@from) -> $candi {
            my $dist = $candi.dist;
            if @specs.first({ $dist.spec-matcher($_) }) {
                my $cur = CompUnit::RepositoryRegistry.repository-for-spec("inst#{$candi.from}", :next-repo($*REPO));
                $cur.uninstall($dist);
                take $candi;
            }
        }
    }

    method list-rev-depends($identity, Bool :$indirect) {
        my $spec  = Zef::Distribution::DependencySpecification.new($identity);
        my $dist  = self.list-available.first(*.dist.contains-spec($spec)).?dist || return [];

        my $rev-deps := gather for self.list-available -> $candidate {
            my $specs = $candidate.dist.depends-specs,
                        $candidate.dist.build-depends-specs,
                        $candidate.dist.test-depends-specs;
            take $candidate if $specs.first({ $dist.contains-spec($_) });
        }
    }

    method list-available(*@storage-names) {
        my $available := $!storage.available(|@storage-names);
    }

    # XXX: an idea is to make CURI install locations a ContentStorage as well. then this method
    # would be grouped into the above `list-available` method
    method list-installed(*@curis) {
        my @curs       = +@curis ?? @curis !! $*REPO.repo-chain.grep(*.?prefix.?e);
        my @repo-dirs  = @curs>>.prefix;
        my @dist-dirs  = |@repo-dirs.map(*.child('dist')).grep(*.e);
        my @dist-files = |@dist-dirs.map(*.IO.dir.grep(*.IO.f).Slip);

        my $dists := gather for @dist-files -> $file {
            if try { Zef::Distribution.new( |%(from-json($file.IO.slurp)) ) } -> $dist {
                my $cur = @curs.first: {.prefix eq $file.parent.parent}
                take Candidate.new( :$dist, :from($cur), :uri($file) );
            }
        }
    }

    method list-leaves {
        my @installed = self.list-installed;
        my @dep-specs = gather for @installed {
            take $_ for .dist.depends-specs;
            take $_ for .dist.build-depends-specs;
            take $_ for .dist.test-depends-specs;
        }

        my $leaves := gather for @installed -> $candi {
            my $dist := $candi.dist;
            take $candi unless @dep-specs.first: { $dist.contains-spec($_) }
        }
    }

    method is-installed($dist, :@at) {
        $ = ?self.list-installed(|@at).first(*.dist.contains-spec($dist))
    }

    method sort-candidates(@candis, *%_) {
        my @tree;
        my $visit = sub ($candi, $from? = '') {
            return if ($candi.dist.metainfo<marked> // 0) == 1;
            if ($candi.dist.metainfo<marked> // 0) == 0 {
                $candi.dist.metainfo<marked> = 1;

                my @deps = unique(grep *.defined,
                    ($candi.dist.depends-specs       if ?$!depends).Slip,
                    ($candi.dist.test-depends-specs  if ?$!test-depends).Slip,
                    ($candi.dist.build-depends-specs if ?$!build-depends).Slip);

                for @deps -> $m {
                    for @candis.grep(*.dist.spec-matcher($m)) -> $m2 {
                        $visit($m2, $candi);
                    }
                }
                @tree.append($candi);
            }
        };

        for @candis -> $candi {
            $visit($candi, 'olaf') if ($candi.dist.metainfo<marked> // 0) == 0;
        }

        $ = @tree.map(*.dist)>>.metainfo<marked>:delete;
        return @tree;
    }

    # Adds appropriate include (-I / PERL6LIB) paths for dependencies
    # This should probably be handled by the Candidate class... one day...
    proto method link-candidates(|) {*}
    multi method link-candidates(Bool :$recursive! where *.so, *@candidates) {
        # :recursive
        # Given Foo::XXX that depends on Bar::YYY that depends on Baz::ZZZ
        #   - Foo::XXX -> -I/Foo/XXX/lib -I/Bar/YYY/lib -I/Baz/ZZZ/lib
        #   - Bar::YYY -> -I/Bar/YYY/lib -I/Baz/ZZZ/lib
        #   - Baz::ZZZ -> -I/Baz/ZZZ/lib

        # XXX: Need to change this so it only add indirect dependencies
        # instead of just recursing the array in order. Otherwise there
        # can be distributions that are part of a different dependency
        # chain will end up with some extra includes

        my @linked = self.link-candidates(|@candidates);
        @ = @linked.map: -> $candi { # can probably use rotor instead of doing the `@a[$index + 1..*]` dance
            my @direct-includes    = |$candi.dist.metainfo<includes>.grep(*.so);
            my @recursive-includes = try |@linked[(state $i += 1)..*]\
                .map(*.dist.metainfo<includes>).flatmap(*.flat);
            my @unique-includes    = |unique(|@direct-includes, |@recursive-includes);
            $candi.dist.metainfo<includes> = |@unique-includes.grep(*.so);
            $candi;
        }
    }
    multi method link-candidates(Bool :$inclusive! where *.so, *@candidates) {
        # :inclusive
        # Given Foo::XXX that depends on Bar::YYY that depends on Baz::ZZZ
        #   - Foo::XXX -> -I/Foo/XXX/lib -I/Bar/YYY/lib -I/Baz/ZZZ/lib
        #   - Bar::YYY -> -I/Foo/XXX/lib -I/Bar/YYY/lib -I/Baz/ZZZ/lib
        #   - Baz::ZZZ -> -I/Foo/XXX/lib -I/Bar/YYY/lib -I/Baz/ZZZ/lib
        my @linked = self.link-candidates(|@candidates);
        @ = @linked.map(*.dist.metainfo<includes>).flatmap(*.flat).unique;
    }
    multi method link-candidates(*@candidates) {
        # Default
        # Given Foo::XXX that depends on Bar::YYY that depends on Baz::ZZZ
        #   - Foo::XXX -> -I/Foo/XXX/lib -I/Bar/YYY/lib
        #   - Bar::YYY -> -I/Bar/YYY/lib -I/Baz/ZZZ/lib
        #   - Baz::ZZZ -> -I/Baz/ZZZ/lib
        @ = @candidates.map: -> $candi {
            my $dist := $candi.dist;

            my @dep-specs = unique(grep *.defined,
                ($dist.depends-specs       if ?$!depends).Slip,
                ($dist.test-depends-specs  if ?$!test-depends).Slip,
                ($dist.build-depends-specs if ?$!build-depends).Slip);

            # this could probably be done in the topological-sort itself
            $dist.metainfo<includes> = eager gather DEPSPEC: for @dep-specs -> $spec {
                for @candidates -> $fcandi {
                    my $fdist := $fcandi.dist;
                    if $fdist.contains-spec($spec) {
                        take $fdist.IO.child('lib').absolute;
                        take $_ for |$fdist.metainfo<includes>.grep(*.so);
                        next DEPSPEC;
                    }
                }
            }

            $candi;
        }
    }
}


# todo: write a real hooking implementation to CU::R::I instead of the current practice
# of writing an installer specific (literally) Build.pm
sub legacy-hook($candi) {
    my $dist := $candi.dist;
    my $DEBUG = ?%*ENV<ZEF_BUILDPM_DEBUG>;

    my $builder-path = $dist.IO.child('Build.pm');
    my $legacy-code  = $builder-path.IO.slurp;
    say "[Build] Attempting to build via {$builder-path}" if ?$DEBUG;

    # if panda is declared as a dependency then there is no need to fix the code, although
    # it would still be wise for the author to change their code as outlined in $legacy-fixer-code
    if ?$legacy-code.contains('use Panda')
        && !$dist.depends\      .first(/'panda' | 'Panda::'/)
        && !$dist.build-depends\.first(/'panda' | 'Panda::'/)
        && !$dist.test-depends\ .first(/'panda' | 'Panda::'/) {

        say "[Build] `build-depends` is missing entries. Attemping to mimick missing dependencies..." if ?$DEBUG;

        my $legacy-fixer-code = q:to/END_LEGACY_FIX/;
            class Build {
                method isa($what) {
                    return True if $what.^name eq 'Panda::Builder';
                    callsame;
                }
            END_LEGACY_FIX

        $legacy-code.subst-mutate(/'use Panda::' \w+ ';'/, '', :g);
        $legacy-code.subst-mutate('class Build is Panda::Builder {', "{$legacy-fixer-code}\n");
        $builder-path = "{$builder-path.absolute}.zef".IO;
        try { $builder-path.spurt($legacy-code) } || $builder-path.subst-mutate(/'.zef'$/, '');
    }


    my $cmd = "require <{$builder-path.basename}>; ::('Build').new.build('{$dist.IO.absolute}'); exit(0);";
    say "[Build] Command: `$cmd`" if ?$DEBUG;

    my $result;
    try {
        use Zef::Shell;
        CATCH { default { say "[Build] Something went wrong: $_" if ?$DEBUG; $result = False; } }
        my @includes = $dist.metainfo<includes>.grep(*.defined).map: { "-I{$_}" }
        my @exec = |($*EXECUTABLE, '-Ilib/.precomp', '-I.', '-Ilib', |@includes, '-e', "$cmd");
        say "[Build] cwd: {$dist.IO.absolute}" if ?$DEBUG;
        say "[Build] exec: {@exec.join(' ')}"  if ?$DEBUG;
        my $proc = zrun(|@exec, :cwd($dist.path), :out, :err);
        my @err = $proc.err.lines;
        my @out = $proc.out.lines;
        if ?$DEBUG {
            say "[Build] > $_" for @out;
            say "[Build] ! $_" for @err;
        }
        $ = $proc.out.close unless +@err;
        $ = $proc.err.close;
        $result = ?$proc;
    }
    $builder-path.IO.unlink if $builder-path.ends-with('.zef') && "{$builder-path}".IO.e;
    say "[Build] Result: {?$result??'Success'!!'Failure'}" if ?$DEBUG;
    $ = $result;
}
