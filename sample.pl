#!//usr/bin/perl

my $seed;
#--------------------------------
# -- Options parsing ...
#
while (@ARGV && $ARGV[0] =~ m/^-/)
{
  $_ = shift;
  #/^-(l|r|i|s)(\d+)/ && (eval "\$$1 = \$2", next);
  if (/^--?v(?:erbose)?/) { $verbose= 1; }
  elsif (/^--?[ncl]\w*([\d]*)/) { $n= $1 ? $1 : shift; }
  elsif (/^--?s(?:eed)?([\d]*)/) { $seed= $1 ? $1 : shift; }
  else                  { die "Unrecognized switch: $_\n"; }
}
#understand variable=value on the command line...
eval "\$$1='$2'"while $ARGV[0] =~ /^(\w+)=(.*)/ && shift;
#--------------------------------
$seed = ($seed) ? srand($seed) : srand();

printf STDERR "--- # %s\n",$0;
printf STDERR "n: %s\n",$n if $n;
printf STDERR "seed: %s\n",$seed;

local $/ = "\n";
my @lines = ();
while (<>) {
  push @lines, $_;
}

if ($n) {
  print(  (sort randomly @lines)[0 .. $n-1]);
} else {
  print sort randomly @lines;
}
exit $?;

sub randomly { rand(1.0) < 0.5 ? -1 : 1; };

1; # $Source: /my/perl/scripts/sample.pl $
