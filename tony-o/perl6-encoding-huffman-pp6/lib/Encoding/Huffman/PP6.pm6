unit module Encoding::Huffman::PP6;

my %huffman-http2 = 
  "{0}" => "1111111111000",
  "{1}" => "11111111111111111011000",
  "{2}" => "1111111111111111111111100010",
  "{3}" => "1111111111111111111111100011",
  "{4}" => "1111111111111111111111100100",
  "{5}" => "1111111111111111111111100101",
  "{6}" => "1111111111111111111111100110",
  "{7}" => "1111111111111111111111100111",
  "{8}" => "1111111111111111111111101000",
  "{9}" => "111111111111111111101010",
  "{10}" => "111111111111111111111111111100",
  "{11}" => "1111111111111111111111101001",
  "{12}" => "1111111111111111111111101010",
  "{13}" => "111111111111111111111111111101",
  "{14}" => "1111111111111111111111101011",
  "{15}" => "1111111111111111111111101100",
  "{16}" => "1111111111111111111111101101",
  "{17}" => "1111111111111111111111101110",
  "{18}" => "1111111111111111111111101111",
  "{19}" => "1111111111111111111111110000",
  "{20}" => "1111111111111111111111110001",
  "{21}" => "1111111111111111111111110010",
  "{22}" => "111111111111111111111111111110",
  "{23}" => "1111111111111111111111110011",
  "{24}" => "1111111111111111111111110100",
  "{25}" => "1111111111111111111111110101",
  "{26}" => "1111111111111111111111110110",
  "{27}" => "1111111111111111111111110111",
  "{28}" => "1111111111111111111111111000",
  "{29}" => "1111111111111111111111111001",
  "{30}" => "1111111111111111111111111010",
  "{31}" => "1111111111111111111111111011",
  "{32}" => "010100",
  "{33}" => "1111111000",
  "{34}" => "1111111001",
  "{35}" => "111111111010",
  "{36}" => "1111111111001",
  "{37}" => "010101",
  "{38}" => "11111000",
  "{39}" => "11111111010",
  "{40}" => "1111111010",
  "{41}" => "1111111011",
  "{42}" => "11111001",
  "{43}" => "11111111011",
  "{44}" => "11111010",
  "{45}" => "010110",
  "{46}" => "010111",
  "{47}" => "011000",
  "{48}" => "00000",
  "{49}" => "00001",
  "{50}" => "00010",
  "{51}" => "011001",
  "{52}" => "011010",
  "{53}" => "011011",
  "{54}" => "011100",
  "{55}" => "011101",
  "{56}" => "011110",
  "{57}" => "011111",
  "{58}" => "1011100",
  "{59}" => "11111011",
  "{60}" => "111111111111100",
  "{61}" => "100000",
  "{62}" => "111111111011",
  "{63}" => "1111111100",
  "{64}" => "1111111111010",
  "{65}" => "100001",
  "{66}" => "1011101",
  "{67}" => "1011110",
  "{68}" => "1011111",
  "{69}" => "1100000",
  "{70}" => "1100001",
  "{71}" => "1100010",
  "{72}" => "1100011",
  "{73}" => "1100100",
  "{74}" => "1100101",
  "{75}" => "1100110",
  "{76}" => "1100111",
  "{77}" => "1101000",
  "{78}" => "1101001",
  "{79}" => "1101010",
  "{80}" => "1101011",
  "{81}" => "1101100",
  "{82}" => "1101101",
  "{83}" => "1101110",
  "{84}" => "1101111",
  "{85}" => "1110000",
  "{86}" => "1110001",
  "{87}" => "1110010",
  "{88}" => "11111100",
  "{89}" => "1110011",
  "{90}" => "11111101",
  "{91}" => "1111111111011",
  "{92}" => "1111111111111110000",
  "{93}" => "1111111111100",
  "{94}" => "11111111111100",
  "{95}" => "100010",
  "{96}" => "111111111111101",
  "{97}" => "00011",
  "{98}" => "100011",
  "{99}" => "00100",
  "{100}" => "100100",
  "{101}" => "00101",
  "{102}" => "100101",
  "{103}" => "100110",
  "{104}" => "100111",
  "{105}" => "00110",
  "{106}" => "1110100",
  "{107}" => "1110101",
  "{108}" => "101000",
  "{109}" => "101001",
  "{110}" => "101010",
  "{111}" => "00111",
  "{112}" => "101011",
  "{113}" => "1110110",
  "{114}" => "101100",
  "{115}" => "01000",
  "{116}" => "01001",
  "{117}" => "101101",
  "{118}" => "1110111",
  "{119}" => "1111000",
  "{120}" => "1111001",
  "{121}" => "1111010",
  "{122}" => "1111011",
  "{123}" => "111111111111110",
  "{124}" => "11111111100",
  "{125}" => "11111111111101",
  "{126}" => "1111111111101",
  "{127}" => "1111111111111111111111111100",
  "{128}" => "11111111111111100110",
  "{129}" => "1111111111111111010010",
  "{130}" => "11111111111111100111",
  "{131}" => "11111111111111101000",
  "{132}" => "1111111111111111010011",
  "{133}" => "1111111111111111010100",
  "{134}" => "1111111111111111010101",
  "{135}" => "11111111111111111011001",
  "{136}" => "1111111111111111010110",
  "{137}" => "11111111111111111011010",
  "{138}" => "11111111111111111011011",
  "{139}" => "11111111111111111011100",
  "{140}" => "11111111111111111011101",
  "{141}" => "11111111111111111011110",
  "{142}" => "111111111111111111101011",
  "{143}" => "11111111111111111011111",
  "{144}" => "111111111111111111101100",
  "{145}" => "111111111111111111101101",
  "{146}" => "1111111111111111010111",
  "{147}" => "11111111111111111100000",
  "{148}" => "111111111111111111101110",
  "{149}" => "11111111111111111100001",
  "{150}" => "11111111111111111100010",
  "{151}" => "11111111111111111100011",
  "{152}" => "11111111111111111100100",
  "{153}" => "111111111111111011100",
  "{154}" => "1111111111111111011000",
  "{155}" => "11111111111111111100101",
  "{156}" => "1111111111111111011001",
  "{157}" => "11111111111111111100110",
  "{158}" => "11111111111111111100111",
  "{159}" => "111111111111111111101111",
  "{160}" => "1111111111111111011010",
  "{161}" => "111111111111111011101",
  "{162}" => "11111111111111101001",
  "{163}" => "1111111111111111011011",
  "{164}" => "1111111111111111011100",
  "{165}" => "11111111111111111101000",
  "{166}" => "11111111111111111101001",
  "{167}" => "111111111111111011110",
  "{168}" => "11111111111111111101010",
  "{169}" => "1111111111111111011101",
  "{170}" => "1111111111111111011110",
  "{171}" => "111111111111111111110000",
  "{172}" => "111111111111111011111",
  "{173}" => "1111111111111111011111",
  "{174}" => "11111111111111111101011",
  "{175}" => "11111111111111111101100",
  "{176}" => "111111111111111100000",
  "{177}" => "111111111111111100001",
  "{178}" => "1111111111111111100000",
  "{179}" => "111111111111111100010",
  "{180}" => "11111111111111111101101",
  "{181}" => "1111111111111111100001",
  "{182}" => "11111111111111111101110",
  "{183}" => "11111111111111111101111",
  "{184}" => "11111111111111101010",
  "{185}" => "1111111111111111100010",
  "{186}" => "1111111111111111100011",
  "{187}" => "1111111111111111100100",
  "{188}" => "11111111111111111110000",
  "{189}" => "1111111111111111100101",
  "{190}" => "1111111111111111100110",
  "{191}" => "11111111111111111110001",
  "{192}" => "11111111111111111111100000",
  "{193}" => "11111111111111111111100001",
  "{194}" => "11111111111111101011",
  "{195}" => "1111111111111110001",
  "{196}" => "1111111111111111100111",
  "{197}" => "11111111111111111110010",
  "{198}" => "1111111111111111101000",
  "{199}" => "1111111111111111111101100",
  "{200}" => "11111111111111111111100010",
  "{201}" => "11111111111111111111100011",
  "{202}" => "11111111111111111111100100",
  "{203}" => "111111111111111111111011110",
  "{204}" => "111111111111111111111011111",
  "{205}" => "11111111111111111111100101",
  "{206}" => "111111111111111111110001",
  "{207}" => "1111111111111111111101101",
  "{208}" => "1111111111111110010",
  "{209}" => "111111111111111100011",
  "{210}" => "11111111111111111111100110",
  "{211}" => "111111111111111111111100000",
  "{212}" => "111111111111111111111100001",
  "{213}" => "11111111111111111111100111",
  "{214}" => "111111111111111111111100010",
  "{215}" => "111111111111111111110010",
  "{216}" => "111111111111111100100",
  "{217}" => "111111111111111100101",
  "{218}" => "11111111111111111111101000",
  "{219}" => "11111111111111111111101001",
  "{220}" => "1111111111111111111111111101",
  "{221}" => "111111111111111111111100011",
  "{222}" => "111111111111111111111100100",
  "{223}" => "111111111111111111111100101",
  "{224}" => "11111111111111101100",
  "{225}" => "111111111111111111110011",
  "{226}" => "11111111111111101101",
  "{227}" => "111111111111111100110",
  "{228}" => "1111111111111111101001",
  "{229}" => "111111111111111100111",
  "{230}" => "111111111111111101000",
  "{231}" => "11111111111111111110011",
  "{232}" => "1111111111111111101010",
  "{233}" => "1111111111111111101011",
  "{234}" => "1111111111111111111101110",
  "{235}" => "1111111111111111111101111",
  "{236}" => "111111111111111111110100",
  "{237}" => "111111111111111111110101",
  "{238}" => "11111111111111111111101010",
  "{239}" => "11111111111111111110100",
  "{240}" => "11111111111111111111101011",
  "{241}" => "111111111111111111111100110",
  "{242}" => "11111111111111111111101100",
  "{243}" => "11111111111111111111101101",
  "{244}" => "111111111111111111111100111",
  "{245}" => "111111111111111111111101000",
  "{246}" => "111111111111111111111101001",
  "{247}" => "111111111111111111111101010",
  "{248}" => "111111111111111111111101011",
  "{249}" => "1111111111111111111111111110",
  "{250}" => "111111111111111111111101100",
  "{251}" => "111111111111111111111101101",
  "{252}" => "111111111111111111111101110",
  "{253}" => "111111111111111111111101111",
  "{254}" => "111111111111111111111110000",
  "{255}" => "11111111111111111111101110",
  "_eos" => "111111111111111111111111111111",
