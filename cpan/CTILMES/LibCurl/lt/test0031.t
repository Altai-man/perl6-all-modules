use v6;

use Test;

use LibCurl::Test;
use LibCurl::Easy;

plan 1;

my $cookiejar will leave { unlink $_ } = "cookiejar";

my $server = LibCurl::Test.new;

$server.start;

my $curl = LibCurl::Easy.new(URL => "http://$HOSTIP:$HTTPPORT/we/want/31",
                             cookiefile => 'none', cookiejar => $cookiejar)
    .perform.cleanup;

is $cookiejar.IO.slurp,
qq<# Netscape HTTP Cookie File
# http://curl.haxx.se/docs/http-cookies.html
# This file was generated by libcurl! Edit at your own risk.

127.0.0.1	FALSE	/silly/	FALSE	0	ismatch	this
127.0.0.1	FALSE	/overwrite	FALSE	0	overwrite	this2
127.0.0.1	FALSE	/secure1/	TRUE	0	sec1value	secure1
127.0.0.1	FALSE	/secure2/	TRUE	0	sec2value	secure2
127.0.0.1	FALSE	/secure3/	TRUE	0	sec3value	secure3
127.0.0.1	FALSE	/secure4/	TRUE	0	sec4value	secure4
127.0.0.1	FALSE	/secure5/	TRUE	0	sec5value	secure5
127.0.0.1	FALSE	/secure6/	TRUE	0	sec6value	secure6
127.0.0.1	FALSE	/secure7/	TRUE	0	sec7value	secure7
127.0.0.1	FALSE	/secure8/	TRUE	0	sec8value	secure8
127.0.0.1	FALSE	/secure9/	TRUE	0	secure	very1
#HttpOnly_127.0.0.1	FALSE	/p1/	FALSE	0	httpo1	value1
#HttpOnly_127.0.0.1	FALSE	/p2/	FALSE	0	httpo2	value2
#HttpOnly_127.0.0.1	FALSE	/p3/	FALSE	0	httpo3	value3
#HttpOnly_127.0.0.1	FALSE	/p4/	FALSE	0	httpo4	value4
#HttpOnly_127.0.0.1	FALSE	/p4/	FALSE	0	httponly	myvalue1
#HttpOnly_127.0.0.1	FALSE	/p4/	TRUE	0	httpandsec	myvalue2
#HttpOnly_127.0.0.1	FALSE	/p4/	TRUE	0	httpandsec2	myvalue3
#HttpOnly_127.0.0.1	FALSE	/p4/	TRUE	0	httpandsec3	myvalue4
#HttpOnly_127.0.0.1	FALSE	/p4/	TRUE	0	httpandsec4	myvalue5
#HttpOnly_127.0.0.1	FALSE	/p4/	TRUE	0	httpandsec5	myvalue6
#HttpOnly_127.0.0.1	FALSE	/p4/	TRUE	0	httpandsec6	myvalue7
#HttpOnly_127.0.0.1	FALSE	/p4/	TRUE	0	httpandsec7	myvalue8
#HttpOnly_127.0.0.1	FALSE	/p4/	TRUE	0	httpandsec8	myvalue9
127.0.0.1	FALSE	/	FALSE	0	partmatch	present
127.0.0.1	FALSE	/we/want/	FALSE	2054030187	nodomain	value
#HttpOnly_127.0.0.1	FALSE	/silly/	FALSE	0	magic	yessir
127.0.0.1	FALSE	/we/want/	FALSE	0	blexp	yesyes
127.0.0.1	FALSE	/we/want/	FALSE	0	withspaces	yes  within and around
127.0.0.1	FALSE	/we/want/	FALSE	0	withspaces2	
127.0.0.1	FALSE	/we/want/	FALSE	0	prespace	yes before
127.0.0.1	FALSE	/we/want/	TRUE	0	securewithspace	after
>, 'correct cookiejar';

done-testing;
