#!/usr/bin/perl
# $Id: moustache.pl,v 1.0 2018/09/03  9:43:16 iglake Exp $
#-------------------------------------------------------
#-- Iggy G. Lake                                      --
#--                                                   --
#-- All contents copyright (C) 2018, 2019, 2020       --
#-- All rights reserved                               --
#-- contact: iggyl@one-♡.tk                           --
#--                                                   --
#-------------------------------------------------------

# moustache 7451c @(#) IPHuO : 7 -Nov-18 (IGLK) 11:53:57 - WW45 [c]
#
# Revision history :
# . 7451~ : re-factored for pmd flow
#
# 1519026565 : Idea of moustashe preprocessor
#
our $dbug = 0;
my ($red,$nc) = ('[31m','[0m');

my $HOME = $ENV{HOME} || '/home/'.$ENV{USERNAME};
#--------------------------------
# -- Options parsing ...
#
while (@ARGV && $ARGV[0] =~ m/^-/)
{
  $_ = shift;
  #/^-(l|r|i|s)(\d+)/ && (eval "\$$1 = \$2", next);
  if (/^-v(?:erbose)?/) { $verbose= 1; }
  elsif (/^-o([\w.]*)/) { $outfile= $1 ? $1 : shift; }
  else                  { die "Unrecognized switch: $_\n"; }

}
#understand variable=value on the command line...
eval "\$$1='$2'"while $ARGV[0] =~ /^(\w+)=(.*)/ && shift;

# load md file and replace {{.*}}
my $file = shift;
my ($fpath,$fname,$bname,$ext) = &fname($file);
printf "// [INFO]: fpath=%s\n",$fpath if $info;
if (! -e $file && $ext eq '') {
   $ext = 'mdx';
   $fname = $bname . '.' . $ext;
   $file =$fpath . '/' . $bname . '.' . $ext;
}
# -------------------------------------------------
# get the destination file name
my $target;
if (defined $outfile) { # passed as -o option
  $target = $outfile;
} elsif ($ARGV[0]) { # passed a second arguments
  $target = $ARGV[0];
} else {
  $target = $file; $target =~ s/\.$ext/.md/;
}
# -------------------------------------------------

# 1) extract yaml data :
my $yml = &extract_yml($file);
if (0) {
my $ymlf = $target; $ymlf =~ s/\.[^\.]+$//; $ymlf .= '.yml.txt';
use YAML::Syck qw(DumpFile); DumpFile($ymlf,$yml);
}

printf "yml: %s.\n",Dump($yml) if $dbug;
# DATE AND TIME
$yml->{TICS} = $^T;
##     0    1     2     3    4     5     6     7
#y ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday)
my ($mon,$day,$yy) = (localtime($yml->{TICS}))[4,3,5];
my $yr4 = $yy + 1900;
my $LMoY = [qw( January February March April May June July August September October November December )];
$yml->{DATE} = sprintf"%s %2d, %4d",$LMoY->[$mon],$day,$yr4;
$yml->{HDATE} = &hdate($yml->{TICS});
$yml->{PREVMONTH} = $LMoY->[($mon+11) % 12];
$yml->{MONTH} = $LMoY->[$mon];
$yml->{YR4} = $yr4;
$yml->{YR2} = $yy % 100;
$yml->{TODAY} = &hdate($^T);


# DEFAULT SUBSTITUTION for YML substitution
$yml->{WWW} = $ENV{WWW};
$yml->{SEARCH} = 'https://seeks.hsbp.org/?language=en&engines=google,duckduckgo,qwant,ixquick,startpage&q';
$yml->{SEARX} = 'https://ipfs.gc-bank.tk/ipns/searx.neocities.org/?q';
$yml->{SEARXES} = 'https://searxes.danwin1210.me/?lg=en-US&search_this';
$yml->{SIMIL} = 'http://www.google.com/searchbyimage?btnG=1&hl=en&image_url';
$yml->{GOO} = 'http://google.com/search?bti=1&q';
$yml->{DUCK} = 'http://duckduckgo.com/?q'; # <---


$yml->{IPROXY} = 'http://ipns.co';

$yml->{GW} = 'http://gateway.ipfs.io';
$yml->{ZGW} = 'http://0.0.0.0:8080';
$yml->{GCGW} = 'http://ipfs.gc-bank.tk';
$yml->{'2GGW'} = 'http://ipfs.2gether.cf';
$yml->{IPH} = 'http://iph.heliohost.org/IPHS';
$yml->{AHE} = 'http://iph.heliohost.org/AHE';

