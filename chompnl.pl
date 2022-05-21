#!/usr/bin/perl

my $f = shift;
local *F; open F,'<',$f or die $!;
local $/ = undef;
my $buf = <F>;
close F;
my $last = substr($buf,-1);
if ($last eq "\n") {
  open F,'>',$f or die $!;
  print F substr($buf,0,-1);
  close F;
}

exit $?;
1;
