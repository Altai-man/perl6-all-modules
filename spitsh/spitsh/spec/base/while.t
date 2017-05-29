use Test;

plan 28;

{
    my $i = 0;
    while ++$i < 3 {

    }
    pass "empty while loop";
}

{
    my $i = 0;

    while $i++ < 5 {
        pass "$i. while iteration";
    }

}

{
    my $i = 0;

    until $i++ == 5 {
        pass "$i. until iteration";
    }
}

class Foo is Int {
    method Bool? { $self <= 8 }
    method squared()-->Foo { $self * $self }
    method times2()-->Foo  { $self + $self }
}

{
    my $i = 1;
    while Foo($i).times2 {
        if $i == 4 {
            is .WHAT, 'Foo','while: $_ has correct .WHAT';
            is .squared,64, 'while: $_ has correct value'
        }
        $i++;
    }
}

{
    my $i = 1;
    while Foo($i).times2 -> $var {
        if $i == 4 {
            is $var.WHAT,'Foo','while: -> $var has correct .WHAT';
            is $var.squared,64,'while: -> $var has correct value';
        }
        $i++;
    }
}

{
    my $i = 8;
    until Foo($i).times2 {
        if $i == 5 {
            is .WHAT, 'Foo','until: $_ has correct .WHAT';
            is .squared,100, 'until: $_ has correct value'
        }
        $i--;
    }
}

{
    my $i = 1;
    ++$i while $i < 5;
    is $i,5,"statement-mod while";
}

{
    my $i = 1;
    is $i,4,'statement-mod while and cond' if $i == 4 while ++$i < 5;
}
{
    my $i = 1;
    is $i,4,'statement-mod until and cond' if $i == 4 until ++$i == 5;
}

{
    my $i = 1;
    is .squared,64,'statement-mod while: $_ has correct value' if $i++ == 4 while Foo($i).times2;
}

{
    my $j = 0;
    my @a = while ++$j < 5 { "foo$j" }

    is @a, <foo1 foo2 foo3 foo4>, "while loop as value";

    is ( @(while ++$j < 5 { Cmd("foo$j"),Cmd("bar$j") })).WHAT, List[Cmd],
       'while becomes List[of-whatever-block-returns]';

    $j = -1;
    is (while ++$j < 3 {  <one two three>[$j].uc }).${ sed 's/E/z/g' }, <ONz TWO THRzz>,
       "piping into command";
}

{
    # Testing that these methods don't turn into piped commands
    class BadPipe {
        method bad-pipe-cond+ {
            my $k = 1;
            while $self.${ grep >X $k } {
                $k++;
            }
            $k;
        }
        method bad-pipe-loop~ {
            my $k = 0;
            while $k < 4 {
                $self.${ grep $k };
                $k++;
            }
            "";
        }
    }

    is BadPipe<123>.bad-pipe-cond, 4, ‘invocant pipe in while condition’;
    is BadPipe<123>.bad-pipe-loop, <123 123 123>, 'invocant pipe in while block';
}

{

    is ${ printf '%s-%s-%s' (
             my @a = <one two three>;
             while @a {
                 my $item = @a[0];
                 @a.shift;
                 $item;
             }
         )
     }, 'one-two-three', 'while flattens in slurpy context';
}

{
    my @c = <1 2 3>;
    my $l = -1;
    my Int @d = while ++$l < 3 { $l,@c };
    is @d, <0 1 2 3 1 1 2 3 2 1 2 3>, 'while in List[Int] context';
}
