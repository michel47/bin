#!/usr/bin/perl
#
# Intent:
#  have a script that emulate a simple Jeyll using pandoc
#  only the page.* variable are substitued no "| filter:" !
#
printf "--- # %s\n",$0;
my $file=shift;
my $top = `git rev-parse --show-toplevel`; chomp($top);
printf "top: %s\n",$top;
my ($fpath,$bname,$ext) = &bname($file);
my $content = &readfile($file);
printf "content: %s\n",nonl($content,0,46);
my (undef,$fmatter,$body,undef) = splitmatter($content);
use YAML::XS qw(Load Dump);
my $fm = Load($fmatter);
#printf "--- # fm %s---\n",Dump($fm);
my $buf = jekyllify($fm,$body);
$buf = &markdownify($buf); 
printf "buf: ...%s.\n",&nonl($buf,-16,16);
# get layout ...
my $layoutf = "$top/_layout/$fm->{layout}.html";
my $layout;
if (-e $layoutf) {
  $layout = &readfile($layoutf);
} else {
  $layout = qq'<!DOCTYPE html><meta charset="utf8"/>\n<link rel="stylesheet" href="style.css"><body><div id="container">{{content}}</div></body>';
}
my $html = $layout;
$html =~ s/{{content}}/$buf/;

#my $out = (-e $top/_site) ? "$top/_site/$file" : "$bname.htm_";
my $out = "$bname.htm";

&writefile($out,$html);

exit $?;
# -----------------------------------------
sub markdownify {
  my $buf = shift;
  my $tmpf = "$$.html";
  local *PAN; open PAN,"| pandoc -f markdown -t html -o $tmpf";
  print PAN $buf; close PAN;
  my $htm = &readfile($tmpf); unlink $tmpf;
  return $htm;
}
# -----------------------------------------
sub jekyllify {
  my $map = shift;
  my $buf = shift;
  foreach my $key (reverse sort keys %{$map}) {
    if (ref($map->{$key}) eq '') {
      #printf "s/{{page.%s}}/%s/g\n",$key,$map->{$key};
      $buf =~ s/{{page.$key}}/$map->{$key}/g;
    }
  }
  return $buf;
}
# -----------------------------------------
sub bname { # my ($fpath,$bname,$ext) = &bname($filename);
  #y &intent = "extract basename etc.";
  my $f = shift;
  $f =~ s,\\,/,g; # *nix style !
  my $s = rindex($f,'/');
  my $fpath = ($s > 0) ? substr($f,0,$s) : '.';
  my $file = substr($f,$s+1);

  if (-d $f) {
    return ($fpath,$file);
  } else {
    my $p = rindex($file,'.');
    my $bname = ($p>0) ? substr($file,0,$p) : $file;
    my $ext = lc substr($file,$p+1);
    $ext =~ s/\~$//;

    $bname =~ s/\s+\(\d+\)$//;

    return ($fpath,$bname,$ext);
  }

}
sub readfile { # Ex. my $content = &readfile($filename);
  #y $intent = "read a (simple) file";
  my $file = shift;
  local *F; open F,'<',$file; binmode(F);
  print "// reading file: $file\n";
  local $/ = undef;
  my $buf = <F>;
  close F;
  return $buf;
}
sub writefile { # Ex. &writefile($filename, $data1, $data2);
  #y $intent = "write a (simple) file";
  my $file = shift;
  local *F; open F,'>',$file; binmode(F);
  print "// storing file: $file\n";
  for (@_) { print F $_; }
  close F;
  print ".\n";
  return $.;
}
sub nonl { # remove newline character
  my $buf = shift;
  $buf =~ s/\\n/\\\\n/g;
  $buf =~ s/\n/\\n/g;
  if (defined $_[1]) {
   $buf = substr($buf,$_[0],$_[1]);
  }
  return $buf;
}
sub splitmatter {
  my $content = shift;
  my @lines = split("\n",$content);
  my ($header,$fmatter,$body,$footer) = map {''} (0 .. 2);
  my $section = 0;
  foreach (@lines) {
    if (/^---/) {
      $section++;
      next;
    }
    if ($section == 2) {
      $body .= $_."\n";
    } elsif ($section == 1) {
      $fmatter .= $_."\n";
    } elsif ($section == 0) {
      $header .= $_."\n";
    } else {
      $footer .= $_."\n";
    }
  }
  return ($header,$fmatter,$body,$footer);
}
# -----------------------------------------
1; # $Source: /my/perl/script/easyj.pl $

