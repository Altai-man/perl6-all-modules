use Test;

# Language 'ru' class
plan 70;

my $lang = 'ru';

use Date::Names;

my $dn;

# these data are auto-generated:
# non-empty data set arrays
my @dow  = <понедельник вторник среда четверг пятница суббота воскресенье>;
my @dow2 = <Пн Вт Ср Чт Пт Сб Вс>;
my @mon  = <январь февраль март апрель май июнь июль август сентябрь октябрь ноябрь декабрь>;
my @mon3 = <янв фев мар апр май июн июл авг сен окт ноя дек>;
my @sets = <dow dow2 mon mon3>;

for @sets -> $n {
    my $ne = $n ~~ /^d/ ?? 7 !! 12;
    my @v = @::($n); # <== interpolated from $n

    my $is-dow;
    if $ne == 7 {
        $dn = Date::Names.new: :$lang, :dset($n);
        $is-dow = 1;
    }
    else {
        $dn = Date::Names.new: :$lang, :mset($n);
        $is-dow = 0;
    }

    # test the class construction
    isa-ok $dn, Date::Names;
    # test class methods (6)
    can-ok $dn, 'nsets';
    can-ok $dn, 'sets';
    can-ok $dn, 'show';
    can-ok $dn, 'show-all';
    can-ok $dn, 'dow';
    can-ok $dn, 'mon';
    # test the data array
    is @v.elems, $ne;

    # test the main methods for return values
    for 1..$ne -> $d {
        my $val = @v[$d-1];
        if $is-dow {
            is $dn.dow($d), $val;
        }
        else {
            is $dn.mon($d), $val;
        }
    }
}
