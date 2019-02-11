use v6;

use Test;
use Perl6::Parser;

# The terms that get tested here are:
#
# enum <name> "foo"
# subset <name> of Type
# constant <name> = 1

plan 2 * 3;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;
my ( $source, $tree );

# Classes, modules, packages &c can no longer be redeclared.
# Which is probably a good thing, but plays havoc with testing here.
#
# This is a little ol' tool that generates a fresh package name every time
# through the testing suite. I can't just make up new names as the test suite
# goes along because I'm running the full test suite twice, once with the
# original Perl6 parser-aided version, and once with the new regex-based parser.
#
# Use it to build out package names and such.
#
sub gensym-package( Str $code ) {
	state $appendix = 'A';
	my $package = 'Foo' ~ $appendix++;

	return sprintf $code, $package;
}

for ( True, False ) -> $*PURE-PERL {
	subtest {
		plan 2;

		subtest {
			plan 4;

			$source = gensym-package Q:to[_END_];
			enum %s()
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			enum %s     ()
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{enum %s()  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{enum %s     ()  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{no intrabrace spacing};

		subtest {
			plan 4;

			$source = gensym-package Q:to[_END_];
			enum %s(   )
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			enum %s     (   )
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{enum %s(   )  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{enum %s     (   )  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{intrabrace spacing};
	}, Q{enum};

	subtest {
		plan 2;

		subtest {
			plan 2;

			$source = gensym-package Q:to[_END_];
			subset %s of Int
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q{subset %s of Int  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};
		}, Q{Normal version};

		$source = gensym-package Q:to[_END_];
		unit subset %s;
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{unit form};
	}, Q{subset};

	subtest {
		plan 5;

		$source = Q:to[_END_];
		constant Foo=1
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		constant Foo     =1
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q:to[_END_];
		constant Foo=   1
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{intermediate ws};

		$source = Q:to[_END_];
		constant Foo     =   1
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{intermediate ws};

		$source = Q{constant Foo=1     };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};
	}, Q{constant};
}

# vim: ft=perl6
