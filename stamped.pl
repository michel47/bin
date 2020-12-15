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
       if (! -e $f && -e "../$f") {
         s,$f,../$f,;
         $f = '../'.$f;
       }
       if (-d $f && $f !~ m,/$,) {
         s,$f,$f/,;
         $f = $f.'/';
       }
       if (-e $f) {
          my ($size,$atime,$mtime,$ctime) = (lstat($f))[7,8,9,10];
          s/added/$mtime/;
          s,$f,$size $f,;
          $ptime = $mtime;
       } else {
          my $tics = time;
          s/added/$tics/;
       }
    }
  }
  print;
}

exit $?;


1; # $Source: /my/perl/scripts/stamped.pl$
