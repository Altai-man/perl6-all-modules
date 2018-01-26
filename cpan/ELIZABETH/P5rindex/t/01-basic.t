use v6.c;
use Test;
use P5rindex;

plan 7;

ok defined(::('&rindex')),          'is &rindex imported?';
ok !defined(P5rindex::{'&rindex'}), 'is &rindex externally NOT accessible?';

is rindex("foobar","bar"),    3, 'did we find bar';
is rindex("foobar","bar",99), 3, 'did we find bar after end';
is rindex("foofoo","bar"),   -1, 'did we *not* find bar';
is rindex("foofoo","foo",1),  0, 'did we find the first foo';
is rindex("foofoo","foo",9),  3, 'did we find the second foo after end';

# vim: ft=perl6 expandtab sw=4
