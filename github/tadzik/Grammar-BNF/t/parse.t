#!/usr/bin/env perl6
use Test;
use lib './lib';
use Grammar::BNF;

plan 6;

my $t;

$t = q[
<foo> ::= "bar"
];
ok Grammar::BNF.new.parse($t);

$t = q[
<foo> ::= <bar'foo>
<bar'foo> ::= "baz"
];
ok Grammar::BNF.new.parse($t);

$t = q[
<foo> ::= <bar> | <bar-z>
<bar> ::= "bar" | <bar-z>
<bar-z> ::= "buzz"
];
ok Grammar::BNF.new.parse($t);

$t = q[
<foo> ::= <bar> <baz>
];
ok Grammar::BNF.new.parse($t);

$t = q[
<postal-address> ::= <name-part> <street-address> <zip-part>
 
      <name-part> ::= <personal-part> <last-name> <opt-suffix-part> <EOL> 
                    | <personal-part> <name-part>
 
  <personal-part> ::= <initial> "." | <first-name>
 
 <street-address> ::= <house-num> <street-name> <opt-apt-num> <EOL>
 
       <zip-part> ::= <town-name> "," <state-code> <ZIP-code> <EOL>
 
<opt-suffix-part> ::= "Sr." | "Jr." | <roman-numeral> | ""
    <opt-apt-num> ::= <apt-num> | ""
];
ok Grammar::BNF.new.parse($t);

# unmodified grammar from wikipedia
# <expression> is actually wrong and needs more optional whitespace; see the Perl 6 grammar
$t = q[
<syntax>         ::= <rule> | <rule> <syntax>
<rule>           ::= <opt-whitespace> "<" <rule-name> ">" <opt-whitespace> "::=" <opt-whitespace> <expression> <line-end>
<opt-whitespace> ::= " " <opt-whitespace> | ""
<expression>     ::= <list> | <list> "|" <expression>
<line-end>       ::= <opt-whitespace> <EOL> | <line-end> <line-end>
<list>           ::= <term> | <term> <opt-whitespace> <list>
<term>           ::= <literal> | "<" <rule-name> ">"
<literal>        ::= '"' <text> '"' | "'" <text> "'"
];
ok Grammar::BNF.new.parse($t);

done-testing;
