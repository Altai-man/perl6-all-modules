#!/pro/bin/perl

use 5.18.2;
use warnings;

sub usage {
    my $err = shift and select STDERR;
    say "usage: $0 [--verbose[=#]] [--irc]";
    exit $err;
    } # usage

use Time::HiRes qw( gettimeofday tv_interval );
use Getopt::Long qw(:config bundling);
my $opt_6 = 1;
GetOptions (
    "help|?"      => sub { usage (0); },
    "i|irc!"      => \my $opt_i,
    "p|perl6!"    =>    \$opt_6,
    "f|fast"      => sub { $opt_6 = 0; },
    "v|verbose:1" => \my $opt_v,
    ) or usage (1);

$| = 1;
$opt_v //= $opt_i ? 0 : 1;

# cpupower frequency-set -g performance

open  my $fh, "<", "/tmp/hello.csv";
1 while <$fh>;
close    $fh;

my %lang = (
    ##       ext     prog       args
     0 => [ ".rb",  "ruby1.9",         ],
     1 => [ ".rb",  "ruby2.0",         ],
     2 => [ ".py",  "python2",         ],
     3 => [ ".py",  "python3",         ],
     4 => [ ".php", "php",     "-nq"   ],
     5 => [ ".pl",  "perl",            ],
     6 => [ ".pl",  "perl6",   "-Ilib" ],
     7 => [ ".lua", "lua"              ],
     8 => [ ".go",  "go",      "run"   ],
     9 => [ "",     "C"                ],
    14 => [ "",     "java6",   "-cp csv-java6.jar:opencsv-2.3.jar csvJava" ],
    10 => [ "",     "java7",   "-cp csv-java7.jar:opencsv-2.3.jar csvJava" ],
    11 => [ "",     "java8",   "-cp csv-java8.jar:opencsv-2.3.jar csvJava" ],
    12 => [ "",     "java9",   "-cp csv-java9.jar:opencsv-2.3.jar csvJava" ],
    13 => [ ".R",   "R",       "--slave -f" ],
    );
my @test = (
    # lang irc script
    [  5, 0, "csv-easy-xs" ],
    [  5, 0, "csv-easy-pp" ],
    [  5, 0, "csv-xsbc"    ],
    [  5, 0, "csv-test-xs" ],
    [  5, 0, "csv-test-pp" ],
    [  5, 0, "csv-pegex"   ],
    [  6, 0, "csv"         ],
    [  6, 1, "csv-ip5xs"   ],
    [  6, 0, "csv-ip5xsio" ],
    [  6, 0, "csv-ip5pp"   ],
    [  6, 0, "csv_gram"    ],
    [  6, 1, "test"        ],
    [  6, 1, "test-t"      ],
    [  6, 1, "csv-parser"  ],
    [  9, 0, "csv-c"       ],
    [  7, 0, "csv-lua"     ],
    [  2, 0, "csv-python2" ],
    [  3, 0, "csv-python3" ],
    [  4, 0, "csv-php"     ],
    [ 11, 0, "csv-java8"   ],
    [ 14, 0, "csv-java6"   ],
    [ 10, 0, "csv-java7"   ],
    [  0, 0, "csv-ruby"    ],
    [  1, 0, "csv-ruby"    ],
    [  8, 0, "csv-go"      ],
    [ 13, 0, "csv-R"       ],
    [ 12, 0, "csv-java9"   ],
    );

sub runfrom {
    my ($v, $script, $file) = @_;
    my ($ext, $exe, @arg) = @{$lang{$v}};

    $exe eq "C" and $exe = "";
    my $run = join " " => $exe, @arg;

    $opt_v > 4 and say "$v / $ext / $exe\t/ $run";
    my $i = 0;
    my $cmd = "$run $script$ext <$file";
    $opt_v > 2 and say $cmd;
    $file eq "empty.csv" and $cmd .= " 2>/dev/null";
    my $t0 = [ gettimeofday ];
    open my $th, "-|", $cmd;
    while (<$th>) {
        m/^(?:\[\d+\]\s+)?(\d+)$/ and $i = $1;
        }
    return (scalar tv_interval ($t0), $i);
    } # runfrom

my $pat = shift // ".";

