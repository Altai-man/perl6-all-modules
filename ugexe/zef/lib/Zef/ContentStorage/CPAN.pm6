use Zef;
use Zef::Distribution;
use Zef::Distribution::DependencySpecification;

# todo: clear search json files
class Zef::ContentStorage::CPAN does ContentStorage {
    has $.mirrors;
    has $.fetcher is rw;
    has $.cache is rw;

    method IO {
        my $dir = $!cache.IO.child('metacpan');
        $dir.mkdir unless $dir.e;
        $dir;
    }

    method search(:$max-results = 5, *@identities, *%fields) {
        return () unless @identities || %fields;

        my $matches := gather DIST: for |@identities -> $wants {
            my $wants-spec = Zef::Distribution::DependencySpecification.new($wants);
            temp %fields<distribution> = $wants-spec.name.subst('::', '-', :g);
            temp %fields<author>       = $wants-spec.auth-matcher.match(/^.*? ':' (.*)$/)[0].Str
                if ?$wants-spec.auth-matcher;
            temp %fields<version>      = $wants-spec.version-matcher.subst(/^v?/, '?')
                if ?$wants-spec.version-matcher && $wants-spec.version-matcher ne '*';

            my $query-string = %fields.grep(*.key.defined).map(-> $q {
                $q.value.map({"{$q.key}:$_"}).join('%20')
            }).join('%20AND%20');
            my $search-url = $!mirrors[0] ~ '_search?q=' ~ $query-string;

            # Query results currently saved to file for now to ease writing shell based
            # fetchers. Soon those will just print it to stdout, and return the captured raw data,
            # but the Fetcher interface needs to be updated to accommodate this.
            my $search-save-as = self.IO.child('search').IO.child("{time}.{$*THREAD.id}.json");

            if ($ = $!fetcher.fetch($search-url, $search-save-as)).IO.e {
                if from-json($search-save-as.IO.slurp) -> %meta {
                    # This should generally return the same distribution but in various versions.
                    # However we will need to be prepared for when multiple distributions are returned
                    # and sorting by version may no longer make sense
                    my @dist-candidates = (^($max-results [min] %meta<hits><hits>.elems)).map: {
                        my $meta6 = METACPAN2META6(%meta<hits><hits>[$_]<_source>);

                        my $host           = 'http://hack.p6c.org:5001';
                        $meta6<source-url> = $host ~ $meta6<source-url>;

                        my $dist      = Zef::Distribution.new(|$meta6);
                        my $candidate = Candidate.new(
                            dist           => $dist,
                            uri            => $dist.source-url,
                            requested-as   => $wants,
                            recommended-by => self.^name,
                        );
                    }

                    my $newest-candidate = |@dist-candidates.sort({ $^b.dist cmp $^a.dist }).head;

                    take $newest-candidate;
                }
            }
        }
    }
}

# This is just a hack to try and create a meta6 from what metacpan gives us. This is often
# missing items (but not always) like provides which will likely always be present in a
# perl6 specific API search result
sub METACPAN2META6(%cpan-meta) {
    my $meta6;
    $meta6<name>        = (%cpan-meta<distribution> // %cpan-meta<metadata><name> // '').subst('-', '::', :g);
    $meta6<version>     = (%cpan-meta<metadata><version> // %cpan-meta<version_numified> // '*');
    $meta6<author>      = (%cpan-meta<author> // %cpan-meta<metadata><name> // '');
    $meta6<description> = (%cpan-meta<abstract> // '');
    $meta6<license>     = (%cpan-meta<license> // '').join(',');
    $meta6<provides>    = (%cpan-meta<metadata><provides>.kv.map: { $^a => $^b<file> } // {});

    # $meta6<depends>     = (%cpan-meta<dependency> // '').map({ .<module> ~ (.<version_numified> ?? ":{.<version_numified>}" !! '') }).join(',');
    $meta6<depends>     = %cpan-meta<metadata><x_depends>;

    $meta6<authority>   = 'cpan';
    $meta6<auth>        = $meta6<metadata><x_authority> // (?$meta6<author> ?? ($meta6<authority> ~ ':' ~ $meta6<author>) !! '');

    # not official spec, but it *is* a Distribution attribute
    $meta6<source-url>  = %cpan-meta<download_url>;

    $meta6;
}