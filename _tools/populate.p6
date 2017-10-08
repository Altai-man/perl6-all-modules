use v6;
use JSON::Tiny;
unit sub MAIN(Bool :$delete=True, Bool :$fetch=True, Bool :$ignore-errors);

run 'wget', '-O', 'projects.json', 'http://ecosystem-api.p6c.org/projects.json'
    if $fetch;
my $json = slurp 'projects.json';
my @projects = from-json($json).list;
my %local-seen;
for @projects {
    my $url = try { .<source-url> // .<repo-url> // .<support><source> };

    unless defined $url {
        warn "No source-url for $_.perl()";
        next;
    }

    my @chunks = $url.split('/');
    my $local = join '/', @chunks[*-2, *-1];
    $local ~~ s/ '.git' $ //;
    my $prefix = $url.contains('gitlab.com') ?? 'gitlab' !! 'github';
    $local = "$prefix/$local";
    %local-seen{$local} = True;
    if $ignore-errors {
       my $proc = run 'git', 'subrepo', 'clone', '-f', $url, $local;
       if $proc.exitcode {
            run 'git', 'reset', 'HEAD';
            run 'git', 'checkout', '.';
        }
    }
    else {
        run 'git', 'subrepo', 'clone', '-f', $url, $local;
    }
}

# find all dirs of the form author/module and potentially remove them

my $removed = 0;

for dir().grep(*.d).grep(*.basename eq none('_tools', '.git')).map({ dir($_).grep(*.d)}).flat {
    my $local = $_.relative;
    unless %local-seen{$local} {
        if $delete && $local.IO.e {
            say "Removing $local";
            try run 'git', 'rm', '-rf', $local;
            $removed++;
        }
        else {
            say "Would remove $local";
        }
    }
}

if $removed {
    run 'git', 'commit', '-m', "Remove repos that no longer exist\n\n(This commit was automatically generated)";
}

say "Done updating, now doing a repack to save space";
run 'git', 'repack', '-Ad';
