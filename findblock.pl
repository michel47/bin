#!/usr/bin/env perl
#
# take a content and return atom list
#
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
my $qmhash = &qmhash('SHA256',$content);
my $qm = &encode_base58($qmhash);
my $ciq = &encode_base32($qmhash);
my $shard = substr($ciq,-3,2);
my $qm58 = &encode_base58($qmhash);
my $bafy = &encode_base32("\x01\x70".$qmhash);

my $sha1 = &digest('SHA1',$content);
my $sha2 = &digest('SHA-256',$content);
my $zb58 = &encode_base58("\x01\x55\x12\x20",$sha2);

printf "--- # %s\n",$0 if ($yaml);

if ($yaml || $all) {
printf "shard: %s\n",$shard;
printf "qm: %s\n",$qm;
printf "ciq: %s\n",$ciq;
printf "bafy: B%s\n",$bafy;
printf "mu: %u\n",$mu;
printf "gitid: %s\n",$gitid;
printf "id7: %s\n",$id7;
printf "md5: %s\n",$md5;
printf "sha1: %s\n",unpack('H*',$sha1);
printf "zb58: z%s\n",$zb58;
printf "md6: %s\n",$md6;
printf "pn: %s\n",$pn;
printf "word: %s\n",$word;
printf "n2: %s\n",$n2;
printf "loc: %s\n",$loc;
}

my $keys = &locate_key($ciq);
push @$keys,@{&locate_key($bafy)};
if (scalar(@$keys)) {
  printf "blocks:\n";
  foreach my $f (@$keys) {
     printf  " - %s\n",$f;
  }
}

exit $?;

sub locate_key {
   my $mh32 = shift;
   my %seen = ();
   my $found = [];
   my @repolist = &get_repo_list();
   #use YAML::Syck qw(Dump); printf "%s.\n",Dump(\@iplist); 
   foreach my $repo (@repolist) {
      my $file = sprintf"%s/blocks/%s/%s.data",$repo,
         substr(uc$mh32,-3,2),uc$mh32;
      next if $seen{$file}++;
      if (-e $file) {
         push @$found, $file;
      }
   }
   return $found;
}

sub loadlist {
  my $file = shift;
  local *F; open F,'<',$file; local $/ = "\n";
  my @list = map { chomp; $_ } grep !/^#/, (<F>); close F;
  return @list;
}

sub get_repo_list {

   my @iplist;
   if (-e '/tmp/ipfs-repos.txt') {
     @iplist = &loadlist('/tmp/ipfs-repos.txt');
   }
   if (-d '/media/IPFS/') {
     local *D; opendir D,'/media/IPFS';
     my @content = grep { (-e "/media/IPFS/$_/blocks") ? 1 : 0 } readdir(D); close D;
     push @iplist, map { "/medial/IPFS/$_" } @content;
   }
   my @repol = ();
   foreach my $repo ($ENV{IPFS_PATH}, $ENV{HOME}.'/.ipfs',
                  '/media/IPFS/PERMLINK',
                  '/media/IPFS/INFINITE',
                  '/media/IPFS/IMAGES',
                   @iplists,
                  '/media/iggy/1TB/PERMLINK',
                  '/media/iggy/1TB/INFINITE',
                  #'/media/iggy/3TB/IPFS',
                  #'/media/iggy/3TB/IPFS/PUBLIC',
                  '/mnt/HDD/IPFS/PERMLINK',
                  '/mnt/HDD/IPFS/LOSTNFOUND',
                  '/mnt/HDD/IPFS/Tommy',
                  '/media/cloud/Tommy/.ipfs',
                  '/media/cloud/Tommy/public_html/ipfs',
                  '/usr/local/share/doc/civetweb/public_html/../.ipfs',
                       ) {
      next if $seen{$repo}++;
      next unless -d $repo;
      push @repol, $repo;
    }
    return @repol;
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
 my $blob = join'',@_;
 my $msg = Digest::SHA1->new() or die $!;
    $msg->add(sprintf "blob %u\0",length($blob));
    $msg->add($blob);
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
