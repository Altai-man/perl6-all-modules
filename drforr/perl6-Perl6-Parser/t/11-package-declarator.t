use v6;

use Test;
use Perl6::Parser;

# The terms that get tested here are:

# package <name> { }
# module <name> { }
# class <name> { }
# grammar <name> { }
# role <name> { }
# knowhow <name> { }
# native <name> { }
# also is <name>
# trusts <name>
#
# class Foo { also is Int } # 'also' is a package_declaration.
# class Foo { trusts Int } # 'trusts' is a package_declaration.

# These terms either are invalid or need additional support structures.
# I'll add them momentarily...
#
# lang <name>

plan 11;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;
my $*INTERNAL-PARSER = True;
my ( $source, $tree );

subtest {
	plan 3;

	subtest {
		plan 4;

		subtest {
			$source = Q{package Foo{}};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $tree.child[0].child[3].child[0] ~~
				Perl6::Block::Enter, Q{enter brace};
			ok $tree.child[0].child[3].child[1] ~~
				Perl6::Block::Exit, Q{exit brace};

			done-testing;
		}, Q{no ws};

		$source = Q:to[_END_];
		package Foo     {}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{package Foo{}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{package Foo     {}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q{package Foo{   }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		package Foo     {   }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{package Foo{   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{package Foo     {   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		$source = Q{unit package Foo;};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		unit package Foo  ;
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{ws before semi};
	}, Q{unit form};
}, Q{package};

subtest {
	plan 3;

	subtest {
		plan 4;

		$source = Q{module Foo{}};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		module Foo     {}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{module Foo{}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{module Foo     {}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q{module Foo{   }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		module Foo     {   }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{module Foo{   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{module Foo     {   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		$source = Q{unit module Foo;};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		unit module Foo;
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{ws};
	}, Q{unit form};
}, Q{module};

subtest {
	plan 3;

	subtest {
		plan 4;

		$source = Q{class Foo{}};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		class Foo     {}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{class Foo{}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{class Foo     {}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q{class Foo{   }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		class Foo     {   }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{class Foo{   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{class Foo     {   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		$source = Q{unit class Foo;};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		unit class Foo;
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{ws};
	}, Q{unit form};
}, Q{class};

subtest {
	plan 2;

	$source = Q{class Foo{also is Int}};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	class Foo{also     is   Int}
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{class Foo also is};

subtest {
	plan 2;

	# space between 'Int' and {} is required
	$source = Q{class Foo is Int {}};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	class Foo is Int {}
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{class Foo is};

subtest {
	plan 4;

	$source = Q{class Foo is repr('CStruct'){has int8$i}};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	class Foo is repr('CStruct'){has int8$i}
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};

	$source = Q:to[_END_];
	class Foo is repr('CStruct') { has int8 $i }
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{more ws};

	$source = Q:to[_END_];
	class Foo is repr( 'CStruct' ) { has int8 $i }
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{even more ws};
}, Q{class Foo is repr()};

subtest {
	plan 2;

	# space between 'Int' and {} is required
	$source = Q{class Foo{trusts Int}};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	class Foo { trusts Int }
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{class Foo trusts};

subtest {
	plan 3;

	subtest {
		plan 4;

		$source = Q{grammar Foo{}};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		grammar Foo     {}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{grammar Foo{}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{grammar Foo     {}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q{grammar Foo{   }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		grammar Foo     {   }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{grammar Foo{   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{grammar Foo     {   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		$source = Q{unit grammar Foo;};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		unit grammar Foo;
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{ws};
	}, Q{unit form};
}, Q{grammar};

subtest {
	plan 3;

	subtest {
		plan 4;

		$source = Q{role Foo{}};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		role Foo     {}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{role Foo{}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{role Foo     {}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q{role Foo{   }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		role Foo     {   }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{role Foo{   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{role Foo     {   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		$source = Q{unit role Foo;};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		unit role Foo;
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source,  Q{ws};
	}, Q{unit form};
}, Q{role};

subtest {
	plan 3;

	subtest {
		plan 4;

		$source = Q{knowhow Foo{}};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		knowhow Foo     {}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{knowhow Foo{}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{knowhow Foo     {}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q{knowhow Foo{   }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		knowhow Foo     {   }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{knowhow Foo{   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{knowhow Foo     {   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		$source = Q{unit knowhow Foo;};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		unit knowhow Foo;
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{ws};
	}, Q{unit form};
}, Q{knowhow};

subtest {
	plan 3;

	subtest {
		plan 4;

		$source = Q{native Foo{}};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		native Foo     {}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{native Foo{}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{native Foo     {}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q{native Foo{   }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		native Foo     {   }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{native Foo{   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{native Foo     {   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		$source = Q{unit native Foo;};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		unit native Foo;
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{ws};
	}, Q{unit form};
}, Q{native};

# XXX 'lang Foo{}' illegal
# XXX 'unit lang Foo;' illegal

# vim: ft=perl6
