unit module CucumisSextus::Gherkin;

use X::CucumisSextus::FeatureParseFailure;
use CucumisSextus::Tags;
use CucumisSextus::I18n;

class File {
    has $.filename is rw;
    has @.lines is rw;
}

class Feature {
    has $.name is rw;
    has @.scenarios is rw;
    has $.background is rw;
    has @.tags is rw;
    has $.file is rw;
    has $.line-from is rw;
    has $.line-to is rw;
}

class Scenario {
    has $.name is rw;
    has @.steps is rw;
    has @.tags is rw;
    has @.examples is rw;
    has $.line-from is rw;
    has $.line-to is rw;
}

class Step {
    has $.verb is rw;
    has $.text is rw;
    has @.table is rw;
    has $.multiline is rw;
    has $.line-from is rw;
    has $.line-to is rw;
}

sub parse-feature-file($filename) is export {
    my $lang = 'en';
    my $feature;
    my $scenario;
    my $step;
    my $current;
    my $last-verb;
    my @tags;
    my @column-header;
    my $in-examples;
    my $is-outline;
    my $in-multiline;
    my $multiline-prefix;

    # XXX tags are madness: https://github.com/cucumber/cucumber/wiki/Tags
    # XXX description lines for features and scenarios

    my $file = File.new;
    $file.lines.push(""); # because we index from 1 as file lines are typically seen that way
    $file.filename = $filename;

    my $line-number = 1;
    for $filename.IO.lines {
        $file.lines.push($_);

        if m/^ \s* '#' \s* 'language:' \s+ (\S+)/ {
            if $line-number == 1 {
                if defined $gherkin-keywords{$0} {
                    $lang = $0;
                }
                else {
                    die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                        ~ "at $filename:$line-number: language '$0' not supported");
                }
            }
            else {
                die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                    ~ "at $filename:$line-number: language directive, but not on first line");
            }
        }
        elsif m/^ (\s*) '"""' \s* $/ {
            if ($in-multiline) {
                $in-multiline = False;
            }
            else {
                # XXX can't happen everywhere, also conflicts with table
                $multiline-prefix = $0;
                $in-multiline = True;
            }
        }
        elsif $in-multiline {
            # XXX explicitely writing $_ is weird?
            if $_.starts-with($multiline-prefix) {
                if $step.multiline {
                    $step.multiline ~= "\n";
                }
                $step.multiline ~= $_.substr($multiline-prefix.chars);
            }
            else {
                die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                    ~ "at $filename:$line-number: inconsistent indentation in multiline string");
            }
        }
        elsif m/^ \s* $/ {
            # blank line
            # XXX clear some state
        }
        elsif m/^ \s* '#'/ {
            # comment, ignore
        }
        elsif my @ctags = parse-tags($_) {
            # tags, add to list
            # XXX tags mess up from-line/to-line
            # XXX surely tags can't happen just anywhere...
            @tags.append(@ctags);
        }
        # XXX all over the place: space after colon single, multiple, optional?
        elsif m/^ <{ $gherkin-keywords{$lang}{'feature'} }> ':' \s* (.+) $/ {
            if ! defined $feature {
                $feature = Feature.new;
                $feature.file = $file;
                $feature.name = ~$0;
                $feature.tags = @tags;
                $feature.line-from = $line-number;
                $current = $feature;
                @tags = ();
            }
            else {
                die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                    ~ "at $filename:$line-number: multiple features per file");
            }
        }
        elsif m/^ \s* <{ $gherkin-keywords{$lang}{'scenario-outline'} }> ':' \s* (.+) $/ {
            # XXX very-similar to the below, refactor
            if defined $feature {
                # XXX end previous step
                $scenario = Scenario.new;
                $scenario.name = ~$0;
                $scenario.tags = @tags;
                $scenario.line-from = $line-number;
                if $current {
                    $current.line-to = $line-number - 1;
                }
                $current = $scenario;
                $feature.scenarios.push($scenario);

                $last-verb = Nil;
                $in-examples = False;
                $is-outline = True;
                @column-header = ();
            }
            else {
                die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                    ~ "at $filename:$line-number: scenario definition without feature");
            }
        }
        elsif m/^ \s* <{ $gherkin-keywords{$lang}{'scenario'} }> ':' \s* (.+) $/ {
            if defined $feature {
                # XXX end previous step
                $scenario = Scenario.new;
                $scenario.name = ~$0;
                $scenario.tags = @tags;
                $scenario.line-from = $line-number;
                if $current {
                    $current.line-to = $line-number - 1;
                }
                $current = $scenario;
                $feature.scenarios.push($scenario);

                $last-verb = Nil;
                $in-examples = False;
                $is-outline = False;
                @column-header = ();
            }
            else {
                die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                    ~ "at $filename:$line-number: scenario definition without feature");
            }
        }
        elsif m/^ \s* <{ $gherkin-keywords{$lang}{'background'} }> ':' \s* (.+) $/ {
            if defined $feature {
                if $feature.background {
                    die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                        ~ "at $filename:$line-number: multiple background scenarios for feature");
                }
                if $feature.scenarios {
                    die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                        ~ "at $filename:$line-number: background scenario after regular scenario");
                }

                $scenario = Scenario.new;
                $scenario.name = ~$0;
                $scenario.tags = @tags;
                $scenario.line-from = $line-number;
                if $current {
                    $current.line-to = $line-number - 1;
                }
                $current = $scenario;
                $feature.background = $scenario;

                $last-verb = Nil;
            }
            else {
                die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                    ~ "at $filename:$line-number: background definition without feature");
            }
        }
        elsif m/^ \s* <{ $gherkin-keywords{$lang}{'given'} }> \s* (.+) $/ {
            my $verb = 'given';
            $step = Step.new;
            $step.verb = $verb;
            $step.text = $0;
            $step.line-from = $line-number;
            if $current {
                $current.line-to = $line-number - 1;
            }
            $current = $step;
            $scenario.steps.push($step);
            $last-verb = $verb;
        }
        elsif m/^ \s* <{ $gherkin-keywords{$lang}{'when'} }> \s* (.+) $/ {
            my $verb = 'when';
            $step = Step.new;
            $step.verb = $verb;
            $step.text = $0;
            $step.line-from = $line-number;
            if $current {
                $current.line-to = $line-number - 1;
            }
            $current = $step;
            $scenario.steps.push($step);
            $last-verb = $verb;
        }
        elsif m/^ \s* <{ $gherkin-keywords{$lang}{'then'} }> \s* (.+) $/ {
            my $verb = 'then';
            $step = Step.new;
            $step.verb = $verb;
            $step.text = $0;
            $step.line-from = $line-number;
            if $current {
                $current.line-to = $line-number - 1;
            }
            $current = $step;
            $scenario.steps.push($step);
            $last-verb = $verb;
        }
        elsif m/^ \s* (   <{ $gherkin-keywords{$lang}{'and'} }>
                        | <{ $gherkin-keywords{$lang}{'but'} }> )
                            \s* (.+) $/ {

            if ! defined $last-verb {
                die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                    ~ "at $filename:$line-number: 'and'/'but' steps may not appear first in a "
                    ~ "scenario");
            }
            my $verb = $last-verb;
            $step = Step.new;
            $step.verb = $verb;
            $step.text = $1;
            $step.line-from = $line-number;
            if $current {
                $current.line-to = $line-number - 1;
            }
            $current = $step;
            $scenario.steps.push($step);
        }
        elsif m/^ \s* <{ $gherkin-keywords{$lang}{'examples'} }> \s* (.+) $/ {
            $in-examples = True;
            if $current {
                $current.line-to = $line-number - 1;
            }
            $current = Nil;
        }
        elsif m/^ \s* \| (.*) \| \s* $/ {
            # XXX when can this occur?
            my @fields = $0.trim.split('|')>>.trim;
            if @column-header {
                if @fields.elems != @column-header.elems {
                    die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                        ~ "at $filename:$line-number: inconsistent number of columns across table");
                }
                my %hash = @column-header Z=> @fields;
                if $in-examples {
                    $scenario.examples.push(%hash);
                }
                else {
                    $step.table.push(%hash);
                }
            }
            else {
                @column-header = @fields;
            }
        }
        else {
            # XXX line not understood, complain
        }
        $line-number++;
    }
    if $current {
        $current.line-to = $line-number;
    }
    $file.lines.push(""); # final line to make output easier
    return $feature;
}
