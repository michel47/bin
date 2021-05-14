#!/usr/bin/env perl

our $dbug=0;
#--------------------------------
# -- Options parsing ...
#
my $all = 0;
while (@ARGV && $ARGV[0] =~ m/^-/)
{
  $_ = shift;
  #/^-(l|r|i|s)(\d+)/ && (eval "\$$1 = \$2", next);
  if (/^--?v(?:erbose)?/) { $verbose= 1; }
  elsif (/^--?d(?:e?bug)?/) { $all= 1; }
  elsif (/^--?a(?:ll)?/) { $all= 1; }
  elsif (/^--?y(?:ml)?/) { $yml= 1; }
  else                  { die "Unrecognized switch: $_\n"; }

}
#understand variable=value on the command line...
eval "\$$1='$2'"while $ARGV[0] =~ /^(\w+)=(.*)/ && shift;

use YAML::Syck qw();
# get key as argument or stdin

if (@ARGV) {
 $key = shift;
} else {
 $key = <STDIN>;
 chomp($key);
}
$key =~ s,.*/ip[fhnm]s/,,;
$key = 'QmboiLojgoteK2P1NWhAjUutsgCpBmgpbrD1iKDAjSWxf4' unless $key;
print "key: $key\n" if $all;

# ----------------------------------------------------------------
# decode data (keep only the binary-hash value
my $bindata = "\0";
if ($key =~ m/^Qm/) {
 $bindata = &decode_base58($key);
 printf "mh58: %s (%uc, %uB) : f%s...\n",$key,length($key),
        length($bindata), substr(unpack('H*',$bindata),0,11) if $dbug;
 $bindata = substr($bindata,-32); # remove header
 printf "bin: %s\n",unpack'H*',$bindata if $all;
# ----------------------------------------------------------------
} elsif ($key =~ m/^z/) {
 $bindata = &decode_base58(substr($key,1));
 printf "zb58: %s (%uc, %uB) : f%s...\n",$key,length($key),
 length($bindata), substr(unpack('H*',$bindata),0,11) if $dbug;
 my $cid = substr($bindata,0,2);
 if ($cid eq "\x01\x55" || $cid eq "\x01\x70") {
   #my $header = substr($bindata,0,4);
   $bindata = substr($bindata,4);
 } else {
   $bindata = substr($bindata,2); # remove header
 }
printf "sha2: f%s\n",unpack('H*',$bindata) if $dbug;
# ----------------------------------------------------------------
} else { # if key is plain text ... do a sha2 on it
  $key =~ s/\\n/\n/g;
  $key .= ' '.join' ',@ARGV if (@ARGV);
  $bindata = &hashr('SHA-256',1,$key); # SHA-256 if cleartext !
  printf "sha2(%s): %s\n",$key,unpack('H*',$bindata) if $dbug;
}
# ----------------------------------------------------------------
our $wordlists;
my $qmDICT = 'QmT3CaqFDZWQb2aNYCHMRQYLVEHS2Z5huDFQBoTYnHoSm8';
#y $etcdir = __FILE__; $etcdir =~ s,/bin/\w+$,/etc,;
#y $DICT = (exists $ENV{DICT}) ? $ENV{DICT} : $etcdir; # '/usr/share/dict';
#rintf "// DICT=%s\n",$DICT if $dbug;

my $sha16 = unpack('H*',$bindata);
my $id7 = substr($sha16,0,7);
printf "id7: %s\n",$id7 if $all;

my $fnamelist = &load_qmlist('fnames');
my $lnamelist = &load_qmlist('lnames');

my @fullname = &fullname($bindata);
#printf "%s.\n",YAML::Syck::Dump(\@fullname) if $dbug;
if ($all) {
printf "fullname: %s %s. %s\n",$fullname[0],substr($fullname[1],0,1),$fullname[-2];
} else {
printf "%s %s. %s\n",$fullname[0],substr($fullname[1],0,1),$fullname[-2];
}
#printf "https://robohash.org/%s.png/set=set4&bgset=bg1&size=120x120&ignoreext=false\n",join'.',map { lc $_; } @fullname;

