use lib 'lib';

use Twitter;
my Twitter $t .= new: |EVALFILE 'keys';

$t.tweet: 'Testing Perl 6';
say $t.search: q{"Perl 6" :)};
