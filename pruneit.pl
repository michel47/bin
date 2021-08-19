#!/usr/bin/perl

# usage: 
#  perl pruneit.pl 50G cold.log dustdir

$| = 1;
use YAML::XS qw(Dump);

#--------------------------------
# -- Options parsing ...
#
my $all = 0;
my $timely = 0;
while (@ARGV && $ARGV[0] =~ m/^-/)
{
  $_ = shift;
  #/^-(l|r|i|s)(\d+)/ && (eval "\$$1 = \$2", next);
  if (/^-v(?:erbose)?/) { $verbose= 1; }
  elsif (/^--?t(?:ime(?:ly)?)?/) { $timely= 1; }
  elsif (/^--?r(?:andom(?:ly)?)?/) { $timely= 0; }
  else                  { die "Unrecognized switch: $_\n"; }

}
#understand variable=value on the command line...
eval "\$$1='$2'"while $ARGV[0] =~ /^(\w+)=(.*)/ && shift;


my $dust = (-d 'dust') ? 'dust' : '../dust';
my $maxsize = shift;
my $idxf = shift;
my $repo = shift || $dust;

$clipat = $1 * 1024 * 1024 if ($maxsize =~ m/(\d+)G$/);
$clipat = $1 * 1024 if ($maxsize =~ m/(\d+)M$/);
$clipat = $1 if ($maxsize =~ m/(\d+)K$/i);
$clipat = $1 / 1024 if ($maxsize =~ m/(\d+)$/);

my $seed = srand();
printf "seed: %s\n",$seed;
printf "clipat: %uk\n",$clipat;
printf "idxf: %s\n",$idxf;

my $index = &loadindex($idxf);
#printf "--- # %s...\n",Dump($idx);

my @set;
if ($timely) {
@set = reverse sort by_time keys %{$index};
} else {
@set = reverse sort randomly keys %{$index};
}

my $totsize = 0;
for $k (@set) {
   $totsize += $index->{$k}[2];
}
printf "totsize: %.3fG\n",$totsize/1024/1024/1024;
 
my $keep = 1;
my $n = 0;
my $moved = 0;
my $cursize = 0;
my $removed = 0;
for $k (@set) {
   my $size = $index->{$k}[2];
   my $f = $index->{$k}[3];
   
   next unless -e $f;
   $cursize += $size/1024;
   $n++;
   if ($cursize >= $clipat) {
      $keep = 0;
   }
   if ($keep == 0) {
      if ($repo eq '/dev/null') {
         unlink $f;
         $removed += $size/1024;
         printf "\r%u: %uM, removed %s",$n,$removed/1024,$f;
      } else {
         my $path = $1 if ($f =~ m,(.*/blocks)/[A-Z0-9]{2}/,);
         my $dst = $f; $dst =~ s,$path,$repo/blocks,;
         if (! -e $dst) {
            my $shard = $1 if ($f =~ m,$path/(..)/,);
            mkdir "$repo/blocks/$shard" unless -d "$repo/blocks/$shard";
            #print " mv $f $dst\n";
            rename $f,$dst or warn "$dst: $!";
            $moved += $size/1024;
            printf "\r%u: %uM, moved to %s",$n,$moved/1024,$dst;
         } else {
            print " -e $dst\n";
            unlink $f;
            $removed += $size/1024;
            printf "\r%u: %uM, removed %s",$n,$removed/1024,$f;
         }
      }
   }

}
print ".\n";
printf "cursize: %.3fG\n",$cursize/1024/1024;

exit $?;

sub randomly { rand(1.0) > 0.5 ? -1 : 1; }

sub by_time {
 $index->{$a}[0] <=> $index->{$b}[0];
}


sub loadindex {
  my $f = shift;
  my $idx = {};
  local *F;
  open F,'<',$f or warn $!;
  while (<F>) {
    chomp;
    ($mtime,$qm,$size,$f) = split(/\s+/,$_,4);
    $idx->{$qm} = [$mtime,$qm,$size,$f];
  }
  return $idx;
}

1;
