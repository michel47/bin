#!/usr/bin/perl

while (@ARGV && $ARGV[0] =~ m/^-/)
{
  $_ = shift;
  #/^-(l|r|i|s)(\d+)/ && (eval "\$$1 = \$2", next);
  if (/^--?v(?:erbose)?/) { $verbose= 1; }
  elsif (/^--?u(?:ser)?/) { $user= 1; }
  elsif (/^--?p(?:ass(?:wo?r?d))?/) { $pass= 1; }
  elsif (/^--?a(?:ll)?/) { $all= 1; }
  else                  { die "Unrecognized switch: $_\n"; }

}
#understand variable=value on the command line...
eval "\$$1='$2'"while $ARGV[0] =~ /^(\w+)=(.*)/ && shift;


my $nrcf = $ENV{HOME}.'/.netrc';
local *F; open F,'<',$nrcf;
my $creds = {};
my ($machine,$login,$password);
while (<F>) {
  if (m/machine (\S+)/) {
    $machine = $1;
  } elsif (m/login (\S+)/) {
    $login = $1;
    $creds->{$machine}{login} = $login;
  } elsif (m/password (\S+)/) {
    $password = $1;
    $creds->{$machine}{password} = $password;
  } 
}
close F;

my $host = shift;
if (exists $creds->{$host}) {
  if ($user) {
    print $creds->{$host}{login};
  } elsif ($pass) {
    print $creds->{$host}{password};
  } elsif ($all) {
    printf "user: %s\n", $creds->{$host}{login};
    printf "password: %s\n", $creds->{$host}{password};
  }
}

