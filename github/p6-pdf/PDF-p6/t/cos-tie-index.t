use v6;
use Test;
plan 18;

use PDF::COS::Array;

{
    # basic class tests
    my role MyRole {};
    my class TestArray
    is PDF::COS::Array {
        use PDF::COS::Tie;
        has Int $.I0 is index(0, :required);
        multi sub coerce($v, MyRole) { $v does MyRole }
        has MyRole $.R1 is index(1, :&coerce);
        has Int %.H2 is index(2);
        has Int $.I3 is index(3, :required);
    }

    my $array-in = [42, 10, { :a(20), :b(30) }, 40 ];
    my TestArray $array;
    lives-ok { $array .= new: :array($array-in) }, 'construction sanity';
    isa-ok $array, Array;
    is $array.I0, 42, 'accessor sanity';
    is $array.R1, 10, 'coercement';
    does-ok $array.R1, MyRole, 'coercement';
    is $array.H2<b>, 30, 'container';
    lives-ok {$array.check}, ".check valid array";
    $array.pop;
    lives-ok {$array.check}, ".check invalid array";
    $array.pop;
    lives-ok {$array.H2}, 'non-required field';
    dies-ok {$array.I3},  'required field';
}

{
    # role coercement tests
    use PDF::COS::Tie::Array;
    use PDF::COS::Name;
    my role TestArray
    does PDF::COS::Tie::Array {
        use PDF::COS::Tie;
        has PDF::COS::Name $.name is index(0);
    }
    my $array-in = ['Hi'];
    my PDF::COS $array .= coerce($array-in, TestArray);
    isa-ok($array, PDF::COS::Array);
    does-ok($array, TestArray);
    does-ok($array[0], PDF::COS::Name);
    is $array.name, 'Hi';
    is-deeply $array.content, (:array($[:name<Hi>])), '.content';
    lives-ok {$array.check}, '.check valid';
    quietly {
        $array[0] = 42;
        dies-ok {$array.check}, '.check invalid';
        $array[0] = {};
        dies-ok {$array.check}, '.check invalid';
    }
}


done-testing;
