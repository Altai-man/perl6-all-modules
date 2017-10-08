#!/usr/bin/env perl6

sub MAIN ($filename = 'default.ppm') {
	my $width = my $height = 125;
 
	# Since P6 is a binary format, open in binary mode
	my $out = open("images/$filename", :w, :bin ) or die "$!\n";
 
	$out.say("P6\n$width $height\n255");
 
	for ^$height X ^$width -> $r, $g {
		my @rgb = (($r*2).Int, ($g*2).Int, (255-$r*2).Int);
		$out.print(@rgb.fmt('%c', ''));
	}
	$out.close;
}