;

sub huffman-encode(Str $s, %codes = %huffman-http2) is export {
  my     $bits = $s.comb.map({ %codes{$_}.Str }).join('');
  my Buf[uint8] $enc .=new((0..($bits.codes/8).ceiling).map({ 0 }));
  my Int $i    = 0;
  for ($bits.comb, %codes<_eos>.comb).flat -> $c {
    $enc[($i / 8).floor] +|= do given $i mod 8 {
      when 0 { 0x80 };
      when 1 { 0x40 };
      when 2 { 0x20 };
      when 3 { 0x10 };
      when 4 { 0x08 };
      when 5 { 0x04 };
      when 6 { 0x02 };
      when 7 { 0x01 };
    } if $c eq '1';
    $i++;
  }
  return $enc;
}

sub huffman-decode(Buf[uint8] $s, %codes = %huffman-http2) is export {
  my Str $r = '';
  my Str $a = '';
  my %a = %codes.keys.map({ %codes{$_} => $_; });
  for $s.map({ .base(2).Str.comb }) -> @i {
    for ((@i.elems == 8 ?? [] !! 0..(7-@i.elems)).map({'0'}), |@i).flat -> $c {
      $a ~= $c;
      next unless %a{$a}.defined;
      last if %a{$a} eq '_eos';
      $r ~= try {%a{$a}.chr} // %a{$a};
      $a  = '';
    }
  }
  return $r;
}

# vi:syntax=perl6
