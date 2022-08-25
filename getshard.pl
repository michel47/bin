#!/usr/bin/perl

my $all = 0;
my $len = 7;
while (@ARGV && $ARGV[0] =~ m/^-/)
{
  $_ = shift;
  #/^-(l|r|i|s)(\d+)/ && (eval "\$$1 = \$2", next);
  if (/^--?v(?:erbose)?/) { $verbose= 1; }
  elsif (/^--?l(?:en)?=?([\w]*)/) { $len = $1 ? $1 : shift; }
  elsif (/^--?d(?:e?bug)?/) { $dbug= 1; }
  elsif (/^--?a(?:ll)?/) { $all= 1; }
  elsif (/^--?y(?:ml)?/) { $yml= 1; }
  else                  { die "Unrecognized switch: $_\n"; }

}

my $name = shift;
my $nshard = &nshard($name,$len);
if ($all) {
printf "len: %s\n",$len;
printf "name: %s\n",$name;
printf "shard: %s\n",$nshard;
} else {
printf "%s",$nshard;
}
exit $?;

# namespace id: 13 char of base36(sha256)
# 13 is chosen to garantie uniqness
# over a population of 2^64 nodes
sub nshard($@) {
 my $len = ($#_ > 0) ? pop : 13;
 my $sha2 = &khash('SHA256',@_);
 my $ns36 = &encode_base36($sha2);
 my $nid = substr($ns36,0,$len);
 return lc $nid;
}

sub khash { # keyed hash
   use Crypt::Digest qw();
   my $alg = shift;
   my $data = join'',@_;
   my $msg = Crypt::Digest->new($alg) or die $!;
      $msg->add($data);
   my $hash = $msg->digest();
   return $hash;
}

sub encode_base36 {
  use Math::BigInt;
  use Math::Base36 qw();
  my $n = Math::BigInt->from_bytes(shift);
  my $k36 = Math::Base36::encode_base36($n,@_);
  #$k36 =~ y,0-9A-Z,A-Z0-9,;
  return $k36;
}

1;


