#!/usr/bin/perl -w


my $all = 0;
my $base = 32;
our $dbug = 0;
while (@ARGV && $ARGV[0] =~ m/^-/)
{
  $_ = shift;
  #/^-(l|r|i|s)(\d+)/ && (eval "\$$1 = \$2", next);
  if       (/^-a(?:ll)?/) { $all= 1; }
  elsif    (/^-16/) { $base= 16; }
  elsif    (/^-32/) { $base= 32; }
  elsif    (/^-b(\d+)/) { $base= $1; }
  elsif (/^-d(?:e?bug)?/) { $dbug= 1; }
  else                    { die "Unrecognized switch: $_\n"; }

}
#understand variable=value on the command line...
eval "\$$1='$2'"while @ARGV&&$ARGV[0] =~ /^(\w+)=(.*)/ && shift;

local $/ = undef;
my $buf = <>;

my $ns =  sprintf "blob %u\0",length($buf);
my $gitid = &digest('SHA1',$ns,$buf);
my $md6bin = &md6digest($buf);
my $sha2 = &digest('SHA256',$buf);

my $md6hex = unpack'H*',$md6bin;
my $sha2hex = unpack'H*',$sha2;
#printf "md6: %s\n",$md6hex;

my $git36=lc&encode_base36($gitid);
my $git32=&encode_base32z($gitid);
my $git16=unpack'H*',$gitid;
my $id7=substr($git16,0,7);
my $shard3=substr($git32,-4,3);

my $nu = hex($id7);
my $n2 = sprintf "%09u",$nu; $n2 =~ s/(....)/$1_/;

my $pn = hex(substr($md6hex,-4));
my $sn = hex(substr($sha2hex,-6));
my $word5 = &word($pn);
my $word7 = &word($sn);


if ($all) { # base encoding char see [*](https://github.com/multiformats/multibase#multibase-table)
printf "git63: l%s\n",&encode_base63($gitid);
printf "git58: Z%s\n",&encode_base58f($gitid);
printf "git36: k%s\n",$git36;
printf "git32: h%s\n",$git32;
printf "git16: f%s\n",$git16;
printf "git12: E%s\n",&encode_basen($gitid,12);
printf "git10: 9%s\n",&encode_base10($gitid);
printf "shrd3: %s\n",$shard3;
printf "id7: %s\n",$id7;
printf "n2: %s\n",$n2;
printf "pn: %d\n",$pn;
printf "sn: %d\n",$sn;
printf "sha2: z%s\n",&encode_base58(pack('H8','01551220').$sha2);
printf "md6: m%s\n",&encode_base64m($md6bin);
printf "word5: %s\n",$word5;
printf "word7: %s\n",$word7;
} else {
   if ($base == 16) {
      print 'f',$git16;
   } elsif ($base == 32) {
      print 'h',$git32;
   } elsif ($base == 36) {
      print 'k',$git36;
   } elsif ($base == 58) {
      print 'z',&encode_basen($gitid,$base);
   } else {
      printf "%d'%s",$base,&encode_basen($gitid,$base);
   }
}

exit $?;

sub md6digest ($@) {
 use Digest::MD6 qw();
 my $msg = Digest::MD6->new() or die $!;
    $msg->add(join'',@_);
 my $digest = $msg->digest();
 return $digest; #bin form !
}

sub digest ($@) {
 my $alg = shift;
 my $ns = (scalar @_ == 2) ? shift : undef;
 use Crypt::Digest qw();
 my $msg = Crypt::Digest->new($alg) or die $!;
    $msg->add($ns) if defined $ns;
    $msg->add(join'',@_);
 my $digest = $msg->digest();
 return $digest; #bin form !
}

sub encode_base10 {
  use Math::BigInt;
  use Encode::Base58::BigInt qw();
  my $bin = join'',@_;
  my $bint = Math::BigInt->from_bytes($bin);
  return $bint;
}
sub encode_base32z {
  use MIME::Base32 qw();
  my $z32 = uc MIME::Base32::encode($_[0]);
  $z32 =~ y/A-Z2-7/ybndrfg8ejkmcpqxotluwisza345h769/;
  return $z32;
}
sub encode_base36 {
  use Math::BigInt;
  use Math::Base36 qw();
  my $n = Math::BigInt->from_bytes(shift);
  my $k36 = Math::Base36::encode_base36($n,@_);
  #$k36 =~ y,0-9A-Z,A-Z0-9,;
  return $k36;
}
sub encode_base58f { # flickr
  use Math::BigInt;
  use Encode::Base58::BigInt qw();
  my $bin = join'',@_;
  my $bint = Math::BigInt->from_bytes($bin);
  my $h58 = Encode::Base58::BigInt::encode_base58($bint);
  return $h58;
}
sub encode_base58 { # btc
  use Math::BigInt;
  use Encode::Base58::BigInt qw();
  my $bin = join'',@_;
  my $bint = Math::BigInt->from_bytes($bin);
  my $h58 = Encode::Base58::BigInt::encode_base58($bint);
  $h58 =~ tr/a-km-zA-HJ-NP-Z/A-HJ-NP-Za-km-z/;
  return $h58;
}


