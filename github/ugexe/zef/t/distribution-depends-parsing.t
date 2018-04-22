use v6;
use Test;
plan 4;

use Zef::Distribution;

my $json = q:to/META6/;
    {
        "perl":"6",
        "name":"Test::Complex::Depends",
        "version":"0",
        "auth":"github:stranger",
        "description":"Test hash-based depends and native depends parsing",
        "license":"none",
        "depends": [
            "Zef::Client",
            {
                "from": "native",
                "name": {
                    "by-distro.name": {
                        "macosx": "mac",
                        "win32" : "win",
                        "linux" : "linux",
                        ""      : "unknown"
                    }
                }
            }
        ],
        "build-depends": [ "Zef::Build" ],
        "test-depends": [ "Zef::Test" ],
        "provides": { }
    }
    META6

my $dist = Zef::Distribution.new(|Rakudo::Internals::JSON.from-json($json));
is $dist.depends-specs[0].name, 'Zef::Client';
is $dist.depends-specs[0].from-matcher, 'Perl6';
ok $dist.depends-specs[1].name ~~ any('mac', 'win', 'linux', 'unknown');
is $dist.depends-specs[1].from-matcher, 'native';
