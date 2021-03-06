use v6;
use Test;
use _007::Test;

{
    my $program = q:to/./;
        say(1);
        .

    outputs $program, "1\n", "say() works";
}

{
    my $program = q:to/./;
        say(type(prompt(">>> ")));
        .

    outputs $program, ">>> \n<type None>\n", "say() works";
}

{
    my $program = q:to/./;
        say(type(none));
        .

    outputs $program, "<type None>\n", "none type() works";
}

{
    my $program = q:to/./;
        my n = 7;
        say(type(n));
        .

    outputs $program, "<type Int>\n", "Int type() works";
}

{
    my $program = q:to/./;
        my s = "Bond";
        say(type(s));
        .

    outputs $program, "<type Str>\n", "Str type() works";
}

{
    my $program = q:to/./;
        my a = [1, 2];
        say(type(a));
        .

    outputs $program, "<type Array>\n", "Array type() works";
}

{
    my $program = q:to/./;
        func f() {}
        say(type(f));
        .

    outputs $program, "<type Func>\n", "Func type() works";
}

{
    my $program = q:to/./;
        say(type(say));
        .

    outputs $program, "<type Func>\n", "builtin func type() returns the same as ordinary func";
}

{
    my $program = q:to/./;
        say(0, 0, 7);
        say(say);
        .

    outputs $program, "007\n<func say(...args)>\n", "builtin func say() has varargs";
}

{
    my $program = q:to/./;
        exit();
        .

    has-exit-code $program, 0, "exit without a parameter";
}

{
    my $program = q:to/./;
        exit(1);
        .

    has-exit-code $program, 1, "exit with a parameter";
}

{
    my $program = q:to/./;
        exit(-1);
        .

    has-exit-code $program, 255, "exit is modulo 256";
}

{
    my $program = q:to/./;
        func foo() {
            exit();
            say("foo");
        }

        func bar() {
            foo();
            say("bar");
        }

        bar();
        .

    outputs $program, "", "nothing is run after exit()";
}

{
    my $program = q:to/./;
        assertType(5, Int);
        .

    outputs $program, "", "assertType does nothing if it finds something of the right type";
}

{
    my $program = q:to/./;
        macro moo() {}

        assertType(moo, Func);
        .

    outputs $program, "", "assertType respects inheritance, so this will work since a Macro is a Func";
}

{
    my $program = q:to/./;
        assertType(5, Str);
        .

    runtime-error
        $program,
        X::TypeCheck,
        "asserType throws a typecheck exception if the value is of the wrong type";
}

done-testing;
