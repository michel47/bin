#!/usr/bin/perl
# $Id: stamped.txt,v 1.0.1 2020-6-30 10:02:24 michelc Exp $
#
# $birth: 1593504220$
# This script replace "added" with timestamp in IPFS log.
#
# usage:
#   ipfs add -r . | perl -S stamped.pl | tee -a added.log
#
# - 4354b @(#) GQU : 30-Jun-20 (MGCM) 10:02:53 - WW26 [b]
#
while (<>) {
  if (/added\s(\w+)\s*(.*)/) {
    my $f = $2;
    chomp($f);
    $f = '../'.$f if (! -e $f && -e "../$f");
    if (-e $f) {
     my ($size,$atime,$mtime,$ctime) = (lstat($f))[7,8,9,10];
     s/added/$mtime/;
    }
  }
  print;
}

exit $?;


1; # $Source: /my/perl/scripts/stamped.pl$
