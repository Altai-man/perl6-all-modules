
use v6;
use lib <blib/lib lib>;

use Test;


my $abort = False;
if ($Sum::libcrypto::up) {
    plan 32;
}
else {
    plan 3;
    $abort = True;
}

use Sum::libcrypto;

ok(1,'We use Sum::libcrypto and we are still alive');

lives-ok { X::libcrypto::NotFound.new() },
	 'X::libcrypto::NotFound is available';
lives-ok { X::libcrypto::NativeError.new() },
	 'X::libcrypto::NativeError is available';

if $abort {
   diag "No libcrypto detected, or other very basic problem.  Skipping tests.";
   exit;
}

# Should at least have MD5
my $md5 = %Sum::libcrypto::Algos<md5>;
isa-ok $md5, Sum::libcrypto::Algo, "Found an Algo named md5";
is $md5.size, 16, "MD5 has expected digest size";

my $a;
lives-ok {$a := Sum::libcrypto::Instance.new("sha1")}, "crypto init lives.";
isa-ok $a, Sum::libcrypto::Instance, "Created Instance object";
ok $a.defined, "Created Instance is really instantiated";
lives-ok {$a.add("Please to checksum this text".encode('ascii'))}, "crypto update lives";
my $b;
lives-ok {$b := $a.clone;}, "libcrypto copy_ex (clone) lives.";
isa-ok $b, Sum::libcrypto::Instance, "Clone is Instance object";
ok $b.defined, "Cloned Instance is really instantiated";
is $b.finalize, buf8.new(0x20,0x27,0x60,0x55,0x24,0x6b,0x17,0xa6,0xb9,0x3a,0x12,0xf0,0x4c,0x24,0xf9,0x36,0x28,0xda,0x4e,0xe4), "SHA1 clone computes expected value";
lives-ok {$a.add(buf8.new('.'.ord))}, "mhash update of original lives";
is $a.finalize(), buf8.new(0x72,0xb,0xfb,0x85,0xdd,0x7a,5,0xb,0x66,0x7d,0xc1,0x58,0x9a,0xa3,0x69,2,0xee,0xd3,0x65,0x21), "OriginalSHA1 alg computes expected value";
throws-like { $a.finalize() }, X::Sum::Final, "Double finalize gets caught for raw Instance";
lives-ok { for 0..10000 { my $a := Sum::libcrypto::Instance.new("sha1"); $a.finalize() if Bool.pick; } }, "Supposedly test GC sanity";

lives-ok {$a := Sum::libcrypto::Sum.new("md5")}, "wrapper class contructor lives";
isa-ok $a, Sum::libcrypto::Sum, "wrapper class intantiates";
ok $a.defined, "wrapper class intantiates for reelz";
lives-ok {$a.push(buf8.new(97 xx 64))}, "wrapper class can push";
lives-ok {$b := $a.clone}, "wrapper class clone lives";
isa-ok $b, Sum::libcrypto::Sum, "wrapper clone typecheck";
ok $b.defined, "wrapper clone definedness";
is +$a.finalize, 0x014842d480b571495a4a0363793f7367, "MD5 is correct (test vector 1).";
is +$a.finalize, 0x014842d480b571495a4a0363793f7367, "Wrapper class caches result";
my $res;
lives-ok {$b.push(buf8.new(97 xx 64))}, "wrapper clone can push";
lives-ok { $res  = $b.finalize(buf8.new(97 xx 56)) }, "finalize also pushes";
is +$res, 0x63642b027ee89938c922722650f2eb9b, "MD5 is correct (test vector 2).";
is (+Sum::libcrypto::Sum.new("md5").finalize()), 0xd41d8cd98f00b204e9800998ecf8427e, "wrapper class works with no addend ever pushed";
is (+Sum::libcrypto::Sum.new("md5").finalize(buf8.new())), 0xd41d8cd98f00b204e9800998ecf8427e, "wrapper class works with just empty buffer finalized";

class sayer {
    has $.accum is rw = "";
    method print (*@s) { $.accum ~= [~] @s }
}
my sayer $p .= new();
# Rakudo-p currently does not serialize $=pod in PIR compunits so skip this.
if ($*VM.name ne 'parrot') {
{ temp $*OUT = $p; EVAL $Sum::libcrypto::Doc::synopsis; }
is $p.accum, $Sum::libcrypto::Doc::synopsis.comb(/<.after \x23\s> (<.ws> <.xdigit>+)+/).join("\n") ~ "\n", 'Code in manpage synopsis actually works';
}
