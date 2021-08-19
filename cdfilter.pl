#!/usr/bin/env perl

my $green = "\e[32m";
my $red = "\e[31m";
my $yellow = "\e[33m";
my $none = "\e[0m";
my $seen;
my @CDP = ();
#foreach my $p (split':',$ENV{CDPATH}) {
#   next if ($seen{$p}++);
#   push @CDP, $p;
#}
while (<>) {
   my $f = $_; chomp($d);
   my $d = substr($f,0,rindex($f,'/.git'));
   next if $d =~ m,/(?:\.|_site|cypher|wiki),;
   next if ($seen{$d}++);
   #printf STDERR "d: %s\n",$d unless ($seen{$d}++);
   my $p = substr($d,0,rindex($d,'/'));
   #printf STDERR "${yellow}p: ${green}%s${none}\n",$p unless ($seen{$p}++);
   $p =~ s,$ENV{HOME},~,;
   next if ($seen{$p}++);
   push @CDP, $p;

}

#print 'CDPATH=',join':',@CDP;
print join':',@CDP;

exit $?;

1;
