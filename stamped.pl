#!/usr/bin/perl
# $Id: stamped.pl,v 1.9.7 2020-12-15 13:32:17 michelc Exp $
#
# $birth: 1593504220$
# This script replace "added" with timestamp in IPFS log.
#  and add the file size before its name
#
# usage:
#   ipfs add -r . | perl -S stamped.pl | tee -a added.log
#
# - 8389b @(#) GQU : 15-Dec-20 (MGC.) 13:32:56 - WW50 [b]
#
my $ptime = time;
while (<>) {
  if (/added\s(\w+)\s*(.*)/) {
    my $f = $2;
    chomp($f);
    if ("$f" eq '') {
       s/added/$ptime/;
    } else {
       my $fr = $f; $fr =~ s/([(\[\$\+\?\])])/\\$1/g;
       if (! -e $f && -e "../$f") {
         s,$fr,../$f,;
         $f = '../'.$f;
         $fr = '../'.$fr;
       }
       if (-d $f && $f !~ m,/$,) {
         s,$fr,$f/,;
         $f = $f.'/';
         $fr = $fr.'/';
       }
       if (-e $f) {
          my ($size,$atime,$mtime,$ctime) = (lstat($f))[7,8,9,10];
          s/added/$mtime/;
          s,$fr,$size $f,;
          $ptime = $mtime;
       } else {
          my $tics = time;
          s/added/$tics/;
          s,$fr,-1 $f,;
       }
    }
  }
  print;
}

exit $?;


1; # $Source: /my/perl/scripts/stamped.pl$