$yml->{HELIO} = 'http://iph.heliohost.org';
$yml->{IPNS} = 'http://iph.heliohost.org/ipns';
$yml->{IMAGES} = 'http://iph.heliohost.org/ipns/images';

$yml->{SAVE} = 'https://web.archive.org/save';
$yml->{GT} = 'https://translate.google.com/translate?sl=auto&tl=en&js=y&prev=_t&hl=en&ie=UTF-8&u';


# Symbols
$yml->{'TM'} = '&trade;';
$yml->{'SM'} = '&#8480;';
$yml->{'<3'} = '&#9825;';
$yml->{':)'} = '&#9786;';

# Redirects
$yml->{'URL'} = 'https://www.google.com/url?q';
$yml->{'URL'} = 'https://getpocket.com/redirect?url';
$yml->{'URL'} = 'https://duck.co/redir/?u=';
$yml->{'URL'} = 'https://ad.zanox.com/ppc/?32249347C62314846&ulp=%5B%5B%%s%5D%5D';
$yml->{'FB'} = 'https://l.facebook.com/l.php?u=';
$yml->{'WB'} = 'https://web.archive.org/web/';


# Maps & charts example :
# https://maps.googleapis.com/maps/api/staticmap?autoscale=2&size=600x300&maptype=roadmap&format=png&visual_refresh=true&markers=icon:https://chart.googleapis.com/chart?chst=d_bubble_icon_text_small%26chld=ski%257Cbb%257cIggy%2520L%257cffffff%257cff0000%7Cshadow:true%7CEcublens,CH
#
# maps : see [1](https://staticmapmaker.com/google/) 
$yml->{MAPS} = 'https://maps.googleapis.com/maps/api/staticmap?center=45.0%2c4.0&zoom=5&size=700x500';
# https://maps.googleapis.com/maps/api/staticmap?center=Albany,+NY&zoom=3&scale=2&size=600x300
#   &maptype=roadmap&format=png&visual_refresh=true
#    &markers=size:mid%7Ccolor:0xff0000%7Clabel:1%7CAlbany,+NY
#    &markers=size:small%7Ccolor:0x2700ff%7Clabel:2%7C2nd+marker
# pins (?=%3F, &=%26, #=%23 %=%25 @=%40 "=%22 '=%27 |=%7C
# https://chart.googleapis.com/chart?chst=d_bubble_icon_text_small&chld=
# charts : see [2](https://developers.google.com/chart/infographics/docs/dynamic_icons)
$yml->{CHART} = 'https://chart.googleapis.com/chart?cht=qr&chs=222x222&choe=UTF-8&chld=H&chl';

# FAVICONS 
$yml->{FAVI} = 'https://www.google.com/s2/favicons?domain';

# 2) read file
local *S; open S,'<',$file;
local $/ = undef; my $buf = <S>; close S;

# 2a) flatten all include
 $buf = &includes($buf);

# 3) make substitution :
my $c = 0;
my $s = &substi($yml,$buf);
if ($s) {
  $c = $s;
  printf "c:%d (yml)\n",$c;
}

# load include file too ...
my @list = ();
if (exists $yml->{moustache}) {
  if (ref $yml->{moustache} eq 'ARRAY') {
    push @list, @{$yml->{moustache}};
    printf "list: %s.\n",join',',@list if $dbug;
  } else {
    push @list, $yml->{moustache};
  }
} else {
  # add yml file if exists ...
  my $ymlf = $file; $ymlf =~ s/\.$ext/.yml/;
  if (-e $ymlf) {
    push @list, $ymlf;
  }

}


  foreach my $y (@list) {
     $y =~ s/\{\{([^}]+)\}\}/$yml->{$1}/g; # do subs on list elements
     while ($y =~ m/\$\{?([^\$]+?)\}?\b/g) {
       my $var = $1;
       #print "y =~ s,\${$var},$ENV{$var},\n";
       $y =~ s,\$\{?$var\}?,$ENV{$var}, if (exists $ENV{$var}); # do env subs too 
     }
     if (-e $y) {
        print " loading $y\n";
        my $yml = &extract_yml($y);
        my $s = &substi($yml,$buf);
        if ($s) { 
           $c += $s;
           printf "c:%d (${y}'s)\n",$c;
        }
     } else {
       printf " ! -e %s\n",$y if $dbug;
     }
  }

