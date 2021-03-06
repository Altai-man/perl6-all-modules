[![Build Status](https://travis-ci.org/lizmat/P5chr.svg?branch=master)](https://travis-ci.org/lizmat/P5chr)

NAME
====

P5chr - Implement Perl 5's chr() / ord() built-ins

SYNOPSIS
========

    use P5chr; # exports chr() and ord()

    my $a = 65;
    say chr $a;

    $_ = 65;
    say chr();   # bare chr may be compilation error to prevent P5isms in Perl 6

    my $a = "A";
    say ord $a;

    $_ = "A";
    say ord();   # bare ord may be compilation error to prevent P5isms in Perl 6

DESCRIPTION
===========

This module tries to mimic the behaviour of the `chr` and `ord` functions of Perl 5 as closely as possible.

ORIGINAL PERL 5 DOCUMENTATION
=============================

    chr NUMBER
    chr     Returns the character represented by that NUMBER in the character
            set. For example, "chr(65)" is "A" in either ASCII or Unicode, and
            chr(0x263a) is a Unicode smiley face.

            Negative values give the Unicode replacement character
            (chr(0xfffd)), except under the bytes pragma, where the low eight
            bits of the value (truncated to an integer) are used.

            If NUMBER is omitted, uses $_.

            For the reverse, use "ord".

            Note that characters from 128 to 255 (inclusive) are by default
            internally not encoded as UTF-8 for backward compatibility
            reasons.

    ord EXPR
    ord     Returns the numeric value of the first character of EXPR. If EXPR
            is an empty string, returns 0. If EXPR is omitted, uses $_. (Note
            character, not byte.)

            For the reverse, see "chr".

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5chr . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

