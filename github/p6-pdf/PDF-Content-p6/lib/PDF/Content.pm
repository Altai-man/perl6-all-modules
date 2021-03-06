use v6;
use PDF::Content::Ops :OpCode, :GraphicsContext, :ExtGState;

class PDF::Content:ver<0.2.8>
    is PDF::Content::Ops {

    use PDF::COS;
    use PDF::COS::Stream;
    use PDF::Content::Text::Block;
    use PDF::Content::XObject;
    use PDF::Content::Tag;

    method TWEAK(:$strict) {
        self.strict = $_ with $strict;
    }

    method graphics( &do-stuff! ) {
        $.op(Save);
        my \ret = do-stuff(self);
        $.op(Restore);
        ret;
    }

    method text( &do-stuff! ) {
        $.op(BeginText);
        my \ret = do-stuff(self);
        $.op(EndText);
        ret
    }

    multi method marked-content(PDF::Content::Tag $_, &do-stuff) {
        samewith( .tag, :props(.props), &do-stuff);
    }

    multi method marked-content( Str $tag,
                                 &do-stuff!,
                                 Hash :$props! where .so) {
        $.BeginMarkedContentDict($tag, $props);
        my \ret = do-stuff(self);
        $.EndMarkedContent;
        ret;
    }

    multi method marked-content( Str $tag, &do-stuff! ) {
        $.BeginMarkedContent($tag);
        my \ret = do-stuff(self);
        $.EndMarkedContent;
        ret;
    }

    method canvas( &mark-up! ) {
        my $canvas = (require HTML::Canvas).new;
        $canvas.context(&mark-up);
        self.draw($canvas);
    }

    method load-image($spec) {
        PDF::Content::XObject.open($spec);
    }

    #| extract any inline images from the content stream. returns an array of XObject Images
    method inline-images returns Array {
	my PDF::COS::Stream @images;
	for $.ops.keys.grep: { $.ops[$_].key eq 'BI' } -> $i {
	    my $v = $.ops[$i];
	    my $v1 = $.ops[$i+1];
	    die "'BI' op not followed by 'ID' in content stream"
		unless $v1 ~~ Pair && $v1.key eq 'ID';

	    my %dict = PDF::Content::XObject['Image'].inline-to-xobject($v.value[0]<dict>);
	    my $encoded = $v1.value[0]<encoded>;

	    @images.push: PDF::COS.coerce( :stream{ :%dict, :$encoded } );
	}
	@images;
    }

    use PDF::Content::Matrix :transform;
    method transform( |c ) {
	my Numeric @matrix = transform( |c );
	$.ConcatMatrix( @matrix );
    }

    method text-transform( |c ) {
	my Numeric @matrix = transform( |c );
	$.SetTextMatrix( @matrix );
    }

    my subset Align of Str where 'left' | 'center' | 'right';
    my subset Valign of Str where 'top'  | 'center' | 'bottom';

    #| place an image, or form object
    method do(PDF::COS::Stream $obj! where .<Subtype> ~~ 'Image'|'Form',
              Numeric $x = 0,
              Numeric $y = 0,
              Numeric :$width is copy,
              Numeric :$height is copy,
              Align   :$align  = 'left',
              Valign  :$valign = 'bottom',
              Bool    :$inline = False,
        )  {

        my Numeric $dx = { :left(0),   :center(-.5), :right(-1) }{$align};
        my Numeric $dy = { :bottom(0), :center(-.5), :top(-1)   }{$valign};

        $obj does PDF::Content::XObject[$obj<Subtype>]
            unless $obj ~~ PDF::Content::XObject;
        my $obj-width = $obj.width || 1;
        my $obj-height = $obj.height || 1;

        with $width {
            $height //= $_ * ($obj-height / $obj-width);
        }
        else {
            with $height {
                $width //= $_ * ($obj-width / $obj-height);
            }
            else {
                $width = $obj-width;
                $height = $obj-height;
            }
        }

        $dx *= $width;
        $dy *= $height;

        if $obj<Subtype> ~~ 'Form' {
            $obj.finish;
            $width /= $obj-width;
            $height /= $obj-height;
        }

        self.graphics: {
            $.op(ConcatMatrix, $width, 0, 0, $height, $x + $dx, $y + $dy);
            if $inline && $obj<Subtype> ~~ 'Image' {
                # serialize the image to the content stream, aka: :BI[:$dict], :ID[:$encoded], :EI[]
                $.ops( $obj.inline-content );
            }
            else {
                my Str:D $key = $.resource-key($obj),
                $.op(XObject, $key);
            }
        }
        # return the display rectangle for the image
       ($x + $dx,
        $y + $dy,
        $x + $dx + $width,
        $y + $dy + $height);
    }

    my subset Pattern of Hash where .<PatternType> ~~ 1|2;
    my subset TilingPattern of Pattern where .<PatternType> == 1;
    method use-pattern(Pattern $pat!) {
        $pat.finish
            if $pat ~~ TilingPattern;
        :Pattern(self.resource-key($pat));
    }

    multi method paint(Bool :$fill! where .so, Bool :$even-odd,
                       Bool :$close, Bool :$stroke) {
        my @paint-ops = $even-odd
            ?? ($close
                ?? ($stroke ?? <CloseEOFillStroke> !! <Close EOFill>)
                !! ($stroke ?? <EOFillStroke>      !! <EOFill>)
               )
            !! ($close
                ?? ($stroke ?? <CloseFillStroke>   !! <Close Fill>)
                !! ($stroke ?? <FillStroke>        !! <Fill>)
               );

        self."$_"()
            for @paint-ops;
    }

    multi method paint(Bool :$stroke! where .so, Bool :$close) {
        $close ?? self.CloseStroke !! self.Stroke
    }

    multi method paint() is default {
        self.EndPath;
    }

    method text-block($font = self!current-font[0], |c) {
        # detect and use the current text-state font
        my Numeric $font-size = $.font-size // self!current-font[1];
        PDF::Content::Text::Block.new(
            :gfx(self), :$font, :$font-size,
            |c,
            );
    }

    #| output text leave the text position at the end of the current line
    multi method print(Str $text,
                       |c,  # :$align, :$valign, :$kern, :$leading, :$width, :$height, :$baseline-shift, :$font, :$font-size
        ) {

        my $text-block = self.text-block( :$text, |c);
        $.print( $text-block, |c);
        $text-block;
    }

    my subset XPos-Pair of Pair where {.key ~~ Align && .value ~~ Numeric}
    my subset YPos-Pair of Pair where {.key ~~ Valign && .value ~~ Numeric}
    my subset Text-Position of List where {
        .elems <= 2
        && (!defined(.[0]) || .[0] ~~ Numeric|XPos-Pair)
        && (!defined(.[1]) || .[1] ~~ Numeric|YPos-Pair)
    }

    method !set-position($text-block, $position,
                         Bool :$left! is rw,
                         Bool :$top! is rw) {
        my $x;
        with $position[0] {
            when Numeric {$x = $_}
            when XPos-Pair {
                my constant Dx = %( :left(0.0), :center(0.5), :right(1.0) );
                $x = .value  +  Dx{.key} * $text-block.width;
                $left = True; # position from left
            }
        }
        my $y;
        with $position[1] {
            when Numeric {$y = $_}
            when YPos-Pair {
                my constant Dy = %( :top(0.0), :center(0.5), :bottom(1.0) );
                $y = .value  -  Dy{.key} * $text-block.height;
                $top = True; # position from top
            }
        }

        self.text-position = [$x, $y];
    }

    my subset Vector of List where {.elems == 2 && all(.list) ~~ Numeric}
    method text-position is rw returns Vector {
        warn '$.text-position accessor used outside of a text-block'
            unless $.context == GraphicsContext::Text;

	Proxy.new(
	    FETCH => sub (\p) {
                my @tm = @.TextMatrix;
	        @tm[4] / @tm[0], @tm[5] / @tm[3];
	    },
	    STORE => sub (\p, Vector \v) {
                my @tm = @.TextMatrix;
                @tm[4] = $_ * @tm[0] with v[0];
                @tm[5] = $_ * @tm[3] with v[1];
		self.op(SetTextMatrix, @tm);
	    },
	    );
    }

    multi method print(PDF::Content::Text::Block $text-block,
                       Text-Position :$position,
                       Bool :$nl = False,
                       Bool :$preserve = True,
        ) {

        my Bool $left = False;
        my Bool $top = False;
        my Bool \in-text = $.context == GraphicsContext::Text;

        unless in-text {
            my Str $tag = $text-block.type.Str;
            self.BeginMarkedContent($tag);
            self.BeginText;
        }

        self!set-position($text-block, $_, :$left, :$top)
            with $position;
        my ($x, $y) = $.text-position;
        my Numeric \font-size = $text-block.font-size;
        my \font = $.use-font($text-block.font);

        self.set-font(font, font-size);
        my ($x-shift, $y-shift) = $text-block.render(self, :$nl, :$top, :$left, :$preserve);
        $x += $x-shift;
        $y += $y-shift;

        unless in-text {
            self.EndText;
            self.EndMarkedContent;
        }
        # return the display rectangle for the text block
        ($x, $y, $x + $text-block.width, $y + $text-block.height);
    }

    #| output text; move the text position down one line
    method say($text = '', |c) {
        $.print($text, :nl, |c);
    }

    #| thin wrapper to $.op(SetFont, ...)
    multi method set-font( Hash $font!, Numeric $size = 16) {
        $.op(SetFont, $.resource-key($font), $size)
            if !$.font-face || $.font-size != $size || $.font-face !eqv $font;
    }

    method !current-font {
        $.Font // [$.core-font('Courier'), 16]
    }

    method font is rw returns Array {
        Proxy.new(
            FETCH => sub ($) {
                $.Font;
            },
            STORE => sub ($, $v) {
                my @v = $v.isa(List) ?? @$v !! [ $v, ];
                @v[0] = .use-font(@v[0]) with $.parent;
                self.set-font(|@v);
            },
        );
    }

    multi method print(Str $text, :$font = self!current-font[0], |c) {
        nextwith( $text, :$font, |c);
    }

    method draw($canvas, :$renderer = (require HTML::Canvas::To::PDF).new: :gfx(self)) {
        $canvas.render($renderer);
    }

    # map transformed user coordinates to untransformed (default) coordinates
    use PDF::Content::Matrix :dot;
    method base-coords(*@coords where .elems %% 2, :$user = True, :$text = False) {
        (
            flat @coords.map: -> $x is copy, $y is copy {
                ($x, $y) = dot($.TextMatrix, $x, $y) if $text;
                ($x, $y) = dot($.CTM, $x, $y) if $user;
                $x, $y;
            }
        )
    }
    method user-default-coords(|c) is DEPRECATED('base-coords') {
        $.base-coords(|c);
    }
}
