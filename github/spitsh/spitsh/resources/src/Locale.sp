#| A (probably tempoary) palce to put locale related functions
class Locale {
    #| Gets the encoding the current terminal is using.
    #|{
    if Local.encoding eq 'UTF-8' {
        say "\c[GHOST] \c[RIGHT-TO-LEFT OVERRIDE] \c[GHOST] llehs ni eht koops a";
    }}
    static method encoding~ on {
        UNIXish { ${locale 'charmap'} }
        # No way of checking. The docker alpine image has utf8 by default so
        # we're just gonna roll with it for now
        Alpine { 'UTF-8' }
    }
}
