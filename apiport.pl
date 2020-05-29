#!/usr/bin/perl

my $webui = '/ipfs/QmfQkD8pBSBCBxWEwFSu4XaDVSWK6bjnNuaWZjMyQbyDub';
   $webui = "/ipfs/QmQLXHs7K98JNQdWrBB2cQLJahPhmupbDjRuH1b9ibmwVa";
   #$webui = "/ipfs/QmRUZjv8AQV2MsRHY1BUdyGjWmod4pp4eTY94SqpJuiM1y";
   $webui = "/ipfs/QmPhnvn747LqwPYMJmQVorMaGbMSgA7mRRoyyZYz3DoZRQ";
   #$webui = "/ipfs/QmfQkD8pBSBCBxWEwFSu4XaDVSWK6bjnNuaWZjMyQbyDub";
   #$webui = "/ipns/webui.ipfs.io/";

my ($apihost,$apiport) = &get_apihostport();
my $proto = ($apiport == 443) ? 'https' : 'http';
printf 'url: %s://%s:%s%s'."\n",$proto,$apihost,$apiport,$webui;
exit $?;

sub get_apihostport {
  my $IPFS_PATH = $ENV{IPFS_PATH} || $ENV{HOME}.'/.ipfs';
  my $conff = $IPFS_PATH . '/config';
  local *CFG; open CFG,'<',$conff or warn $!;
  local $/ = undef; my $buf = <CFG>; close CFG;
  use JSON qw(decode_json);
  my $json = decode_json($buf);
  my $apiaddr = $json->{Addresses}{API};
  my (undef,undef,$apihost,undef,$apiport) = split'/',$apiaddr,5;
      $apihost = '127.0.0.1' if ($apihost eq '0.0.0.0');
  return ($apihost,$apiport);
}

sub get_gwhostport {
  my $IPFS_PATH = $ENV{IPFS_PATH} || $ENV{HOME}.'/.ipfs';
  my $conff = $IPFS_PATH . '/config';
  local *CFG; open CFG,'<',$conff or warn $!;
  local $/ = undef; my $buf = <CFG>; close CFG;
  use JSON qw(decode_json);
  my $json = decode_json($buf);
  my $gwaddr = $json->{Addresses}{Gateway};
  my (undef,undef,$gwhost,undef,$gwport) = split'/',$gwaddr,5;
      $gwhost = '127.0.0.1' if ($gwhost eq '0.0.0.0');
  my $url = sprintf'http://%s:%s/ipfs/zz38RTafUtxY',$gwhost,$gwport;
  use LWP::UserAgent qw();;
  my $ua = LWP::UserAgent->new();
  my $resp = $ua->get($url);
  if ($resp->is_success) {
    return ($gwhost,$gwport);
  } else {
    return ('ipfs.blockringtm.ml',443);
  }
}

1; # $Source: /my/perl/scripts/apiport.pl $
