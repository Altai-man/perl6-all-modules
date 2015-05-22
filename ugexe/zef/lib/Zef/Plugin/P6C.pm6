use Zef::Phase::Getting;
use Zef::Plugin::Git;
use Zef::Utils::HTTPClient;
use Zef::Utils::Depends;

our $p6c = 'http://ecosystem-api.p6c.org/projects.json';

role Zef::Plugin::P6C does Zef::Phase::Getting {
    method get(:$save-to is copy = $*TMPDIR, *@modules) {
        my $response = Zef::Utils::HTTPClient.new.get($p6c);
        my @projects = @(from-json($response.content));
        my @wanted   = @projects.grep({ $_.<name> ~~ any(@modules) });
        my @tree     = build-dep-tree( @projects, target => $_ ) for @wanted;
        my @results  = eager gather for @tree -> %node {
            my @git  = Zef::Plugin::Git.new.get(:$save-to, %node.<source-url>);
            take { module => %node.<name>, path => @git.[0].<path> }
        }
        return @results;
    }
}
