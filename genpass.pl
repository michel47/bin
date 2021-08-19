#!/usr/bin/perl

# intent: generate a secure enough password for the web

# create a salt from the user,realm and gecos (no randomness here!)
# and keyed-hash it w/ a basic-auth
# password is the base encoded version of that hash


# security risk:
#  suceptible to brute-force attack
#  if any digest of the password is known.


#--------------------------------
# -- Options parsing ...
#
my $all = 0;
my $hashrate = 300_000_000; # hash per second;
my $passbet = join('',('0'..'9','A'..'Z','a'..'z')) . q/!+.,#*/;
my $new = 1 if (exists $ENV{GENPASS_GECOS});
while (@ARGV && $ARGV[0] =~ m/^-/)
{
  $_ = shift;
  #/^-(l|r|i|s)(\d+)/ && (eval "\$$1 = \$2", next);
  if (/^-v(?:erbose)?/) { $verbose= 1; }
  elsif (/^-d(?:e?bug)?/) { $dbug= 1; }
  elsif (/^-c(?:lear)?/) { $clear= 1; }
  elsif (/^-p(?:ass)?(?:w(?:or)?d?)?$/) { $pass_only= 1; }
  elsif (/^-a(?:ll)?/) { $all= 1; }
  elsif (/^-n(?:ew)?/) { $new= 1; }
  elsif (/^--?p(?:ass)?b(?:et)?(?:=(\w+))?/) { $passbet = $1 ? $1 : shift; }
  elsif (/^-y(?:ml)?/) { $yml= 1; }
  else                  { die "Unrecognized switch: $_\n"; }

}
#understand variable=value on the command line...
eval "\$$1='$2'"while $ARGV[0] =~ /^(\w+)=(.*)/ && shift;

my $gecos_fmt = $new ? $ENV{GENPASS_GECOS} : 'password of %s';

my $len = 16;
my $user,$realm;
if ($#ARGV > 0) {
 $user = shift;
 $realm = shift;
} else {
 $realm=shift || 'here';
}
my $home=($new) ? '//www.drit.ml/' : '';
printf "passbet: %s (%uc)\n",$passbet,length($passbet) if $verbose;
my $auth = &get_auth($user,$realm);
printf "auth: %s\n",$auth if $verbose;
# ---------------------------------------------------------------------------------
my $key;
   $key = sprintf "%s:*:0:${len}:${gecos_fmt}:%s:/bin/login",$user,$realm,$home; # salt
my $hash = &khash('SHA256',$key,$auth); # <--- keyed hash !
printf "key: %s\n",$key if $verbose;
printf "hash: %s\n",unpack'H*',$hash if $verbose;
my $pass = &encode_basea(substr($hash,-224),$passbet);
# ---------------------------------------------------------------------------------
# recover info:
my $recbet = $passbet; $recbet =~ s/:/::/;
my $pubkey = &get_pubkey("$user:$realm");
my $hmac = &get_dhmac($pubkey,$hash);
my $record = "$key:$passbet:$hmac";
# TODO 
# ---------------------------------------------------------------------------------
if ($pass_only) {
  printf "%s\n",substr($pass,0,$len);
} else {
  printf "pass: %s\n",substr($pass,0,$len);
  # assuming random-walk on half of the space
  printf "crack: %gyears\n",$len**(length($passbet)) / 365.25 / 86400 / $hashrate / 2;
}

# ----------------------------------
sub encode_basea {
  use Math::BigInt;
  my ($data,$alphab) = @_;
  $alphab = '123456789ABCDEFGHJKLMNPQRSTUVWXYZ -+.$%' unless $alphab; # barcode 
  my $radix = Math::BigInt->new(length($alphab));
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
# ----------------------------------
sub decode_basea { # passing an alphabet ...
  use Math::BigInt;
  my ($s,$alphab) = @_;
  $alphab = '123456789ABCDEFGHJKLMNPQRSTUVWXYZ -+.$%' unless $alphab; # barcode 
  my $radix = Math::BigInt->new(length($alphab));
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
# ----------------------------------
sub khash { # keyed hash
   use Crypt::Digest qw();
   my $alg = shift;
   my $data = join'',@_;
   my $msg = Crypt::Digest->new($alg) or die $!;
      $msg->add($data);
   my $hash = $msg->digest();
   return $hash;
}
# ----------------------------------
sub get_auth {
  my ($user,$realm) = @_;
  my $auth = '*';
  my $ASKPASS;
  if (exists $ENV{DRIT_ASKPASS}) {
    $ASKPASS=$ENV{DRIT_ASKPASS}
  } elsif (exists $ENV{IPMS_ASKPASS}) {
    $ASKPASS=$ENV{IPMS_ASKPASS}
  } elsif (exists $ENV{SSH_ASKPASS}) {
    $ASKPASS=$ENV{SSH_ASKPASS}
  } elsif (exists $ENV{GIT_ASKPASS}) {
    $ASKPASS=$ENV{GIT_ASKPASS}
  } elsif (exists $ENV{SUDO_ASKPASS}) {
    $ASKPASS=$ENV{SUDO_ASKPASS}
  } elsif (exists $ENV{ASKPASS}) {
    $ASKPASS=$ENV{ASKPASS}
  }
  if ($ASKPASS) { 
     use MIME::Base64 qw(encode_base64);
     local *X; open X, sprintf"%s %s %s|",${ASKPASS},$realm;
     local $/ = undef; my $secret = <X>; close X;
     $/ = "\n"; chomp($secret);
     $secret =~ s/^[^*]*\*//; # allow some threat specific responses...
     printf "secret: '%s'\n",$secret if ($verbose && $clear);
     $auth = encode_base64(sprintf('%s:%s',$user,$secret),'');
     return $auth;
  } elsif (exists $ENV{AUTH}) {
     return $ENV{AUTH};
  } elsif ((my $ans = <STDIN>) ne "") {
    chomp($ans);
    $auth = encode_base64(sprintf('%s:%s',$user,$ans),'');
    return $auth;
  } else {
    return 'YW5vbnltb3VzOnBhc3N3b3JkCg=='; # anonymous:password
  }
}

sub get_pubkey {
  my $who = shift;
  my $membership = 'QmdUt2gqucRaV7UHStZH9iVHaKvkqoBHYHJ4tSjMy6zbL7'
  # TODO  
  # return a DHkey
}
sub get_dhmac {
 # TODO : get a diffie hermann mac digest for "rainbow lookup"

}


sub ipfs_cli_api {
}

1;


