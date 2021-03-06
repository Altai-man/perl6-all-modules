use v6;

class PDF::Font::Loader:ver<0.2.1> {

    use Font::FreeType;
    use Font::FreeType::Face;
    use PDF::Font::Loader::FreeType;
    use PDF::Font::Loader::Type1;

    subset TrueTypish of Font::FreeType::Face where .font-format eq 'TrueType'|'CFF';
    subset Type1ish of Font::FreeType::Face where .font-format eq 'Type 1';

    sub load-font(|c) is export(:load-font) {
        $?CLASS.load-font(|c);
    }

    multi method load-font(Str :$file!, |c) {
        my Blob $font-stream = $file.IO.open(:r, :bin).slurp: :bin;
        self.load-font(:$font-stream, |c);
    }

    multi method load-font(Blob :$font-stream!, |c) is default {
        my $free-type = Font::FreeType.new;
        my $face = $free-type.face($font-stream);
        given $face {
            when TrueTypish {
                die "unable to handle TrueType Collections"
                    if $font-stream.subbuf(0,4).decode('latin-1') eq 'ttcf';
                PDF::Font::Loader::FreeType.new( :$face, :$font-stream, |c);
            }
            when Type1ish {
                PDF::Font::Loader::Type1.new( :$face, :$font-stream, |c);
            }
            default { die "unable to handle font of format {.font-format}"; }
        }
    }

    # resolve font name via fontconfig
    multi method load-font(Str :$name!, |c) {
        my $file = self.find-font($name, |c);
        self.load-font: :$file, |c;
    }

    multi method load-font(Font::FreeType::Face :$face!, |c) {
        die "unsupported font format: {$face.font-format}";
    }

    sub find-font(|c) is export(:find-font) {
        $?CLASS.find-font(|c);
    }
    subset Weight  of Str where /^[thin|extralight|light|book|regular|medium|semibold|bold|extrabold|black|[1..9]00]$/;
    subset Stretch of Str where /^[[ultra|extra]?[condensed|expanded]]|normal$/;
    subset Slant   of Str where /^[normal|oblique|italic]$/;
    method find-font(Str $family-name,
                     Weight :$weight is copy = 'medium',
                     Stretch :$stretch = 'normal',
                     Slant :$slant = 'normal') {
        my $pat = $family-name;
        with $weight {
            # convert CSS/PDF numeric weights for fontconfig
            #      000  100        200   300  400     500    600      700  800       900
            $_ =  <thin extralight light book regular medium semibold bold extrabold black>[$0]
                if /^(0..9)00$/;
        }
        $pat ~= ':weight=' ~ $weight  unless $weight eq 'medium';
        $pat ~= ':width='  ~ $stretch unless $stretch eq 'normal';
        $pat ~= ':slant='  ~ $slant   unless $slant eq 'normal';

        my $cmd =  run('fc-match',  '-f', '%{file}', $pat, :out, :err);
        given $cmd.err.slurp {
            note $_ if $_;
        }
        my $file = $cmd.out.slurp;
        $file
          || die "unable to resolve font: $pat"
    }
}

=begin pod

=head1 NAME

PDF::Font::Loader

=head1 SYNPOSIS

 use PDF::Lite;
 use PDF::Font::Loader;
 my $deja = PDF::Font::Loader.load-font: :file<t/fonts/DejaVuSans.ttf>;

 use PDF::Font::Loader :load-font;
 my $deja = load-font( :file<t/fonts/DejaVuSans.ttf> );

 # requires fontconfig
 use PDF::Font::Loader :load-font. :find-font;
 $deja = load-font( :name<DejaVu>, :slant<italic> );

 my $file = find-font( :name<DejaVu>, :slant<italic> );
 my $deja-vu = load-font: :$file;

 my PDF::Lite $pdf .= new;
 $pdf.add-page.text: {
    .font = $deja;
    .text-position = [10, 600];
    .say: 'Hello, world';
 }
 $pdf.save-as: "/tmp/example.pdf";

=head1 DESCRIPTION

This module provdes font loading and handling for
L<PDF::Lite>,  L<PDF::API6> and other PDF modules.

=head1 METHODS

=head3 load-font

A class level method to create a new font object.

=head4 C<PDF::Font::Loader.load-font(Str :$file);>

Loads a font file.

parameters:
=begin item
C<:$file>

Font file to load. Currently supported formats are:
=item2 Open-Type (C<.otf>)
=item2 True-Type (C<.ttf>)
=item2 Postscript (C<.pfb>, or C<.pfa>)

=end item

=head4 C<PDF::Font::Loader.load-font(Str :$name);>

 my $vera = PDF::Font::Loader.load-font: :name<vera>;
 my $deja = PDF::Font::Loader.load-font: :name<Deja>, :weight<bold>, :width<condensed> :slant<italic>);

Loads a font by a fontconfig name and attributes.

Note: Requires fontconfig to be installed on the system.

parameters:
=begin item
C<:$name>

Name of an installed system font to load.

=end item

=head3 find-font

  find-font(Str $family-name,
            Str :$weight,     # thin|extralight|light|book|regular|medium|semibold|bold|extrabold|black|100..900
            Str :$stretch,    # normal|[ultra|extra]?[condensed|expanded]
            Str :$slant,      # normal|oblique|italic
            );

Locates a matching font-file. Doesn't actually load it.

   my $file = PDF::Font::Loader.find-font('Deja', :weight<bold>, :width<condensed>, :slant<italic>);
   say $file;  # /usr/share/fonts/truetype/dejavu/DejaVuSansCondensed-BoldOblique.ttf
   my $font = PDF::Font::Loader.load-font( :$file )';

=head1 BUGS AND LIMITATIONS

=item Font subsetting is not yet implemented. I.E. fonts are always fully embedded, which may result in large PDF files.

=end pod

