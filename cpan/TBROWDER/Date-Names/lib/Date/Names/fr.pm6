unit module Date::Names::fr;

#********
# <name of your language in its native script>
# French
#********

# IMPORTANT:
#
# All valid month and weekday name and abbreviation arrays must have
# either twelve (12) or seven (7) elements, respectively.  Arrays
# without month or day values MUST be completely empty as are the ones
# shown below.

# Note the standard eight arrays should exist in the file (see Table 2
# in the README for the correct names). They may be empty, but there
# should be eight (8) total arrays.

# To be an acceptable language for Date::Names, there must be defined completely
# at least one of the standard abbreviation sets for both months and weekdays
# in order to provide a default abbreviation set for the user in the
# event another abbreviation set is desired but not available.

#=== FULL NAMES ======================================================
# 1
constant $mon = <
     janvier     février   mars       avril
     mai         juin      juillet    août
     septembre   octobre   novembre   décembre
>;

# 2
constant $dow = <
     lundi     mardi   mercredi  jeudi
     vendredi  samedi  dimanche
>;

#=== THREE-LETTER ABBREVIATIONS ======================================
# 3
constant $mon3 = <
>;

# 4
constant $dow3 = <
    lun  mar  mer  jeu
    ver  sam  dim
>;

#=== TWO-LETTER ABBREVIATIONS ========================================
# 5
constant $mon2 = <
    JR  FR  MS  AL
    MI  JN  JT  AT
    SE  OE  NE  DE
>;

# 6
constant $dow2 = <
>;

#=== MIXED-LENGTH ABBREVIATIONS ======================================
# 7
constant $mona = <
    # abbreviations "courante"
    janv févr mars  avr
    mai  juin juill août
    sept oct  nov   déc
>;

# 8
constant $dowa = <
    # abbreviations "courante"
    lundi mardi mercr jeudi
    vendr sam   dim
>;
