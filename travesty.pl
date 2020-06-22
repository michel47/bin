#!/usr/bin/perl

my $nl = shift;

while (<>) {
   next if /^\./;
   next if /^From / .. /^$/;
   next if /^Path: / .. /^$/;
   s/^\W+//;
   push(@ary,split(' '));
   while ($#ary > 1) {
      $aw = $pw; $pw = $w;
      $a = $p; $p = $n;
      $w = shift(@ary);
      $n = $num{$w};
      if ($n eq '') {
         push(@word,$w);
         $n = pack('S',$#word); # index in @word dictionary
         $num{$w} = $n;
      }
      $lookup{$a . $p} .= $n;
      $idx = sprintf '%3d',unpack('S',$n);
      $dict{$idx.':'.$aw.'-'.$pw} .= '-'.$w;
   }
}

use YAML::Syck qw(DumpFile);
DumpFile('travesty-lookup.yml',\%lookup);
DumpFile('travesty-dict.yml',\%dict);


my $i = 0;
for (;;) {
   $n = $lookup{$a . $p};
   ($foo,$n) = each(%lookup) if $n eq '';
   $n = substr($n,int(rand(length($n))) & 0177776,2);
   $a = $p;
   $p = $n;
   ($w) = unpack('S',$n);
   $w = $word[$w];
   $col += length($w) + 1;
   if ($col >= 65) {
      $col = 0;
      print "\n";
      $i++;
   }
   else {
      print ' ';
   }
   print $w;
   if ($w =~ /\.$/) {
      if (rand() < .1) {
         print "\n";
         $i++;
         $col = 80;
      }
   }
   last if (defined $nl && $i > $nl);
}

exit $?;
1;

