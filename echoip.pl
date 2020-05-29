#!/usr/bin/perl

# simpler server that return the ip address of the client ...
my $port = shift || 12701;

use IO::Socket;
my $server = new IO::Socket::INET(Proto => 'tcp',
                                  LocalPort => $port,
                                  Listen => SOMAXCONN,
                                  Reuse => 1);
$server or die "Unable to create server socket: $!" ;
while (my $client = $server->accept()) {
   my $sink = <$client>; # read;
   my $serveraddr = join'.',unpack'C4',$client->sockaddr();
   my $remoteaddr = join'.',unpack'C4',$client->peeraddr();
   print $client "HTTP/0.9 200\r\n"; 
   #print $client "Xtics: ",$^T,"\r\n";
   print $client "Content-Type: text/plain\r\n"; 
   print $client "\r\n";
   printf $client "--- # %s\n",$0;
   printf $client "tics: %s\n",$^T;
   printf $client "remote_addr: %s\n",$remoteaddr;
   printf $client "server_addr: %s\n",$serveraddr;
   close $client;
}

exit $?;

1;




