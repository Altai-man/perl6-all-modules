use v6;

use PDF::Grammar;

grammar PDF::Grammar::Content::Fast
    is PDF::Grammar {
    # Manually optimised version of PDF::Grammar::Content. Also
    # more forgiving; doesn't enforce text or marked content blocks
    rule TOP {^ [<op=.instruction>||<op=.unknown>]* $}

    proto rule instruction {*}
    rule instruction:sym<op>    {<op>}
    rule instruction:sym<block> {<block>}

    # image blocks BI ... ID ... EI
    rule opBeginImage          { (BI) }
    token opImageData          { (ID)[\n|' '|<.comment>]* }
    token opEndImage           { (EI) }

    proto rule block {*}
    rule imageDict { [<name> <object>]* }
    rule block:sym<image> {
                      <opBeginImage>
                      <imageDict>
                      [  $<start>=<opImageData>.*?$<end>=[\n|' ']<opEndImage>
                      || $<start>=<opImageData>.*?$<end>=<opEndImage>] # more forgiving fallback
    }

    proto rule ignored {*}
    rule ignored:sym<guff>  { <guff> }
    rule ignored:sym<char>  { . }

    # ------------------------
    # Operators and Objects
    # ------------------------

    proto rule op {*}
    rule op:sym<unary>  { (b\*?|B[T|X|\*]?|E[MC|T|X]|F|f\*?|h|n|s|S|W\*?|T\*|Q|q) }
    rule op:sym<num>    { <number> [ (G|g|i|M|Tc|T[L|s|w|z]|w)
                                   | <number> [ (d0|l|m|Td|TD)
                                              | <string> (\")
                                              | <number> [ (rg|RG)
                                                         | <number> [ (k|K|re|v|y)
                                                                    | <number> <number> (c|cm|d1|Tm) ] ] ] ] }
    rule op:sym<name>   { <name> [ (BMC|cs|CS|Do|gs|MP|ri|sh)
                                 | [<name> | <dict>] (BDC|DP)
                                 | <number> (Tf) ]}
    rule op:sym<int>    { <int> (J|j|Tr) }
    rule op:sym<obj>    { <object>+ (scn?|SCN?) }
    rule op:sym<string> { <string> (Tj|\') }
    rule op:sym<array>  { <array> [ (TJ) | <number> (d) ] }

    # catchall for unknown opcodes and arguments
    token guff    { <[a..zA..Z\*\"\']><[\w\*\"\']>* }
    rule unknown  { <object> || <guff> } 
}
