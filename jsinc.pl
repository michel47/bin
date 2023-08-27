#!/usr/bin/perl

my $file=shift;
local *F; open F,'<',$file;
while (<F>) {
  if (m/\/\/ import '([^']+)'/) {
    printf "// included: %s\n",$1;
    local *I; open I,'<',$1;
    while (<I>) { print $_; }
  } else {
    print $_;
  }
}
