#!/usr/bin/perl

# intent:
#  find a nonce such a file has it's gitid matching a pattern
#
# usage:
#  perl -S vani36.pl file pat

use Crypt::Digest qw();
use Digest::SHA1 qw();
use Math::BigInt;
use Math::Base36 qw();

my $i = 1;
my $nonce = '$nonce: ~$';
my $mod = 1000;
my $logf = "vani36-$$.log";
local *LOG; open LOG,'>>',$logf;
my $h = select(LOG); $| = 1; select($h);

my $n0 = 24 * 234 *($^T%3600);
my $n = $n0;

my $next = $n + $mod;

my $time = $^T-1;
my $file = shift;
local $| = 1;
# pat: 'EMPTY|\dREMOV|C[PO]\d*(?:BRI?NG|Q?GIT\d|NULL|GE?NE?S?\d)'
my $pat = shift; $pat = qr($pat);
printf "file: %s\n",$file;
printf "pat: %s\n",$pat;
printf "n: %s\n",$n;

my $content = &get_filecontent($file);
my $p = index($content,'$nonce: ');
my $q = index($content,'$',$p+1);
my $begin = substr($content,0,$p+8);
my $end = substr($content,$q);
printf qq'begin: "%s"\n',&nonl($begin,0,64);
printf "end: %s\n",&nonl($end,0,64);
my $len = length($begin) + length($end);
while (1) {
   my $nonce = &basen($n,63);
   #printf "content: %s\n",$content; die;
   my $ns =  sprintf "blob %u\0",$len + length($nonce);
   my $msg = Crypt::Digest->new('SHA1') or die $!;
   #my $msg = Digest::SHA1->new() or die $!;
      $msg->add($ns,$begin,$nonce,$end);
   my $gitid = $msg->digest();
   my $git36 = &encode_base36("\x00\x78\x11\x14".$gitid);

   if ($git36 =~ m/$pat/o) {
      printf LOG "n: %6u; git36: K%s (nonce: %s) file: %s\n",$n,$git36,$nonce,$file;
      printf "n: %6u; git36: K%s (nonce: %s) *\n",$n,$git36,$nonce;
      printf "git16: f%s\n",unpack'H*',$gitid;
   } elsif ($n == $next ) {
      my $now = time;
      my $elaps = $now - $^T + 1;
      my $delta = $now - $time;
      if ($delta > 7) { $mod--; } elsif ($delta < 7) { $mod++; }
      $next += $mod;
      my $c = substr($git36,5,1);
      if (! $seen{$c}++) {
        printf "n: %6u; git36: k%s (mod: %d %.2fm %.1fhps %ds) %s! %u\n",$n,lc$git36,$mod,$elaps/60,($n-$n0)/$elaps,$delta,$c,$i++;
      } else {
         printf "n: %6u; git36: k%s (mod: %d %.2fm %.1fhps %ds)\r",$n,lc$git36,$mod,$elaps/60,($n-$n0)/$elaps,$delta;
      }
      $time = $now;
   #} else {
   #   my $elaps = time - $^T;
   #   printf "n: %6u; git36: k%s (mod: %d %.2fm %ds)\r",$n,lc$git36,$mod,$elaps/60,$delta;
   }
   $n++;
}

close LOG;
exit $?;

# -----------------------------------------------------
sub basen { # int -> str, radix <= 43; 
  use integer;
  my ($n,$radix) = @_;
  my $e = '';
  return('0') if $n == 0;
  while ( $n ) {
    my $c = $n % $radix;
    $e .=  chr(0x30 + $c); # 0x30: 0 included
    $n = int $n / $radix;
  }
  if ($radix <= 35) {
     $e =~ y/0-R/A-Z1-9/
  } elsif ($radix <= 40) {
     $e =~ y/0-W/0-9a-z\-_.!/
  } elsif ($radix <= 43) {
     $e =~ y/0-Z/0-9A-Z+\-$.% */;
  } elsif ($radix <= 58) {
    $e =~ y/0-i/1-9A-HJ-NP-Za-km-z/;
  } elsif ($radix <= 64) {
    $e =~ y,0-o,0-9A-Za-z\-_,;
  }
  return scalar reverse $e;
}
# -----------------------------------------------------
sub get_filecontent {
  my $file = shift; local *F; open F,'<',$file;
  local $/ = undef;
  my $buf = <F>;
  close F;
  return $buf;
}
# -----------------------------------------------------
sub hash { # non-keyed hash
   my $msg = Crypt::Digest->new($_[0]) or die $!;
      $msg->add($_[1]);
   return $msg->digest();
}
# -----------------------------------------------------
sub encode_base36 {
  my $n = Math::BigInt->from_bytes(shift);
  my $k36 = Math::Base36::encode_base36($n,@_);
  #$k36 =~ y,0-9A-Z,A-Z0-9,;
  return $k36;
}
# -----------------------------------------------------
sub nonl {
  my $buf = shift;
  $buf =~ s/\\n/\\\\n/g;
  $buf =~ s/\n/\\n/g;
  if (defined $_[1]) {
   $buf = substr($buf,$_[0],$_[1]);
  }
  return $buf;
}

1; # $Source: /my/perl/scripts/vani36.pl $
