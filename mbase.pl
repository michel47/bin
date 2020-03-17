#!/usr/bin/perl


# see [*](https://github.com/multiformats/multibase)
use lib $ENV{SITE}.'/lib';
use UTIL qw(hex2quint decode_base58 decode_base32 encode_base10 encode_base63 encode_base64m encode_base64u encode_base32 encode_base32z encode_base58 encode_base58f);

my $dec;
if ($ARGV[0] eq '-d') {
 $dec++;
} 

local $/ = undef;
my $buf = <STDIN>;
local $/ = "\n";
chomp $buf;

my $bin = '';
if ($dec) {
   if ($buf =~ m/^Qm/) {
      $cidv = 0;
      $mhash = &decode_base58($buf);
      $bin = pack('H*','0170'). &decode_base58($buf);
   } elsif ($buf =~ m/^z/) { # decode multiformat ...
      $cidv = 1;
      $bin = &decode_base58(substr($buf,1));
      $mhash = substr($bin,2);
   } elsif ($buf =~ m/^b/i) {
      $bin = &decode_base32(substr($buf,1));
      $cidv = unpack'C',substr($bin,0,1);
      $mhash = ($cidv == 1) ? substr($bin,2) : $bin;
   } elsif ($buf =~ m/^f/i) {
      $bin = pack('H*',substr($buf,1));
      $cidv = unpack'C',substr($bin,0,1);
      $mhash = ($cidv == 1) ? substr($bin,2) : $bin;
   } elsif ($buf =~ m/^([um])/i) {
      $buf =~ tr{-_}{+/} if ($1 eq 'u');
      $bin = &decode_base64m(substr($buf,1));
      $cidv = unpack'C',substr($bin,0,1);
      $mhash = ($cidv == 1) ? substr($bin,2) : $bin;
   } else {
      $bin = &decode_base58($buf);
      $cidv = unpack'C',substr($bin,0,1);
      $mhash = ($cidv == 1) ? substr($bin,2) : $bin;
   }
} else {
   $bin = $buf;
   $cidv = unpack'C',substr($bin,0,1);
   $mhash = ($cidv == 1) ? substr($bin,2) : $bin;
}

my $qm = &encode_base58($mhash);
my $quint = &hex2quint(unpack'H*',$mhash);
my $b16 = unpack'H*',$bin;
my $b10 = &encode_base10($bin);
my $b32 = &encode_base32($bin);
my $b32z = &encode_base32z($bin);
my $b58 = &encode_base58($bin);
my $b58f = &encode_base58f($bin);
my $b63 = &encode_base63($bin);
my $b64m = &encode_base64m($bin); $b64m =~ tr /=//d;
my $b64u = &encode_base64u($bin); $b64u =~ tr /=//d;

print "--- # other encoding for z.$qm\n";
printf "qm: %s\n",$qm;
printf "quint: %s\n",$quint;
printf "b10: 9%s\n",$b10;
printf "b16: f%s\n",$b16;
printf "b32: B%s\n",$b32;
printf "b32z: h%s\n",lc$b32z;
printf "b58: z%s\n",$b58;
printf "b58f: Z%s\n",$b58f;
printf "b63l: l%s\n",$b63;
printf "b64m: m%s\n",$b64m;
printf "b64u: u%s\n",$b64u;
print "...\n";

