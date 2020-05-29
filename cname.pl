#!/usr/bin/perl

# script generates a canonical name for an ipfs resource
#
# Modules deps:
#  File::Type
#  Digest::MurmurHash
#
#  install:
# export PERL5LIB=$HOME/.hlrings/perl5/lib/perl5
# perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e 'CPAN::install(YAML)'
# perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e 'CPAN::install(File::Type)'
# perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e 'CPAN::install(Digest::MurmurHash)'
#
# perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e 'CPAN::install(Digest::MD6)'
# if error: correct Devel/CheckLib.pm
# perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e 'CPAN::install(Devel::CheckLib)'
# ~/.cpan/build/Digest-MD6-0.11-1
# mv inc _inc
# vi MANIFEST (comment inc/Devel/CheckLib line)
# perl -Mlocal::lib=${PERL5LIB%/lib/perl5} Makefile.PL


use lib $ENV{SITE}.'/lib';
use YAML::Syck qw(Dump);
use UTIL qw(digest shake version encode_base42 encode_base58f encode_base58 encode_basen word5 word fname etime get_type get_ext rev fdow);
use IPFS qw(ipfsapi);

#printf "INC: \n\t%s\n",join"\n\t",@INC; exit $?;

our $dbug = 0;
#understand variable=value on the command line...
eval "\$$1='$2'"while $ARGV[0] =~ /^(\w+)=(.*)/ && shift;

# caching dir...
my $cachedir = "$ENV{HOME}/var/cache";
mkdir "$ENV{HOME}/var" unless -d "$ENV{HOME}/var";
mkdir $cachedir unless -d $cachedir;
my ($fpath,$file,$bname,$ext);
if (@ARGV) {
    $file = shift;
   ($fpath,$fname,$bname,$ext) = &fname($file);
} else {
  $file = '-';
  $fpath = '/dev';
  $fname = 'stdin';
  $bname = 'stdin';
  $ext = 'blob';
}
printf "--- # %s (v%s)\n",$0,&version($0);
printf "file: '%s'\n",$file;
printf "fpath: '%s'\n",$fpath;
printf "fname: '%s'\n",$fname;
printf "bname: '%s'\n",$bname;
printf "ext: '%s'\n",$ext;

my $etime = (-e $file) ? &etime($file) : $^T;
printf "etime: %s\n",$etime;
my ($sec,$min,$hour,$mday,$mo,$yy,$yday) = (localtime($etime))[0..5,7];
my ($yr4,$yr2,$mon,$wk) =($yy+1900,$yy%100,$mo+1,($yday+&fdow($etime))/7);
my $stamp = sprintf '%04u/%02u/%02u/T%02u%02u%02u',
             $yr4,$mon+1,$mday, $hour,$min,$sec;
printf "stamp: %s\n",$stamp;

my ($m,$r) = &rev($etime);
my $rel = sprintf '%.1f.%d',,int($m/10)/10,$m%10+$r;
printf "rel: %s\n",$rel;

if (-d $file) {
  $bindata = { type => 'dir', path => $file };
} else {
   local *IN;
   if (-r $file) {
      print "x-info: -r $file\n";
      open IN,'<',$file;
   } else {
      print "x-info: reading stdin\n",
      open IN,'<&','STDIN';
   }
   local $/ = undef;
   $bindata = <IN>;
   close IN;
}



my $ns = sprintf "blob %u\0",length($bindata);
my $md6 = &digest('MD6',$bindata);
my $git = &digest('SHA1',$ns,$bindata);

my $id7 = substr(unpack('H*',$git),0,7);
my $nu = hex($id7);
my $pn = unpack'n',substr($md6,-2); # 16-bit
my $word = &word($pn);
my $n2 = sprintf "%09u",$nu; $n2 =~ s/(....)/\1_/;



printf "md6: %s\n",unpack'H*',$md6;
printf "git: %s\n",unpack'H*',$git;
printf "id7: %s\n",$id7;
printf "nu: %d\n",$nu;
printf "pn: %d\n",$pn;
printf "word: %s\n",$word;
printf "n2: %s\n",$n2;

my $sha1 = &digest('SHA1',$bindata);
my $sha2 = &digest('SHA-256',$bindata);
printf "sha1: %s\n",unpack'H*',$sha1;
printf "sha2: %s\n",unpack'H*',$sha2;
my $shake = &shake(224,$bindata);
printf "bin: %s\n",unpack'H*',$bindata if (length($bindata) <= 128);
printf "sh16: %s\n",unpack'H*',$shake;
printf qq'sh37: "*%s*"\n',&encode_basen($shake,37);
printf qq'sh39: "*%s*"\n',&encode_basen($shake,39);
printf "sh42: '*%s*'\n",&encode_base42($shake);
printf "sh58f: %s\n",&encode_base58f($shake);
printf "sh62: %s\n",&encode_basen($shake,62);
printf "sh63: %s\n",&encode_basen($shake,63);
printf "z83: z%s\n",&encode_base58("\x01\x55\x11\x14".$sha1);

# N2 sub(d,-4,3)
# SHA3 sub(x,-4,3)
# ZB2 sub(q,-3,2)
# 65K sub(b,-5,2)
# PN5
# W5L sub(w,-3,2)
# id7 sub(i,-3,2)

