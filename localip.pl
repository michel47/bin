#!/usr/bin/perl
# $Id: localip.pl,v 0.0 2018/04/08 07:23:57 michelc Exp $

use strict;
# $ENV{TZ} = 'PST8PDT';

my $nip;
my $dotip;
my $dynip;

   $dotip = &get_localip();
   print $dotip,"\n";
   $nip = unpack'N',pack'C4',split('\.',$dotip);
   exit $nip;

# ---------------------------------------------------------
sub get_localip {
    use IO::Socket::INET qw();
    # making a connectionto a.root-servers.net

    # A side-effect of making a socket connection is that our IP address
    # is available from the 'sockhost' method
    my $socket = IO::Socket::INET->new(
        Proto       => 'udp',
        PeerAddr    => '198.41.0.4', # a.root-servers.net
        PeerPort    => '53', # DNS
    );

    my $local_ip = (defined $socket) ? $socket->sockhost : '127.0.0.1';

    return $local_ip;
}
  
# -----------------------------------------------------------------------
1; # vim: ts=2 sw=3 et ai ff=unix
