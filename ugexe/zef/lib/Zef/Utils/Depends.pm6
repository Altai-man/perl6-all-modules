# todo: refactor/move to Zef::Roles::
class Zef::Utils::Depends {
    has @.projects;

    # A poor attempt to parse module names from source code
    grammar Grammar::Dependency::Parser {
        token TOP { [[^^ || \s+] <load-statement>]+ .*? $$ }

        token load-statement { <load-type> \s+ <short-name>               }
        token short-name     { <name-piece> [<.colon-pair> <name-piece>]* }
        token name-piece     { <.name-token>+       }
        token name-token     { <+[\S] -restricted>  }
        token restricted     { < : ; { } [ ] ( ) . , = + / \ ] $ @ % ! ^ & * ~ # ` | ? > || '<' || '>' }
        token colon-pair     { '::' }

        proto token load-type {*}
        token load-type:sym<use>     { <sym> }
        token load-type:sym<need>    { <sym> }
        token load-type:sym<require> { <sym> }
    }

    # Modified from:
    # http://rosettacode.org/wiki/Topological_sort/Extracted_top_item#Perl_6
    method topological-sort (*@wanted, *%fields) {
        %fields<depends> = True unless %fields.elems;
        my @top = @wanted.flat.list.map({ $_.<name> });
        my %deps;

        # Handle where provides has 2+ package names mapped to the same path
        # todo: don't do the unique call on every iteration
        for @!projects -> $meta {
            for %fields.kv -> $k, $v {
                %deps{$meta.<name>} .= push($_) for $meta.{$k}.list;
                %deps{$meta.<name>} = [%deps{$meta.<name>}.list.grep(*.so).unique];
            }
        }

        my %ba;
        for %deps.kv -> $after, $befores {
            for $befores.list -> $before {
                %ba{$after}{$before} = 0 if $before ne $after;
                %ba{$before} //= {};
            }
            %ba{$after} //= {};
        }

        if @top {
            my @want = @top;
            my %care;
            %care{@want} = 1 xx *;
            repeat while @want {
                my @newwant;
                for @want -> $before {
                    if %ba{$before} {
                        for %ba{$before}.keys -> $after {
                            if not %ba{$before}{$after} {
                                %ba{$before}{$after}++;
                                push @newwant, $after;
                            }
                        }
                    }
                }
                @want = @newwant;
                %care{@want} = 1 xx *;
            }
         

            for %ba.keys {
               %ba{$_}:delete unless %care{$_}:exists;
            }
        }


        # XXX redo after GLR
        my @levels = gather {
            loop {
                my @befores = %ba.grep( not *.value ).map({ $_.key });
                last unless @befores.elems;
                take [@befores];
                for @befores -> $k {
                    %ba{$k}:delete;
                    for %ba.values { .{$k}:delete }
                }
            }
        }

        return @levels;
    }

    # Determine build order for a CompUnitRepo's provides by parsing the source
    method extract-deps(*@paths) {
        my @pm-files = @paths.grep(*.IO.f).grep({ $_.IO.basename ~~ / \.pm6? $/ });
        my $slash    = / [ \/ | '\\' ]  /;
        my @skip     = <v6 MONKEY-TYPING MONKEY_TYPING strict fatal nqp NativeCall cur lib Test>;

        my @minimeta = gather for @pm-files -> $f is copy {
            my @depends;
            for $f.IO.slurp.lines -> $line {
                state Int $pod-block;
                my $code-only = do given $line {
                    # remove pod
                    $pod-block-- and next when /^^ \s* '=' 'end' [\s || $$]/;
                    $pod-block++ and next when /^^ \s* '=' 'begin' [\s || $$]/;
                    next when /^^ \s* '=' \w/;
                    next if $pod-block;

                    # remove comments (broken; too naive)
                    # but keep non-commented part of line
                    when /^^ $<pre-comment>=[.*?] '#'/ {
                        $/<pre-comment>.Str ;
                    }

                    default { $_ }
                }

                # Only bother parsing if the line has enough chars for a `use *`
                next unless $code-only.chars > 5;

                my $dep-parser = Grammar::Dependency::Parser.parse($code-only);
                my @deps = $dep-parser.<load-statement>.list.grep(*.so)\
                    .grep({ $_.<short-name>.Str ~~ none(@skip) })\
                    .map({ $_.<short-name>.Str });

                @depends.push($(@deps));
            }

            my $file-path = $f.IO.path;

            take { path => $file-path, name => $file-path, depends => @depends }
        }

        return @minimeta;
    }

    # Not used currently. May be used to parse dependencies from an exception message.
    method runtime-extract-deps(*@paths is copy) {
        #use Perl6::Grammar:from<NQP>; # prevents compile on jvm
        #use Perl6::Actions:from<NQP>;

        @paths //= @!projects.grep({ $_.<file> });
        my @pm6-files := @paths.grep(*.IO.f).grep({ $_.IO.basename ~~ / \.pm6? $/ });

        # Try to parse exceptions for missing dependencies
        my @missing = gather for @pm6-files -> $source {
            try {
                my $*LINEPOSCACHE;            
                Perl6::Grammar.parse($source.IO.slurp, :actions(Perl6::Actions.new()));

                CATCH { 
                    when X::AdHoc {
                        if $_.payload ~~ /'Could not find'\s$<missing>=(.*?)\s'in any of:'/ {
                            take ~$/.<missing>;
                            # Inject fake dependency or find another way
                            # to continue on and parse more dependencies 
                            # as only one module name is shown per exception.
                        }
                    }
                }
            }
        }
    }
}


sub runtime-extract-deps(*@paths) is export {
    Zef::Utils::Depends.new.runtime-extract-deps(@paths);
}

sub extract-deps(*@paths) is export {
    Zef::Utils::Depends.new.extract-deps(@paths);
}

sub build-dep-tree(*@projects, :$target) is export {
    Zef::Utils::Depends.new(:@projects).build-dep-tree(:$target);    
}

sub topological-sort(*@projects, :$target) is export {
    Zef::Utils::Depends.new(:@projects).topological-sort(:$target);    
}