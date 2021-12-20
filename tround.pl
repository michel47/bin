#!/usr/bin/perl
#
# intent: round decimal hours from toptracker
# usage: 
#  perl -S tround.pl 4:32 $(date +%m)


my $t = shift;
my $mday = shift || (localtime(time))[3];

my ($h,$m) = split':',$t;

printf "--- %s\n",$0;



printf "mday: %d\n", $mday;
printf "mins: %s\n", $h * 60 + $m;
printf "hours: %s\n", &round($h + $m/60,$mday%2);

sub round {
  return int ( 100 * $_[0] + 0.99999 * $_[1] ) / 100;
}
