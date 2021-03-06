[![Build Status](https://travis-ci.org/lizmat/Tie-Array.svg?branch=master)](https://travis-ci.org/lizmat/Tie-Array)

NAME
====

Tie::Array - Implement Perl 5's Tie::Array core module

SYNOPSIS
========

    use Tie::Array;

DESCRIPTION
===========

Tie::Array is a module intended to be subclassed by classes using the </P5tie|tie()> interface. It depends on the implementation of methods `FETCH`, `STORE`, `FETCHSIZE` and `STORESIZE`.

The `EXISTS` method should be implemented if `exists` functionality is needed. The `DELETE` method should be implemented if `delete` functionality is needed. Apart from these, all other interfaces methods are provided in terms of `FETCH`, `STORE`, `FETCHSIZE` and `STORESIZE`.

SEE ALSO
========

[P5tie](P5tie), [Tie::StdArray](Tie::StdArray)

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Tie-Array . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

