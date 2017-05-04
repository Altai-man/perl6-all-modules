use v6;
use Test;
plan 1;

use PDF::IO::IndObj;
use PDF::Writer;

use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;

my $actions = PDF::Grammar::PDF::Actions.new;

my $input = 't/pdf/ind-obj.in'.IO.slurp( :enc<latin-1> );
PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my %ast = $/.ast;

my $ind-obj = PDF::IO::IndObj.new( :$input, |%ast );

my $pdf-out = PDF::Writer.new( :$input );

# round trip
$input = $pdf-out.write( $ind-obj.ast );
PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "reparse failed";
%ast = $/.ast;

my $ind-obj2 = PDF::IO::IndObj.new( :$input, |%ast );

is-deeply $ind-obj.object.decoded, $ind-obj2.object.decoded, 'writer round trip';
