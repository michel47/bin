#!/usr/bin/perl

# Sieve Eratosthenes :

my $n = shift || 134217779; # 128MB
my @A = map { 1 } (2 .. $n+2);
$A[0] = 0;
$A[1] = 1;

my $sqrn = int sqrt($n+2);

for my $i (2 .. $sqrn) {
  if ($A[$i]) {
     my $i2 = $i*$i;
     for (0 .. int($n+2-$i2)/$i ) {
       my $j = $i2 + $_ * $i;
       @A[$j] = 0;
     }
  }
}

my $r = '';
local $| = 1;
foreach my $p ($sqrn .. $n) {
  printf $r.'%3u ',$p if ($A[$p]);
}

exit $?;

1;
