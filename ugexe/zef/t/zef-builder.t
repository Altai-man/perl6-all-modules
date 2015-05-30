use v6;
use Zef::Builder;
use Zef::Utils::PathTools;
use Test;
plan 1;



# Basic tests on default builder method
subtest {
    my $CWD     := $*CWD;
    my $save-to := $*SPEC.catdir($CWD,"test-libs").IO;

    my $lib-base  := $*SPEC.catdir($CWD, "lib").IO;
    my $blib-base = $*SPEC.catdir($save-to,"blib").IO;
    LEAVE try rm($save-to, :d, :f, :r);

    my @source-files  = ls($lib-base, :f, :r, d => False);
    my @target-files := gather for @source-files.grep({ $_.IO.basename ~~ / \.pm6? $/ }) -> $file {
        my $mod-path := $*SPEC.catdir($blib-base, "{$file.IO.dirname.IO.relative}").IO;
        my $target   := $*SPEC.catpath('', $mod-path.IO.path, "{$file.IO.basename}.{$*VM.precomp-ext}").IO;
        take $target.IO.path;
    }

    my $builder = Zef::Builder.new;
    my @results = $builder.pre-compile($CWD, :$save-to);

    is @results.elems, 1, '1 repo';
    is @results.[0].<curlfs>.list.grep({ $_.has-precomp }).elems, 
       @results.[0].<curlfs>.list.elems, 
       "Default builder precompiled all modules";
    for @target-files -> $file {
        is any(@results.[0].<curlfs>.list.map({ $_.precomp-path })), $file.IO.absolute, "Found: {$file.IO.path}";
    }
}, 'Zef::Builder';



done();
