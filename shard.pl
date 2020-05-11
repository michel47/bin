#!/usr/bin/env perl
#
# take a content and return a 32bit key and more
#
use Digest::MurmurHash qw(); # Austin Appleby (Murmur 32-bit)
our $dbug=0;
#--------------------------------
# -- Options parsing ...
#
my $all = 0;
my $_shard = 1 if (!@ARGV || $ARGV[0] !~ m/^-/);

while (@ARGV && $ARGV[0] =~ m/^-/) {
  $_ = shift;
  #/^-(l|r|i|s)(\d+)/ && (eval "\$$1 = \$2", next);
  if (/^-a(?:ll)?/) { $all= 1; }
  elsif (/^-y(?:ml)?/) { $yaml= 1; }
  elsif (/^-s(?:hard)?/) { $_shard= 1; }
  elsif (/^-qm(?:58)?/) { $_qm= 1; }
  elsif (/^-zb2?/) { $_zb58= 1; }
  elsif (/^-c(?:iq)?/) { $_ciq= 1; }
  elsif (/^-b(?:afy)?/) { $_bafy= 1; }
  elsif (/^-m(?:u)?/) { $_mu= 1; }
  elsif (/^-g(?:it)?/) { $_git= 1; }
  elsif (/^-(?:i(?:d)?|7)/) { $_id7= 1; }
  elsif (/^-(?:m(?:d6)?|6)/) { $_md6= 1; }
  elsif (/^-(?:m(?:d)?|5)/) { $_md5= 1; }
  elsif (/^-(?:n2|2)/) { $_n2= 1; }
  elsif (/^-p(?:n)?/) { $_pn= 1; }
  elsif (/^-w(?:ord)?/) { $_word= 1; }
  elsif (/^-l(?:oc)?/) { $_loc= 1; }
  else                  { die "Unrecognized switch: $_\n"; }

}
#--------------------------------
#understand variable=value on the command line...
eval "\$$1='$2'"while $ARGV[0] =~ /^(\w+)=(.*)/ && shift;

my $content=shift;
my $loc='stdin';
if (-e $content) {
 $loc=$content;
 local *F; open F,'<',$content;
 local $/ = undef; $content = <F>; close F;
}
my $mu = Digest::MurmurHash::murmur_hash($content);

my $qmhash = &qmhash('SHA256',$content);
my $qm = &encode_base58($qmhash);
my $ciq = &encode_base32($qmhash);
my $shard = substr($ciq,-3,2);
my $qm58 = &encode_base58($qmhash);
my $bafy = &encode_base32("\x01\x70".$qmhash);
my $gitbin = &githash($content);
my $gitid = unpack('H*',$gitbin);
my $id7 = substr($gitid,0,7);

my $md5 = unpack'H*',&digest('MD5',$content);
my $sha1 = &digest('SHA1',$content);
my $sha2 = &digest('SHA-256',$content);
my $zb58 = &encode_base58("\x01\x55\x12\x20",$sha2);
my $md6bin = &digest('MD6',$content);
my $md6 = unpack('H*',$md6bin);


my $nu = hex($id7);
my $pn = hex(substr($md6,-4)); # 16-bit
my $word = &word($pn);
my $n2 = sprintf "%09u",$nu; $n2 =~ s/(....)/\1_/;

printf "--- # %s\n",$0 if ($yaml);

if ($yaml || $all) {
printf "shard: %s\n",$shard;
printf "qm: %s\n",$qm;
printf "ciq: %s\n",$ciq;
printf "bafy: B%s\n",$bafy;
printf "mu: %u\n",$mu;
printf "gitid: %s\n",$gitid;
printf "id7: %s\n",$id7;
printf "md5: %s\n",unpack('H*',$md5);
printf "sha1: %s\n",unpack('H*',$sha1);
printf "zb58: z%s\n",$zb58;
printf "md6: %s\n",$md6;
printf "pn: %s\n",$pn;
printf "word: %s\n",$word;
printf "n2: %s\n",$n2;
printf "loc: %s\n",$loc;
} else {
  my @res = ();
  push @res, $shard if $_shard;
  push @res, $mu if $_mu;
  push @res, $gitid if $_git;
  push @res, $id7 if $_id7;
  push @res, $md5 if $_md5;
  push @res, $sha1 if $_sha1;
  push @res, $zb58 if $_zb58;
  push @res, $qm if $_qm58;
  push @res, $ciq if $_ciq;
  push @res, $bafy if $_bafy;
  push @res, $md6 if $_md6;
  push @res, $pn if $_pn;
  push @res, $word if $_word;
  push @res, $n2 if $_n2;

  my $sep = (scalar@res > 2) ? ', ' : ' - ';
  print join$sep,@res;

}

