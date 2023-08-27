#!/usr/bin/perl

#understand variable=value on the command line...
eval "\$$1='$2'"while @ARGV&&$ARGV[0] =~ /^(\w+)=(.*)/ && shift;

my $qmhash;
my $data;
if ($ARGV[0] =~ m/^Qm/) {
  $qmhash = shift;
  $data = &decode_base58($qmhash);
} else {
  local $/ = undef;
  $buf = <>;
  $data = &mhash($buf); # TBD
  $qmhash = &encode_base58b($data);
  printf "size: %dc\n",length($data);
  printf "qm: %s\n",$qmhash;
}

my $size = length($data);
my $maxcolor = 0;
for my $c (unpack'C*',$data) {
  $maxcolor = $c if ($c > $maxcolor);
}
my $bpc = int log(2*$maxcolor - 1) / log(2);
$maxcolor = (1<<$bpc) - 1;

my $pi = atan2(0,-1);
my $iratio = $ratio || $pi; # x/y
my $xy = $size/3;
my $sqx = sqrt($xy);
my $x = int( $xy / $sqx + 0.5);
my $y = int( ($xy + $x - 1) / $x );
($x,$y) = ($x > $y) ? ($x,$y) : ($y,$x); # landscape !
printf "z: %s, xy: %s, √xy: %s, y: %s, %sx%s\n",$size,$xy,$sqx,$xy/int($sqx+0.49999),$x,$y;
my $n = $x*$y*3;
my $delta = $n - $size;
if ($delta < 0) {
   $x++;
   $n = $x*$y*3;
   $delta = $n - $size;
}
my $pad = "\x00" x $delta;
my $hdr = <<"EOS";
P6
$x $y
$maxcolor
EOS

my $of = sprintf "%s.png",substr($qmhash,0,9);
local *PPM; open PPM,"| convert -compress LZW -strip -quality 90 ppm:- -magnify -magnify -magnify -magnify $of";
print PPM $hdr;
binmode(PPM);
print PPM $data;
print PPM $pad;
close PPM;

exit $?;


# -----------------------------------------------------------------------
sub mhash {
  my $buf = shift;
  my $size = length($buf);
  my $hash = &khash('SHA256',substr($buf,0,512),pack'N',$size); # external hash...
  #printf "hash: %s\n",unpack'H*',$hash;
  my $mhash = pack('H8','01701220').$hash;
  printf "mhash: %s\n",unpack'H*',$mhash;
  return $mhash;
}
# -----------------------------------------------------------------------
sub khash { # keyed hash
   use Crypt::Digest qw();
   my $alg = shift;
   my $data = join'',@_;
   my $msg = Crypt::Digest->new($alg) or die $!;
      $msg->add($data);
   my $hash = $msg->digest();
   return $hash;
}
# -----------------------------------------------------------------------
sub encode_base58b {
  use Math::BigInt;
  use Encode::Base58::BigInt qw();
  my $bin = join'',@_;
  my $bint = Math::BigInt->from_bytes($bin);
  my $h58 = Encode::Base58::BigInt::encode_base58($bint);
  $h58 =~ tr/a-km-zA-HJ-NP-Z/A-HJ-NP-Za-km-z/; # btc
  return $h58;
}
sub decode_base58 {
  use Carp qw(cluck);
  use Math::BigInt;
  use Encode::Base58::BigInt qw();
  my $s = $_[0];
  if ($s =~ m/^Qm/) {
    $s =~ tr/A-HJ-NP-Za-km-zIO0l/a-km-zA-HJ-NP-ZiooL/; # btc
  }
  #$s =~ tr/IO0l/iooL/; # forbidden chars
  #printf "s: %s\n",unpack'H*',$s;
  my $bint = Encode::Base58::BigInt::decode_base58($s) or warn "$s: $!";
  cluck "error decoding $s!" unless $bint;
  my $bin = Math::BigInt->new($bint)->as_bytes();
  return $bin;
}



1;