sub encode_base63 {
  return &encode_basen($_[0],63);
}
sub decode_base63 {
  return &decode_basen($_[0],63);
}
sub encode_base64m {
  use MIME::Base64 qw();
  my $m64 = MIME::Base64::encode_base64($_[0],'');
  return $m64;
}
# -----------------------------------------------------------------------
sub encode_basen { # n < 94;
  use Math::BigInt;
  my ($data,$radix) = @_;
  my $alphab = &alphab($radix);;
  my $mod = Math::BigInt->new($radix);
  #printf "mod: %s, lastc: %s\n",$mod,substr($alphab,$mod,1);
  my $h = '0x'.unpack('H*',$data);
  my $n = Math::BigInt->from_hex($h);
  my $e = '';
  while ($n->bcmp(0) == +1)  {
    my $c = Math::BigInt->new();
    ($n,$c) = $n->bdiv($mod);
    $e .= substr($alphab,$c->numify,1);
  }
  return scalar reverse $e;
}
# ---------------------------
sub decode_basen { # n < 94
  use Math::BigInt;
  my ($s,$radix) = @_;
  my $alphab = &alphab($radix);;
  die "alphab: %uc < %d\n",length($alphab) if (length($alphab) < $radix);
  my $n = Math::BigInt->new(0);
  my $j = Math::BigInt->new(1);
  while($s ne '') {
    my $c = substr($s,-1,1,''); # consume chr from the end !
    my $i = index($alphab,$c);
    return '' if ($i < 0);
    my $w = $j->copy();
    $w->bmul($i);
    $n->badd($w);
    $j->bmul($radix);
  }
  my $h = $n->as_hex();
  # byte alignment ...
  my $d = int( (length($h)+1-2)/2 ) * 2;
  $h = substr('0' x $d . substr($h,2),-$d);
  return pack('H*',$h);
}
# ---------------------------------------------------------
sub alphab {
  my $radix = shift;
  my $alphab;
  if ($radix < 12) {
    $alphab = '0123456789-';
  } elsif ($radix <= 16) {
    $alphab = '0123456789ABCDEF';
  } elsif ($radix <= 26) {
    $alphab = 'ABCDEFGHiJKLMNoPQRSTUVWXYZ';
  } elsif ($radix == 32) {
    $alphab = '0123456789ABCDEFGHiJKLMNoPQRSTUV'; # Triacontakaidecimal
    $alphab = join('',('A' .. 'Z', '2' .. '7')); # RFC 4648
    $alphab = '0123456789ABCDEFGHJKMNPQRSTVWXYZ'; # Crockfordś ![ILOU] (U:accidental obscenity)
    $alphab = 'ybndrfg8ejkmcpqxotluwisza345h769';  # z-base32 ![0lv2]
  
  } elsif ($radix == 36) {
    $alphab = 'ABCDEFGHiJKLMNoPQRSTUVWXYZ0123456789';
  } elsif ($radix <= 38) {
    $alphab = '0123456789ABCDEFGHiJKLMNoPQRSTUVWXYZ.-';
  } elsif ($radix <= 40) {
    $alphab = 'ABCDEFGHiJKLMNoPQRSTUVWXYZ0123456789-_.+';
  } elsif ($radix <= 43) {
    $alphab = 'ABCDEFGHiJKLMNoPQRSTUVWXYZ0123456789 -+.$%*';
  } elsif ($radix == 58) {
    $alphab = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  } elsif ($radix == 62) {
    $alphab = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  } else { # n < 94
    $alphab = '-0123456789'. 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
                             'abcdefghijklmnopqrstuwvxyz'. 
             q/+.@$%_,~`'=;!^[]{}()#&/.      '<>:"/\\|?*'; #
  } 
  printf "// alphabet: %s (%uc)\n",$alphab,length($alphab) if $dbug;
  return $alphab;
}
# -----------------------------------------------------------------------
sub word { # 20^4 * 6^3 words (25bit worth of data ...)
 my $n = $_[0];
 my $vo = [qw ( a e i o u y )]; # 6
 my $cs = [qw ( b c d f g h j k l m n p q r s t v w x z )]; # 20
 my $str = '';
 while ($n >= 20) {
   my $c = $n % 20;
      $n /= 20;
      $str .= $cs->[$c];
      $c = $n % 6;
      $n /= 6;
      $str .= $vo->[$c];
 }
 $str .= $cs->[$n];
 return $str;	
}
# -----------------------------------------------------------------------
1; # $Source: /my/perl/scripts/gitid.pl $