exit $?;


sub store {
   my ($addr,$data) = @_;
   # adding file to the repository
   my $mh32 = uc&encode_base32($mhash);
   if (exists $ENV{IPFS_PATH}) {
      my $split = substr($mh32,-3,2);
      my $objfile = sprintf '%s/blocks/%s/%s.data',$ENV{IPFS_PATH},$split,$mh32;
      if (! -e $objfile) { # create the record ... i.e. it is like adding it to IPFS !
         printf "%s created !\n",$objfile if $dbug;
         local *F; open F,'>',$objfile; binmode(F);
         print F $data; close F;
      } else {
         printf "-e %s\n",$objfile if $dbug;
      }
   }
   my $cid = &encode_base58($addr);
   return $cid;
}
# ---------------------------------------------------------
# protobuf container :
#   f1=id: t0=varint
#   f2=data: t2=string
sub qmhash {
   my $algo = shift;
   my $msg = shift;
   my $msize = length($msg);
   my $mhfncode = { 'SHA256' => 0x12, 'SHA1' => 0x11, 'MD5' => 0xd5, 'ID' => 0x00};
   my $mhfnsize = { 'SHA256' => 256, 'GIT' => 160, 'MD5' => 128};
   
   #printf "msize: %u (%s)\n",$msize,unpack'H*',&varint($msize);
   printf "msg: %s%s\n",substr(&enc($msg),0,76),(length($msg)>76)?'...':'' if $dbug;
   # QmPa5thw8vNXH7eZqcFX8j4cCkGokfQgnvbvJw88iMJDVJ
   # 00000000: 0a0e 0802 1208 6865 6c6c 6f20 210a 1808  ......hello !...
   # {"Links":[],"Data":"\u0008\u0002\u0012\u0008hello !\n\u0018\u0008"}
   # 0000_1010 : f1.t2 size=14 (0a0e)
   # payload: 0802_1208 ... 1808
   #          0000_1000 : f1.t0 varint=2 (0802)
   #          0001_0010 : f2.t2 size=8 ... (1208 ...)
   #          0001_1000 : f3.t0 varint=8 (1808)
   my $payload = sprintf '%s%s',pack('C',(1<<3|0)),&varint(2);
   $payload .= sprintf '%s%s%s',pack('C',(2<<3|2)),&varint($msize),$msg;

   $payload .= sprintf '%s%s',pack('C',(3<<3|0)),&varint($msize);
   # { Data1: { f1 Data2 Tsize3 }}


   printf "payload: %s%s\n",unpack('H*',substr($payload,0,76/2)),((length($payload)>76/2)?'...':'') if $dbug;
   my $data = sprintf "%s%s%s",pack('C',(1<<3|2)),&varint(length($payload)),$payload;

   my $mh = pack'C',$mhfncode->{$algo}; # 0x12; 
   my $hsize = $mhfnsize->{$algo}/8; # 256/8
   my $hash = undef;
   if ($algo eq 'GIT') {
     my $hdr = sprintf 'blob %u\0',length($data);
     $hash = &hash1($algo,$hdr,$data);
   } else {
     $hash = &hash1($algo,$data);
   }
   my $mhash = join'',$mh,&varint($hsize),substr($hash,0,$hsize);
   printf "mh16: %s\n",unpack'H*',$mhash if $dbug;
   return $mhash;

}
# ---------------------------------------------------------
sub varint {
  my $i = shift;
  my $bin = pack'w',$i; # Perl BER compressed integer
  # reverse the order to make is compatible with IPFS varint !
  my @C = reverse unpack("C*",$bin);
  # clear msb on last nibble
  my $vint = pack'C*', map { ($_ == $#C) ? (0x7F & $C[$_]) : (0x80 | $C[$_]) } (0 .. $#C);
  return $vint;
}
# ---------------------------------------------------------
sub uvarint {
  my $vint = shift;
  # reverse the order to make is compatible with perl's BER int !
  my @C = reverse unpack'C*',$vint;
  # msb = 1 except last
  my $wint = pack'C*', map { ($_ == $#C) ? (0x7F & $C[$_]) : (0x80 | $C[$_]) } (0 .. $#C);
  my $i = unpack'w',$wint;
  return $i;
}
# ---------------------------------------------------------
sub hash1 { # keyed hash
   use Crypt::Digest qw();
   my $alg = shift;
   my $data = join'',@_;
   my $msg = Crypt::Digest->new($alg) or die $!;
      $msg->add($data);
   my $hash = $msg->digest();
   return $hash;
}
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
sub encode_base32 {
  use MIME::Base32 qw();
  my $mh32 = uc MIME::Base32::encode($_[0]);
  return $mh32;
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
1; # $Source: /my/perl/scripts/shard.pl $
