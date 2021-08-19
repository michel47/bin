#!/usr/bin/perl -w

# SopPasswd: A generator for Sort-of-pronounceable passwords.
# Version: 0.1
# Author: Mark A. Pors, mark@dreamzpace.com, www.dreamzpace.com
# License: GPL

use strict;

my $dict = '/usr/share/dict/words';       # path to dict file
my $wordlen = 8;                    # desired length of the password
my $numwords = 10;                 # number of passwords to print
my $sublen = 3;                     # length of the word chunks that create the password
my $sep = "\n";                     # how to separate the words

my @dict;

$wordlen >= $sublen || die "Error: The word length should be equal or larger than the length of the 'chunks'\n";

open (DICT, "<$dict") || die ("Cannot open dict: $!");
while (<DICT>) {
    chomp;
    push (@dict, $_);
}

while (1) {

    my @sub = ();
    my $word;
    my $parts = int ($wordlen/$sublen);

    for (1 .. $parts) {
        my $try = $dict[rand @dict];
        redo if length($try) < $sublen;
        $word .= lc substr($try, 0, $sublen);
    }

    my @chars = split(m{}xms, $word);
    my $upper = rand @chars;
    $chars[$upper] = uc $chars[$upper];
    $word = join(q{}, @chars);

    my $left = $wordlen % $sublen;
    $word .= substr (int rand (10**($wordlen - 1)), 0, $left);

    print $word . $sep;
    chomp (my $exit = <STDIN>);

}
