#!/usr/bin/perl
#
# usage:
#  perl -S intent.pl  -i "state your intent..."

my $intent = "Bringing humanity-changing technology to the you";
while (@ARGV && $ARGV[0] =~ m/^-/)
{
  $_ = shift;
  #/^-(l|r|i|s)(\d+)/ && (eval "\$$1 = \$2", next);
  if (/^--?v(?:erbose)?/) { $verbose= 1; }
  elsif (/^--?i(?:ntent)?=?([\w]*)/) { $intent= $1 ? $1 : shift; }
  else                  { die "Unrecognized switch: $_\n"; }

}
#understand variable=value on the command line...
eval "\$$1='$2'"while $ARGV[0] =~ /^(\w+)=(.*)/ && shift;


if (! exists($ENV{ASKPASS})) { $ENV{ASKPASS}="ssh-askpass password intent"; }

my $pass = &get_pass();

my $sha2 = &khash('SHA256',$pass,$intent);
my $sha16 = unpack'H*',$sha2;
printf "sha2: f%s\n",$sha16;

my $tic = time();
my $key = substr($sha16,-10,7);
my $seed = hex($key);
printf "tic: %s\n",$tic;
printf "key: %s\n",$key;
printf "seed: %s\n",$seed;
printf qq'intent: "%s"\n',$intent;

sub khash { # keyed hash
   use Crypt::Digest qw();
   my $alg = shift;
   my $data = join'',@_;
   my $msg = Crypt::Digest->new($alg) or die $!;
      $msg->add($data);
   my $hash = $msg->digest();
   return $hash;
}

sub get_pass() {
  if (exists $ENV{ASK_PASS}) {
    open EXEC,$ENV{ASK_PASS}.'|';
    my $pass = <EXEC>; chomp($pass);
    #printf $LOG qq'%s.pass: %s\n',$callee,$pass;
    return $pass
  } else {
    require Term::ReadKey;
    Term::ReadKey::ReadMode('noecho');
    printf STDERR "secret? ";
    my $secret = Term::ReadKey::ReadLine(0);
    $secret =~ s/\R\z//;
    Term::ReadKey::ReadMode('restore');
    return $secret;
  }
}


1;
