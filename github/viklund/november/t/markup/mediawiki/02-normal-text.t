use v6;

use Test;
plan 1;

use Text::Markup::Wiki::MediaWiki;

my $converter = Text::Markup::Wiki::MediaWiki.new;

my $input = 'normal text';
my $expected_output = '<p>normal text</p>';
my $actual_output = $converter.format($input);

is( $actual_output, $expected_output, 'normal text goes through unchanged' );

# vim:ft=perl6
