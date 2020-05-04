#!/usr/bin/env perl
#
# take a contain an return a 32bit key and more
#
use Digest::MurmurHash qw(); # Austin Appleby (Murmur 32-bit)
printf "--- # %s\n",$0;
my $key=shift;
if (-e $key) {
 local *F; open F,'<',$key;
 local $/ = undef; $key = <F>; close F;
}
my $mu = Digest::MurmurHash::murmur_hash($key);
printf "mu: %u\n",$mu;

my $gitbin = &githash($key);
my $gitid = unpack('H*',$gitbin);
printf "gitid: %s\n",$gitid;
my $id7 = substr($gitid,0,7);
printf "id7: %s\n",$id7;

my $md5 = &digest('MD5',$key);
printf "md5: %s\n",unpack('H*',$md5);
my $sha1 = &digest('SHA1',$key);
printf "sha1: %s\n",unpack('H*',$sha1);
my $sha2 = &digest('SHA-256',$key);
my $qm58 = &encode_base58("\x01\x55\x12\x20",$sha2);
printf "qm58: z%s\n",$qm58;
my $md6bin = &digest('MD6',$key);
my $md6 = unpack('H*',$md6bin);
printf "md6: %s\n",$md6;



my $nu = hex($id7);
my $pn = hex(substr($md6,-4)); # 16-bit
printf "pn: %s\n",$pn;
my $word = &word($pn);
printf "word: %s\n",$word;
my $n2 = sprintf "%09u",$nu; $n2 =~ s/(....)/\1_/;
printf "n2: %s\n",$n2;


exit $?;


# ---------------------------------------------------------
sub githash {
 use Digest::SHA1 qw();
 my $msg = Digest::SHA1->new() or die $!;
    $msg->add(sprintf "blob %u\0",(lstat(F))[7]);
    $msg->add(@_);
 my $digest = $msg->digest();
 return $digest; # binay form !
}
# ---------------------------------------------------------
sub digest ($@) {
 my $alg = shift;
 my $header = undef;
 my $text = shift;
 use Digest qw();
 if ($alg eq 'GIT') {
   $header = sprintf "blob %u\0",length($text);
   $alg = 'SHA-1';
 }
 my $msg = Digest->new($alg) or die $!;
    $msg->add($header) if $header;
    $msg->add($text);
 my $digest = $msg->digest();
 return $digest; #binary form !
}
# ---------------------------------------------------------
sub encode_base58 { # btc
  use Math::BigInt;
  use Encode::Base58::BigInt qw();
  my $bin = join'',@_;
  my $bint = Math::BigInt->from_bytes($bin);
  my $h58 = Encode::Base58::BigInt::encode_base58($bint);
  $h58 =~ tr/a-km-zA-HJ-NP-Z/A-HJ-NP-Za-km-z/;
  return $h58;
}
# ---------------------------------------------------------
sub word { # 20^4 * 6^3 words (25bit worth of data ...)
 my $n = $_[0];
 my $vo = [qw ( a e i o u y )]; # 6
 my $cs = [qw ( b c d f g h j k l m n p q r s t v w x z )]; # 20
 my $str = '';
 while ($n >= 20) {
   my $c = $n % 20;
      $n /= 20;
      $str .= $cs->[$c];
   my $c = $n % 6;
      $n /= 6;
      $str .= $vo->[$c];
 }
 $str .= $cs->[$n];
 return $str;	
}
# ---------------------------------------------------------
1; # $Source: /my/perl/scripts/contkey.pl $
