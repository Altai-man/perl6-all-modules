use v6.c;
unit module Lingua::Stopwords::DE;

sub get-list ( Str $list = 'snowball' --> SetHash ) is export {
    
    my SetHash $stop-words .= new;
    
    given $list {
        when 'all' {
            $stop-words = <  aber alle allem allen aller alles als also am an ander andere anderem anderen anderer anderes anderm andern anderr anders auch auf 
                            aus bei bin bis bist da dadurch daher damit dann darum das dass dasselbe dazu daß dein deine deinem deinen deiner deines dem 
                            demselben den denn denselben der derer derselbe derselben des deshalb desselben dessen dich die dies diese dieselbe dieselben 
                            diesem diesen dieser dieses dir doch dort du durch ein eine einem einen einer eines einig einige einigem einigen einiger einiges 
                            einmal er es etwas euch euer eure eurem euren eurer eures für gegen gewesen hab habe haben hat hatte hatten hattest hattet hier 
                            hin hinter ich ihm ihn ihnen ihr ihre ihrem ihren ihrer ihres im in indem ins ist ja jede jedem jeden jeder jedes jene jenem jenen 
                            jener jenes jetzt kann kannst kein keine keinem keinen keiner keines können könnt könnte machen man manche manchem manchen mancher 
                            manches mein meine meinem meinen meiner meines mich mir mit muss musst musste muß mußt müssen müßt nach nachdem nein nicht nichts 
                            noch nun nur ob oder ohne sehr seid sein seine seinem seinen seiner seines selbst sich sie sind so solche solchem solchen solcher 
                            solches soll sollen sollst sollt sollte sondern sonst soweit sowie um und uns unse unsem unsen unser unsere unses unter viel vom 
                            von vor wann war waren warst warum was weg weil weiter weitere welche welchem welchen welcher welches wenn wer werde werden werdet 
                            weshalb wie wieder wieso will wir wird wirst wo woher wohin wollen wollte während würde würden zu zum zur zwar zwischen über >.SetHash;
        }
        when 'ranks-nl' {
            $stop-words = <  aber als am an auch auf aus bei bin bis bist da dadurch daher darum das daß dass dein deine dem den der des dessen deshalb die 
                            dies dieser dieses doch dort du durch ein eine einem einen einer eines er es euer eure für hatte hatten hattest hattet hier hinter 
                            ich ihr ihre im in ist ja jede jedem jeden jeder jedes jener jenes jetzt kann kannst können könnt machen mein meine mit muß mußt 
                            musst müssen müßt nach nachdem nein nicht nun oder seid sein seine sich sie sind soll sollen sollst sollt sonst soweit sowie und 
                            unser unsere unter vom von vor wann warum was weiter weitere wenn wer werde werden werdet weshalb wie wieder wieso wir wird wirst 
                            wo woher wohin zu zum zur über >.SetHash;
        }
        when 'snowball' {
            $stop-words = <  aber alle allem allen aller alles als also am an ander andere anderem anderen anderer anderes anderm andern anderr anders auch auf 
                            aus bei bin bis bist da damit dann der den des dem die das daß derselbe derselben denselben desselben demselben dieselbe dieselben 
                            dasselbe dazu dein deine deinem deinen deiner deines denn derer dessen dich dir du dies diese diesem diesen dieser dieses doch 
                            dort durch ein eine einem einen einer eines einig einige einigem einigen einiger einiges einmal er ihn ihm es etwas euer eure 
                            eurem euren eurer eures für gegen gewesen hab habe haben hat hatte hatten hier hin hinter ich mich mir ihr ihre ihrem ihren ihrer 
                            ihres euch im in indem ins ist jede jedem jeden jeder jedes jene jenem jenen jener jenes jetzt kann kein keine keinem keinen 
                            keiner keines können könnte machen man manche manchem manchen mancher manches mein meine meinem meinen meiner meines mit muss 
                            musste nach nicht nichts noch nun nur ob oder ohne sehr sein seine seinem seinen seiner seines selbst sich sie ihnen sind so 
                            solche solchem solchen solcher solches soll sollte sondern sonst über um und uns unse unsem unsen unser unses unter viel vom von 
                            vor während war waren warst was weg weil weiter welche welchem welchen welcher welches wenn werde werden wie wieder will wir wird 
                            wirst wo wollen wollte würde würden zu zum zur zwar zwischen >.SetHash;
        }
        default {
            fail "Invalid type of list: $list.";
        }
    }

    return $stop-words;
}