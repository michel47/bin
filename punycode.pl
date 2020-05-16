#!/usr/bin/perl

use Encode;
use Encode::Punycode;

while (<STDIN>) {
 my $ans = decode('utf8',$_);
 chomp($ans);
if ($ans =~ m/xn--([^\.]*)/) {
  my $unicode = decode('Punycode',$1);
  my $puny = $ans; $puny =~ s/xn--$1/$unicode/;
  printf "puny: %s\n",$puny;
} elsif ($ans =~ m/([^\.]*)/) {
 my $unicode = "$1";
 print "// ";
 &xxd($unicode);
 my $puny = encode('Punycode',$unicode);
 my $xn = $ans; $xn =~ s/$unicode/xn--$puny/;
 printf "xn: %s\n",$xn;
}
}

exit 1;

# -----------------------------------------------------
sub xxd {
  local *X, open X, "|xxd" or die $!;
  print X @_;
  close X;
  return $?;
}
# -----------------------------------------------------
1; # $Source: /my/perl/scripts/punycode.pl $