my $keys = &get_keylist();
#foreach (grep !/ID$/, keys %$key) { $keys->{$_.'ID'} = $keys->{$_}; # keyname alias !  }
my $s = &substi($keys,$buf);
if ($s) {
   $c += $s;
   printf "c:%d (keys's)\n",$c;
}

# 4) write file
if ($file eq $target) { # /!\ DANGEROUS 
   print "// ${red}/!\\${nc} CAUTION $file is rename to $file~\n";
   unlink "$file~"; rename $file,"$file~";
}
print "// moustache: -> $target\n";
open *T; open T,'>',$target;
print T $buf;
close T;



exit $?;

# -----------------------------------------------------
sub get_keylist {
   my $keylist = {};
   my $cmd = sprintf 'ipfs key list -l';
   local *EXEC; open EXEC,"$cmd|" or die $!;
   local $/ = "\n";
   while (<EXEC>) {
     chomp();
     my ($mhash,$key) = split(/\s+/,$_);
     $keylist->{$key.'ID'} = $mhash;
   }
   return $keylist;
   
}
# -----------------------------------------------------
sub includes { # flatten {{#include file}} code
  my $data = shift;
  for $mus (split("\}\}",$data)) { # each moustache
    if ($mus =~ m/\{\{#include\s+([^}]+)$/) { #}
      my $incf = $1;
      if (-e $incf) {
        local *F;
        open F,'<',$incf;
        local $/ = undef;
        my $buf = <F>;
        close F;
        $data =~ s/\{\{#include\s+$incf}}/$buf/; # }}
      }
      
    }
 }
 return $data;
}
# -----------------------------------------------------
sub substi { # inplace (buf) substitution ...
  my $yml = shift;
  my $bufref = \$_[0];
  my $c = 0;
  return unless (ref($yml) eq 'HASH');
  foreach my $key (reverse sort keys %$yml) {
    my $pat = $key;
    $pat =~ s/-/\\-/g;
    $pat =~ s/([()])/\\$1/g;
    next if (ref $yml->{$key} eq 'ARRAY');
    #printf "ref: %s\n",ref($yml->{$key});
    #next unless (ref $yml->{$key} eq '');
    my $value = $yml->{$key};
    print "{{$pat}} -> $value\n" if ($$bufref =~ m/\{\{$pat\}\}/);
    $c += $$bufref =~ s/\{\{$pat\}\}/$value/g;
  }
  return $c;
}

# -----------------------------------------------------
sub extract_yml {
   my $file = shift;
   die "! -e $file" if ! -e $file;
   local *F; open F,'<',$file or die $!;
   local $/ = "\n";
   my $isyml = 0;
   my $yml = '';
   while (<F>) {
     tr/\r//d;
      if (/^---\s(?:#.*)?$/) {
         $isyml = 1;
      }
      if ($isyml == 1) {
         print "DBUG> $_" if $dbug;
         $yml .= $_;
         if (/^[\.\-]{3}$/) { $isyml = 0; }
      }
   }
   close F;
   $yml =~ s/[\.\-]{3}\r?\n---\s?(?:#[^\n]*)?\r?\n//gs;
   #print "YAML: \"$yml\"\n";
   use YAML::Syck qw(Load Dump);
   my $dump = $file.'.xtr.yml';
   if ( $yml ne '' ) {
      local *F; open F,'>',$dump;
      print F $yml;
      close F; 
   }
   my $data = Load($yml);
   if (defined $data) {
     unlink $dump unless $dbug;
   }
   return $data;
}

# -----------------------------------------------------
sub fname { # extract filename etc...
  my $f = shift;
  $f =~ s,\\,/,g; # *nix style !
  my $s = rindex($f,'/');
  my $fpath = '.';
  if ($s > 0) {
    $fpath = substr($f,0,$s);
  } else {
    use Cwd;
    $fpath = Cwd::getcwd();
  }
  my $file = substr($f,$s+1);

  if (-d $f) {
    return ($fpath,$file);
  } else {
  my $p = rindex($file,'.');
  my $bname = ($p>0) ? substr($file,0,$p) : $file;
  my $ext = lc substr($file,$p+1);
     $ext =~ s/\~$//;

  $bname =~ s/\s+\(\d+\)$//; # remove (1) in names ...

  return ($fpath,$file,$bname,$ext);

  }
}
# -----------------------------------------------------
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
# -----------------------------------------------------
1; # $Source: /my/perl/scripts/moustache.pl,v $
