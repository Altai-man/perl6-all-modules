#!/usr/bin/env perl6
use Test;
use lib './lib';
use Grammar::BNF;

plan 4;

my ($t, $p);

$t = q[
<foo> ::= "bar"
];
ok Grammar::BNF.generate($t, name => 'test1').new.parse('bar');

$t = q[
<foo> ::= <bar'foo>
<bar'foo> ::= "baz"
];
ok Grammar::BNF.generate($t, name => 'test2').new.parse('baz');


$t = q[
<foo> ::= <bar> | <bar-z>
<bar> ::= "bar" | <bar-z>
<bar-z> ::= "buzz"
];
ok Grammar::BNF.generate($t).new.parse('buzz');

$t = q[
<foo> ::= <bar> <baz>
<bar> ::= 'foo'
<baz> ::= 'bar'
];
ok Grammar::BNF.generate($t).new.parse('foobar');

# TODO: Tests for other things in parse.t

done-testing;
