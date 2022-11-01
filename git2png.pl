#!/usr/bin/perl

#understand variable=value on the command line...
eval "\$$1='$2'"while @ARGV&&$ARGV[0] =~ /^(\w+)=(.*)/ && shift;

my $gitid;
my $gitid_raw;
if ($ARGV[0] =~ m/^[0-9a-f]+$/) {
  $gitid = shift;
  $gitid_raw = pack'H*',$gitid;
} else {
  local $/ = undef;
  $buf = <>;
  my $ns =  sprintf "blob %u\0",length($buf);
  $gitid_raw = &digest('SHA1',$ns,$buf);
  $gitid = unpack'H*',$gitid_raw;
}

sub digest ($@) {
 my $alg = shift;
 my $ns = (scalar @_ >= 2) ? shift : undef;
 use Crypt::Digest qw();
 my $msg = Crypt::Digest->new($alg) or die $!;
    $msg->add($ns) if defined $ns;
    $msg->add(join'',@_);
 my $digest = $msg->digest();
 return $digest; #bin form !
}


my $size = length($gitid_raw);
my $maxcolor = 0;
for my $c (unpack'C*',$gitid_raw) {
  $maxcolor = $c if ($c > $maxcolor);
}
my $bpc = int log(2*$maxcolor - 1) / log(2);
$maxcolor = (1<<$bpc) - 1;

my $pi = atan2(0,-1);
my $iratio = $ratio || $pi; # x/y
my $xy = $size/3;
my $sqx = sqrt($xy);
my $x = int( $xy / $sqx + 0.5);
my $y = int( ( $xy + $x - 1) / $x );
my $x = int( ( $xy + $y + 1) / $y );
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

my $of = sprintf "%s.png",substr($gitid,0,7);
local *PPM; open PPM,"| convert -compress LZW -strip -quality 90 ppm:- -magnify -magnify -magnify -magnify $of";
print PPM $hdr;
binmode(PPM);
print PPM $gitid_raw;
print PPM $pad;
close PPM;

exit $?;