if ($all) {
   printf "ini: %s%s%s\n",uc(substr($fullname[0],0,1)),uc(substr($fullname[1],0,1)),uc(substr($fullname[-2],0,1));
   printf "firstname: %s\n",$fullname[0];
   printf "midlename: %s\n",$fullname[1];
   printf "lastname: %s\n",$fullname[-2];
   printf "maidenname: %s\n",$fullname[-1];
   printf "lni: %s\n",uc(substr($fullname[-2],0,1));
   printf "mni: %s\n",uc(substr($fullname[1],0,1));
   printf "fni: %s\n",uc(substr($fullname[0],0,1));
   printf "user: %s%s\n",lc(substr($fullname[0],0,1)),lc($fullname[-2]);
   printf "email: %s%s+%s\@%s\n",lc(substr($fullname[0],0,1)),lc($fullname[-2]),$id7,'ydentity.ml';
}

exit $?;

# -----------------------------------------------------------------------
sub get_ipfs_content {
  my $ipath=shift;
  use LWP::UserAgent qw();
  my ($gwhost,$gwport) = &get_gwhostport();
  my $proto = ($gwport == 443) ? 'https' : 'http';
  my $url = sprintf'%s://%s:%s%s',$proto,$gwhost,$gwport,$ipath;
  printf "url: %s\n",$url if $::dbug;
  my $ua = LWP::UserAgent->new();
  my $resp = $ua->get($url);
  if ($resp->is_success) {
    my $content = $resp->decoded_content;
    return $content;
  } else {
    return undef;
  }
}
# -----------------------------------------------------------------------
sub load_qmlist {
   my $wlist = shift;
   if (! exists $wordlists->{$wlist}) {
      $wordlists->{$wlist} = [];
   }
   # ------------------------------
   my $wordlist = $wordlists->{$wlist};
   my $wl = scalar @$wordlist;
   if ($wl < 1) {
      my $file;
      my $buf = &get_ipfs_content("/ipfs/$qmDICT/$wlist.txt");
      if (ref($buf) eq 'HASH' || $buf eq '') {
        return undef;
      }
      @$wordlist = grep !/^#/, split("\n",$buf);
      $wl = scalar @$wordlist;
      #printf "wlist: %s=%uw\n",$wlist,$wl;
   }
  return $wordlist;
}
# -----------------------------------------------------------------------
sub fullname {
  my $bin = shift;
  my $funiq = substr($bin,1,6); # 6 char (except 1st)
  my $luniq = substr($bin,7,4);  # 4 char 
  my $flist = $wordlists->{fnames};
  my $llist = $wordlists->{lnames};
  my @first = map { $flist->[$_] } &encode_baser($funiq,5494);
  my @last = map { $llist->[$_] } &encode_baser($luniq,88799);
 
  return (@first,'.',@last);
}
# -----------------------------------------------------------------------
sub encode_base58 {
  use Math::BigInt;
  use Encode::Base58::BigInt qw();
  my $bin = join'',@_;
  my $bint = Math::BigInt->from_bytes($bin);
  my $h58 = Encode::Base58::BigInt::encode_base58($bint);
  $h58 =~ tr/a-km-zA-HJ-NP-Z/A-HJ-NP-Za-km-z/;
  return $h58;
}
# --------------------------------------------
sub decode_base58 {
  use Math::BigInt;
  use Encode::Base58::BigInt qw();
  my $s = $_[0];
  # $e58 =~ tr/a-km-zA-HJ-NP-Z/A-HJ-NP-Za-km-z/;
  $s =~ tr/A-HJ-NP-Za-km-z/a-km-zA-HJ-NP-Z/;
  my $bint = Encode::Base58::BigInt::decode_base58($s);
  my $bin = Math::BigInt->new($bint)->as_bytes();
  return $bin;
}
# --------------------------------------------
sub encode_base32 {
  use MIME::Base32 qw();
  my $mh32 = uc MIME::Base32::encode($_[0]);
  return $mh32;
}
sub decode_base32 {
  use MIME::Base32 qw();
  my $bin = MIME::Base32::decode($_[0]);
  return $bin;
}
# -----------------------------------------------------------------------
sub hashr {
   my $alg = shift;
   my $rnd = shift;
   my $tmp = join('',@_);
   use Digest qw();
   my $msg = Digest->new($alg) or die $!;
   for (1 .. $rnd) {
      $msg->add($tmp);
      $tmp = $msg->digest();
      $msg->reset;
   }
   return $tmp
}
# -----------------------------------------------------------------------
sub qmcontainer { # (cidv0)
   my $msg = shift;
   my $msize = length($msg);
   # Qm container are off format : { Data1: { f1 Data2 Tsize3 }}
   # QmPa5thw8vNXH7eZqcFX8j4cCkGokfQgnvbvJw88iMJDVJ
   # 00000000: 0a0e 0802 1208 6865 6c6c 6f20 210a 1808  ......hello !...
   # {"Links":[],"Data":"\u0008\u0002\u0012\u0008hello !\n\u0018\u0008"}
   # header:  0000_1010 : f1.t2 size=14 (0a0e)
   # payload: 0802_1208 ... 1808
   #          0000_1000 : f1.t0 varint=2 (0802)
   #          0001_0010 : f2.t2 size=8 ... (1208 ...)
   #          0001_1000 : f3.t0 varint=8 (1808)

   my $f1 = sprintf      '%s%s',pack('C',(1<<3|0)),&varint(2); # f1.t0 varint=2
      $data2 = sprintf '%s%s%s',pack('C',(2<<3|2)),&varint($msize),$msg; # f2.t2 msize msg
      $tsize3 = sprintf  '%s%s',pack('C',(3<<3|0)),&varint($msize); # f3.t0 msize
   my $payload = $f1 . $data2 . $tsize3;

   my $data = sprintf "%s%s%s",pack('C',(1<<3|2)),&varint(length($payload)),$payload; # f1.t2 size, payload
   return $data;
}
sub varint {
  my $i = shift;
  my $bin = pack'w',$i; # Perl BER compressed integer
  # reverse the order to make is compatible with IPFS varint !
  my @C = reverse unpack("C*",$bin);
  # clear msb on last nibble
  my $vint = pack'C*', map { ($_ == $#C) ? (0x7F & $C[$_]) : (0x80 | $C[$_]) } (0 .. $#C);
  return $vint;
}
# -----------------------------------------------------------------------
sub get_gwhostport {
  my $IPFS_PATH = $ENV{IPFS_PATH} || $ENV{HOME}.'/.ipfs';
  my $conff = $IPFS_PATH . '/config';
  printf "\/\/ config: %s\n",$conff if $dbug;
  local *CFG; open CFG,'<',$conff or warn $!;
  local $/ = undef; my $buf = <CFG>; close CFG;
  use JSON qw(decode_json);
  my $json = decode_json($buf);
  my $gwaddr = $json->{Addresses}{Gateway};
  my (undef,undef,$gwhost,undef,$gwport) = split'/',$gwaddr,5;
      $gwhost = '127.0.0.1' if ($gwhost eq '0.0.0.0');
  my $url = sprintf'http://%s:%s/ipfs/zz38RTafUtxY',$gwhost,$gwport;
  printf "try: http://%s:%s/ipfs/zz38RTafUtxY\n",$gwhost,$gwport if $dbug;
  my $ua = LWP::UserAgent->new();
  my $resp = $ua->get($url);
  if ($resp->is_success) {
    return ($gwhost,$gwport);
  } else { #do a second attempt 
    my $ua = LWP::UserAgent->new();
    $gwhost = 'localhost';
    $gwport = 8080;
    my $url = sprintf'http://%s:%s/ipfs/zz38RTafUtxY',$gwhost,$gwport;
    printf "try-again: http://%s:%s/ipfs/zz38RTafUtxY\n",$gwhost,$gwport if $dbug;
    $resp = $ua->get($url);
    if ($resp->is_success) {
      return ($gwhost,$gwport);
    } else {
      return ('ipfs.blockringtm.ml',443);
    }
  }
}
# -----------------------------------------------------------------------
sub get_apihostport {
  my $IPFS_PATH = $ENV{IPFS_PATH} || $ENV{HOME}.'/.ipfs';
  my $conff = $IPFS_PATH . '/config';
  local *CFG; open CFG,'<',$conff or warn $!;
  local $/ = undef; my $buf = <CFG>; close CFG;
  use JSON qw(decode_json);
  my $json = decode_json($buf);
  my $apiaddr = $json->{Addresses}{API};
  my (undef,undef,$apihost,undef,$apiport) = split'/',$apiaddr,5;
      $apihost = '127.0.0.1' if ($apihost eq '0.0.0.0');
  return ($apihost,$apiport);
}
# -----------------------------------------------------------------------
sub ipms_api {
   use LWP::UserAgent qw();
   # ipms config Addresses.API
   #  (assumed gateway at /ip4/127.0.0.1/tcp/5001/...)
   my $api_url;
   if ($ENV{HTTP_HOST} =~ m/heliohost/) {
      $api_url = sprintf'https://%s/api/v0/%%s?arg=%%s%%s','ipfs.blockringtm.ml';
   } else {
     my ($apihost,$apiport) = &get_apihostport();
      $api_url = sprintf'http://%s:%s/api/v0/%%s?arg=%%s%%s',$apihost,$apiport;
   }
   my $url = sprintf $api_url,@_; # failed -w flag !
   #  printf "X-api-url: %s<br>\n",$url;
   my $content = '';
   my $ua = LWP::UserAgent->new();
   my $realm='Restricted Content';
   if ($ENV{HTTP_HOST} =~ m/heliohost/) {
      use MIME::Base64 qw(decode_base64);
      my $auth64 = &get_auth();
      my ($user,$pass) = split':',&decode_base64($auth64);
      $ua->credentials('ipfs.blockringtm.ml:443', $realm, $user, $pass);
      # printf "X-Creds: %s:%s\n",$ua->credentials('ipfs.blockringtm.ml:443', $realm);
   }
   my $resp = $ua->get($url);
   if ($resp->is_success) {
      # printf "X-Status: %s<br>\n",$resp->status_line;
      $content = $resp->decoded_content;
   } else { # error ... 
      printf "X-api-url: %s\n",$url;
      printf "Status: %s\n",$resp->status_line;
      $content = $resp->decoded_content;
      local $/ = "\n";
      chomp($content);
      printf "Content: %s\n",$content;
   }
   if ($content =~ m/^{/) { # }
      use JSON qw(decode_json);
      my $json = &decode_json($content);
      return $json;
   } elsif ($_[0] =~ m{^(?:cat|files/read)}) {
     return $content;
   } else {
	   printf "Content: %s\n",$content if $dbug;
     if (0) {
        $content =~ s/"/\\"/g;
        $content =~ s/\x0a/\\n/g;
        $content = sprintf'{"content":"%s"}',$content;
     }
     return $content;
   }
}
# -----------------------------------------------------------------------
sub encode_baser {
  use Math::BigInt;
  my ($d,$radix) = @_;
  my $n = Math::BigInt->from_bytes($d);
  my @e = ();
  while ($n->bcmp(0) == +1)  {
    my $c = Math::BigInt->new();
    my ($n,$c) = $n->bdiv($radix);
    push @e, $c->numify;
  }
  return reverse @e;
}
# ---------------------------------------------------------
sub decode_baser (\@$) {
  use Math::BigInt;
  my ($s,$radix) = @_;
  my $n = Math::BigInt->new(0);
  my $j = Math::BigInt->new(1);
  foreach my $i (reverse @$s) { # for all digits
    return '' if ($i < 0);
    my $w = $j->copy();
    $w->bmul($i);
    $n->badd($w);
    $j->bmul($radix);
  }
  my $d = $n->as_bytes();
  return $d;

}
# -----------------------------------------------------------------------
1;
