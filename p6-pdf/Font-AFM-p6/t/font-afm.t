use Test;
plan 5;

%*ENV<METRICS> = 'etc/Core14_AFMs';

require ::('Font::AFM');

my $font;

lives-ok {
   $font = ::('Font::AFM').new: :name<Helvetica>
}, 'Font::AFM.new: :name<Helvetica>' or do {
    diag "Can't find the AFM file for Helvetica";
    skip-rest "Can't find required font";
    exit;
};

is $font.Weight, 'Medium', '$font.Weight accessor'; 

dies-ok {$font.Guff}, 'unknown method - dies';

my $sw = $font.stringwidth("Gisle Aas");
is $sw, 4279, 'Stringwidth for Helvetica';

$sw = $font.stringwidth("Gisle Aas", 12);
is-approx $sw, 4279 * 12 / 1000, 'Stringwidth with pointsize';



