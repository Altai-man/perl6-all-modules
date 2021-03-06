unit module StepDefs;

use CucumisSextus::Glue;

my $trace;

Given /'a new Calculator object'/, sub () {
    say "# new-calculator";
    $trace ~= 'A';
};

Given /'ich habe einen Taschenrechner'/, sub () {
    say "# new-calculator-de";
    $trace ~= 'Ade';
};

Given /'a freshly unboxed Calculator'/, sub () {
    say "# unboxed-calculator";
    $trace ~= 'B';
}

Step /'having pressed' \s+ (\S+) [\s+ 'and' \s+ (\S+)]*/, sub (+@btns) {
    for @btns -> $b {
        $trace ~= "C$b";
    }
}

Step /'Ich habe die Taste' \s+ (\S+) \s+ 'gedrueckt'/, sub ($num) {
    say "# having-pressed-de '$num'";
    $trace ~= "D" ~ $num ~ "de";
};

Step /'having pressed' \s* (123)/, sub ($num) {
    say "# broken-having-pressed '$num'";
    $trace ~= "D$num";
};

Step /'having pressed' \s* (\d+) \s* 'again'/, sub () {
    say "# broken-having-pressed-again";
    $trace ~= 'E';
};

Then /'sollte der Bildschirm' \s+ ('-'? <[\d . ]>+) \s+ 'anzeigen'/, sub ($num) {
    say "# then-display-shows-de '$num'";
    $trace ~= "F" ~ $num ~ "de";
};

Then /'the display should show' \s+ ('-'? <[\d . ]>+)/, sub ($num) {
    say "# then-display-shows '$num'";
    $trace ~= "F$num";
};

# XXX temporary until we can replace them
Then /'the display should show' \s+ ('_' .+)/, sub ($num) {
    say "# then-display-shows '$num'";
    $trace ~= "F$num";
};

Step /'having it switched on'/, sub () {
    say "# having-switched-on";
    $trace ~= "G";
};

Step /'having successfully performed the following calculations'/, sub (@table) {
    say "# having-performed";
    for @table -> $r {
        $trace ~= "T" ~ $r{'first'} ~ $r{'operator'} ~ $r{'second'};
    }
}

Step /'having added these numbers'/, sub (@table) {
    say "# having-added-numbers";
}

Step /'having keyed' \s* (\S+)/, sub ($key) {
    say "# having-keyed";
    $trace ~= "t$key";
}

Step /'having entered the following sequence'/, sub ($text) {
    say "# having-entered";
    $trace ~= "U$text";
}

Then /'the display should be off'/, sub () {
    say "# display-should-be-off";
    $trace ~= "V1";
    die "display should be off, but isn't";
    $trace ~= "V2";
}

Given /'एक नई गणक वस्तु'/, sub () {
    $trace ~= "HG";
}

Step /(\d+) \s+ 'दबाया हुआ'/, sub ($num) {
    $trace ~= "H$num";
}

Then /'प्रदर्शन' \s+ (\d+) \s+ 'दिखाना चाहिए'/, sub ($num) {
    $trace ~= "T$num";
}

Before sub ($feature, $scenario) {
    if $feature.tags.first(* ~~ 'hooked') {
        $trace ~= '[';
    }
}

After sub ($feature, $scenario) {
    if $feature.tags.first(* ~~ 'hooked') {
        $trace ~= ']';
    }
}

Step /'یک شی' .*/, sub () {
}

Step /'فشرد' .*/, sub () {
}

Step /'صفحه' .*/, sub () {
}

sub clear-trace() is export {
    $trace = '';
}

sub get-trace() is export {
    return $trace;
}