my $run_speed = 0;
my @time;
my @irc;
for (@test) {
    my ($v, $irc, $script) = @$_;
    $script =~ m{$pat}i or  next;
    $opt_i && !$irc     and next;

    my ($ext, $exe, @arg) = @{$lang{$v}};

    $exe eq "perl6" && !$opt_6 and next;

    $opt_v and printf "%-8s ", $exe;
    my $s_script = sprintf "%-11s ", $script;
    print $s_script;

    local *STDERR;
    open STDERR, ">", "/dev/null";

    open my $eh, ">", "empty.csv";
    print $eh  "\n";
    close $eh; END { unlink "empty.csv"; }

                    runfrom ($v, $script, "empty.csv");
                    runfrom ($v, $script, "empty.csv");
    my ($start)   = runfrom ($v, $script, "empty.csv");
    my ($run, $i) = runfrom ($v, $script, "/tmp/hello.csv");

    my $s = sprintf "%s %6d %9.3f %9.3f", $i eq 50000 ? "   " : "***", $i,
        $run, $run - $start;
    say $s;
    push @time, [ $script, $s_script, $i, $run, $start, $exe ];

    if ($script eq "test-t" and open my $fh, ">>", "../Talks/CSV6/speed.log") {
        my @d = localtime;
        printf $fh "%4d-%02d-%02d %02d:%02d:%02d test-t %.3f\n",
            $d[5] + 1900, $d[4] + 1, @d[3,2,1,0], $run;
        close $fh;
        $run_speed++;
        }

    $opt_i and next;
    $irc and push @irc, $time[-1];
    }

printf "%s %9.3f\n", $_->[1], $_->[3] for @irc;

if (!$opt_i and open my $fh, ">", "../Talks/CSV6/speed5.html") {
    print $fh <<'EOH';
<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
  <title>Parsing CSV</title>
  <meta name="Generator"     content="elvis 2.2" />
  <meta name="Author"        content="H.Merijn Brand" />
  <meta name="Description"   content="Parsing CSV in perl" />

  <link rel="SHORTCUT ICON"  href="images/csv.ico" />

  <link rel="stylesheet" type="text/css"  href="csv.css" />
  <link rel="next"       type="text/html" href="attributes.html" />
  <style type="text/css">
    td { text-align: left; }
    thead > tr > td { font-weight: bold; background: #c0c0c0; }
    </style>
  </head>
<body>
<table>
  <tr class="boxed">
    <td class="boxed">
      <h1><a class="navF" href="attributes.html">Other languages</a></h1>
      <table>
	<thead>
	  <tr><td>language</td><td>script</td><td>check</td><td>count</td><td>time</td><td>runtime</td></tr>
	  </thead>
	<tbody>
EOH
    foreach my $t (sort { $a->[3] <=> $b->[3] } @time) {
        my ($script, $s_script, $i, $run, $start, $exe) = @$t;
        my ($s_run, $s_run2) = map { sprintf "%.3f", $_ } $run, $run - $start;
        $s_run2 =~ m/^-/ and $s_run2 = "0.000";
        $exe =~ s/perl$/perl5/;
        say $fh
            qq{\t  <tr@{[$exe =~ m/^perl/ ? qq{ class="$exe"} : ""]}>},
                qq{<td>$exe</td>},
                qq{<td>$script</td>},
                qq{<td>@{[$i == 50000 ? "&nbsp;" : "***"]}</td>},
                qq{<td class="@{[$i == 50000 ? 'fixed'  : 'broken']}">$i</td>},
                qq{<td class="time">$s_run</td>},
                qq{<td class="time">$s_run2</td>},
                qq{</tr>};
        }
    my @d = localtime;
    print $fh <<"EOF";
	  </tbody>
	</table>
      <ul>
	<li><strong>count</strong> should be 50000</li>
	<li><strong>time</strong> is the time taken to parse 10000 CSV lines with 5 fields each</li>
	<li><strong>runtime</strong> is time minus time taken to run script from an empty stream</li>
	</ul>
      <p>See also <a href="https://bitbucket.org/ewanhiggs/csv-game">the CSV game</a>.</p>
      </td>
    </tr>
  </table>

<p class="update">last update: @{[join "-" => map { sprintf "%02d", $_ } $d[3], $d[4] + 1, $d[5] + 1900]}</p>
</body>
</html>
EOF
    close $fh;
    }

if ($run_speed) {
    chdir "../Talks/CSV6";
    exec "perl speed.pl >/dev/null 2>&1";
    }
