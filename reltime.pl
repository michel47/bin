#!/usr/bin/perl


use Time::Local qw(timelocal);

printf "--- # %s\n",$0;
my $rpw = 4; # release per week
printf "period: %drel/wk %sh (%sd)\n",$rpw, 24  / ($rpw/7), 7/$rpw;
my $tic = time;
my @time = localtime($tic);
my ($sec,$min,$hour,$day,$mon,$year,$wday,$yday) = @time;
my $midnight = timelocal(0,0,0,$day,$mon,1900+$year);
printf "midnight: %s\n",&hdate($midnight);



my $monday = $midnight - (($wday + 6) % 7) * 24 * 3600;
printf "monday: %s\n",&hdate($monday);
my $sunday = $monday - 3600 * 24;

my $ver = undef;
my $tic = $sunday;
my @rev = &rev($tic);
my $rel =  ($rev[0] + $rev[1]) / 100;
  printf "v%.02f (r%d+%d) %s %s (last Sunday)\n",$rel,@rev,$tic,&hdate($tic);
  $ver = $rel;

for $mm (0 .. 10 * 24 * 60 ) {
  my $tic = $sunday + ($mm) * 60;
  my @rev = &rev($tic);
  my $rel =  ($rev[0] + $rev[1]) / 100;
  if ($rel != $ver) {
    printf "v%.02f (r%d+%d) %s %s\n",$rel,@rev,$tic,&hdate($tic);
  }
  $ver = $rel;
}

exit $?;

sub rev {
  my ($sec,$min,$hour,$mday,$mon,$yy,$wday,$yday) = (localtime($_[0]))[0..7];
  my $rweek=($yday+&fdow($_[0]))/7;
  my $rev_id = int($rweek) * $rpw;
  my $low_id = int(($wday+($hour/24)+$min/(24*60))*$rpw/7);
  my $revision = ($rev_id + $low_id) / 100;
  return (wantarray) ? ($rev_id,$low_id) : $revision;
}

sub fdow {
   my $tic = shift;
   use Time::Local qw(timelocal);
   ##     0    1     2    3    4     5     6     7
   #y ($sec,$min,$hour,$day,$mon,$year,$wday,$yday)
   my $year = (localtime($tic))[5]; my $yr4 = 1900 + $year ;
   my $first = timelocal(0,0,0,1,0,$yr4);
   $fdow = (localtime($first))[6];
   #printf "1st: %s -> fdow: %s\n",&hdate($first),$fdow;
   return $fdow;
}

sub hdate { # return HTTP date (RFC-1123, RFC-2822) 
  my $DoW = [qw( Sun Mon Tue Wed Thu Fri Sat )];
  my $MoY = [qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec )];
  my ($sec,$min,$hour,$mday,$mon,$yy,$wday) = (gmtime($_[0]))[0..6];
  my ($yr4,$yr2) =($yy+1900,$yy%100);
  # Mon, 01 Jan 2010 00:00:00 GMT

  my $date = sprintf '%3s, %02d %3s %04u %02u:%02u:%02u GMT',
             $DoW->[$wday],$mday,$MoY->[$mon],$yr4, $hour,$min,$sec;
  return $date;
}
1;