my @N = unpack'N*',$shake;
my @W7 = map { &word5($_); } @N;
printf "w7: [%s]\n",join', ',@W7;
my @n = unpack'n*',$shake;
my @w14 = map { &word($_); } @n;
printf "w14: [%s]\n",join', ',@w14;

my $wid = $w14[-2];
printf "wid: %s\n",$wid;
my $name = sprintf '%s.%s',$bname,$ext;
my $cname = sprintf '%s.%s',$wid,$ext;
printf "cname: %s\n",$cname;
my $fname = substr($name,1); $fname =~ tr/a-z//dc; $fname =~ tr/aeiouy//d;
   $fname = substr($name,0,1). substr($fname,0,2) . '-' . $cname;


printf "uname: %s\@v%s/%s\n",$wid,$rel,$name;
# caching file :
my $cachef = &cache($cname,$bindata);
my $mh = &ipfsadd($cachef);
printf "# ipfs-add %s",Dump($mh);

# /files/store/$cname
my $cpath = sprintf '/files/store/%s',$wid;
printf "canonical-file: %s/%s\n",$cpath,$name;
&file($mh->{qm},$cpath,$name);
# /var/timeline/date/fname
my $dpath = sprintf '/var/timeline/%04u/%02u/%02u',$yr4,$mon,$mday;
printf "dated-file: %s/%s\n",$dpath,$fname;
&file($mh->{qm},$dpath,$fname);
# /root/global/type/year/rel/$cname
my $type = &get_type($cachef);
printf "type: %s\n",$type;
my $gpath = sprintf '/root/global/%s/%04u/v%s',$type,$yr4,$rel;
printf "global-file: %s/%s\n",$gpath,$cname;
&file($mh->{qm},$gpath,$cname);
# /var/history/week/rname
my $rpath = sprintf '/var/history/weeks/W%02u',$wk;
my $rname = sprintf '%s-v%s_%s.%s',$bname,$rel,$wid,$ext;
printf "released-file: %s/%s\n",$rpath,$rname;
&file($mh->{qm},$rpath,$rname);


exit $?;
1;

sub cache {
 my ($key,$data) = @_;
 my $p = rindex($key,'.'); $p = 0 if ($p<0);
 my $shard = sprintf'%s/%s',$cachedir,substr($key,$p-3,2);
 mkdir $shard unless -d $shard;
 my $cachef = sprintf '%s/%s',$shard,$key;
 if (-e $cachef) {
   $mtime = (lstat($cachef))[9];
   if (($^T - $mtime) > 3600) {
     printf "x-info: rm %s\n",$cachef;
      unlink $cachef;
   } else {
     printf "hit-cache-file: %s\n",$cachef;
   }
 }
 if (! -e $cachef) {
    printf "miss-cache-file: %s\n",$cachef;
    local *F; open F,'>',$cachef;
    binmode(F); print F $data ; close F;
 }
 return $cachef;
}
  

sub ipfsadd {
 my $f = shift;
 my $p = rindex($f,'/');
 my $b = substr($f,$p+1);
 return { 'wrap' => 'z6cYNbecZSFzLjbSimKuibtdpGt7DAUMMt46aKQNdwfs' } unless -r $f;
 open EXEC,sprintf 'ipfs add -w %s --raw-leaves --cid-base=base58btc --progress=false --pin=false |',$f;
 my $mh = {};
 local $/ = "\n";
 while (<EXEC>) {
    chomp;
    if (m/added (\w+) (.*)/) {
       if ($2 eq '') {
          $mh->{wrap} = $1;
       } elsif ($2 eq $b) {
          $mh->{qm} = $1;
       } else {
          $mh->{$2} = $1;
       }
    }
 }
 close EXEC;
 return $mh;
}

sub file {
 my ($qm,$p,$n) = @_; # qmhash parent-dir, newname
 my $f = $p .'/'. $n;
 print "cname-file: $qm $f\n" if $dbug;
 my $mh = &ipfsapi('files/stat',$p,'&hash=1'); # test directory 
 if ($dbug && ! exists $mh->{Code}) {
     printf "info: dir p=%s exists\n",$p;
 }
 if (exists $mh->{Code}) {
   print "ipfs-api-files: mkdir $p\n" if $dbug;
   my $mh = &ipfsapi('files/mkdir',$p,'&parents=1&cid-version=0'); # create it if necessary
   if (exists $mh->{Code}) { printf "%s: %d -- %s: %s\n",$mh->{Type},$mh->{Code},$p,$mh->{Message}; }
 } else { # dir $p exists
   my $mh = &ipfsapi('files/stat',$f,'&hash=1'); # test directory 
   if (! exists $mh->{Code}) {
      print "ipfs-api-files: rm $f\n" if $dbug;
      my $mh = &ipfsapi('files/rm',$f,'&recursive=0');
      if ($dbug && exists $mh->{Code}) { printf "%s: %d -- %s: %s\n",$mh->{Type},$mh->{Code},$f,$mh->{Message}; }
   }
 }
 my $mh = &ipfsapi('files/cp',"/ipfs/$qm",'&arg='.$f);
   print "ipfs-api-files: cp /ipfs/$qm $f\n" if $dbug;
   if (exists $mh->{Code}) { printf "%s: %d -- %s\n",$mh->{Type},$mh->{Code},$mh->{Message}; }

}

1;
