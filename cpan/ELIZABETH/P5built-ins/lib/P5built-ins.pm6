use v6.c;

my %export;
module P5built-ins:ver<0.0.22>:auth<cpan:ELIZABETH> {
    use P5__FILE__;
    use P5caller:ver<0.0.6>:auth<cpan:ELIZABETH>;
    use P5chdir;
    use P5chomp;
    use P5chr;
    use P5defined;
    use P5each;
    use P5fc;
    use P5fileno;
    use P5getgrnam:ver<0.0.6>:auth<cpan:ELIZABETH>;
    use P5getnetbyname:ver<0.0.4>:auth<cpan:ELIZABETH>;
    use P5getpriority;
    use P5getprotobyname:ver<0.0.3>:auth<cpan:ELIZABETH>;
    use P5getpwnam:ver<0.0.5>:auth<cpan:ELIZABETH>;
    use P5getservbyname:ver<0.0.4>:auth<cpan:ELIZABETH>;
    use P5hex;
    use P5index;
    use P5lc;
    use P5lcfirst;
    use P5length;
    use P5localtime:ver<0.0.6>:auth<cpan:ELIZABETH>;
    use P5math;
    use P5opendir:ver<0.0.4>:auth<cpan:ELIZABETH>;
    use P5pack;
    use P5print;
    use P5push;
    use P5quotemeta;
    use P5readlink;
    use P5ref;
    use P5reset;
    use P5reverse;
    use P5seek;
    use P5shift;
    use P5sleep;
    use P5study;
    use P5substr;
    use P5tie;
    use P5times:ver<0.0.6>:auth<cpan:ELIZABETH>;
    use P5-X;

    # there must be a better way to do this, but this will work for now
    %export = MY::.keys.grep( *.starts-with('&') ).map: { $_ => ::($_) };
}

multi sub EXPORT() { %export }
multi sub EXPORT(*@args) {
    my $imports := Map.new( |(%export{ @args.map: '&' ~ * }:p) );
    if $imports != @args {
        die "P5built-ins doesn't know how to export: "
          ~ @args.grep( { !$imports{$_} } ).join(', ')
    }
    $imports
}

=begin pod

=head1 NAME

P5built-ins - Implement Perl 5's built-in functions

=head1 SYNOPSIS

  use P5built-ins;   # import all P5 built-in functions supported

  use P5built-ins <tie untie>;  # only import specific ones

  tie my @a, Foo;

=head1 DESCRIPTION

This module provides an easy way to import a growing number of built-in
functions of Perl 5 in Perl 6.  Currently supported at:

  abs caller chdir chomp chop chr closedir cos crypt defined each endgrent
  endnetent endprotoent endpwent endservent exp fc fileno getgrent getgrgid
  getgrnam getlogin getnetbyaddr getnetbyname getnetent getpgrp getppid
  getpriority getprotobyname getprotobynumber getprotoent getpwent getpwnam
  getpwuid getservbyname getservbyport getservent gmtime hex index int lc
  lcfirst length localtime log oct opendir ord pack pop print printf push
  quotemeta rand readdir readlink ref reset reverse rewinddir rindex say
  seek seekdir setgrent setnetent setpriority setprotoent setpwent setservent
  shift sin sleep sqrt study substr telldir tie tied times uc ucfirst undef
  unpack unshift untie

The following file test operators are also available:

  -r -w -x -e -f -d -s -z -l

And the following terms:

  __FILE__ __LINE__ __PACKAGE__ __SUB__ SEEK_CUR SEEK_END SEEK_SET
  STDERR STDIN STDOUT

=head1 PORTING CAVEATS

Please look at the porting caveats of the underlying modules that actually
provide the functionality:

  module        | built-in functions
  --------------+-------------------
  P5caller      | caller
  P5chdir       | chdir
  P5defined     | defined undef
  P5each        | each
  P5fileno      | fileno
  P5getpriority | getpriority setpriority getppid getpgrp
  P5length      | length
  P5localtime   | localtime gmtime
  P5math        | abs cos crypt exp int log rand sin sqrt
  P5opendir     | opendir readdir telldir seekdir rewinddir closedir
  P5pack        | pack unpack
  P5print       | print printf say
  P5readlink    | readlink
  P5ref         | ref
  P5reset       | reset
  P5reverse     | reverse
  P5study       | study
  P5tie         | tie, tied, untie
  P5times       | times
  P5-X          | -r -w -x -e -f -d -s -z -l

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5built-ins . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018-2019 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
