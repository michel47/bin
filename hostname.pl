#!/usr/bin/perl

our $dbug=0;
#understand variable=value on the command line...
eval "\$$1='$2'"while @ARGV&&$ARGV[0] =~ /^(\w+)=(.*)/ && shift;

use Socket;

printf "--- # %s\n",$0;
my ($name, $aliases, $addrtype, 
      $length, @addrs) = gethostbyname 'localhost';
push @addrs, pack'C4',split'\.',&get_localip();
if ($dbug) {
print "# host name is $name\n";
print "# aliases are $aliases\n";
printf "# addrs are %s\n",join' ', map { join'.',unpack'C4',$_; } @addrs;
}

my $addr =  pack'C4',split'\.','192.168.42.146';

my ($name,$aliases,$addrtype,$l,@a) = gethostbyaddr($addr,$addrtype);
printf "name: %s\n",$name;
printf "aliases: %s\n",$aliases||'~';
printf "atype: %s\n",$addrtype;
printf "length: %s\n",$length;
printf "addrs: [%s]\n",join', ',map { join'.',unpack'C4',$_; } @a;

exit $?;

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
    return '127.0.0.1' unless $socket;

    my $local_ip = $socket->sockhost;

    return $local_ip;
}
# ---------------------------------------------------------
1;
