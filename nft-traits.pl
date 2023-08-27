#!perl

# intent take an yaml as STDIN
# take a do files from argument, and evaluate them
# spew out a (canonical) json ...

push @INC,'.';

use YAML::XS qw(Load Dump);
use JSON::XS qw();

local $/ = undef;
my $yaml = <STDIN>;

my ($fmatter,$yin) = Load($yaml);
printf STDERR "--- front-matter %s...\n",Dump($fmatter);
printf STDERR "--- yaml %s...\n",Dump($yin);


foreach my $key (reverse sort keys %$fmatter) {
  my $value = $fmatter->{$key};
  $yaml =~ s/\${$key}/$value/g;
}
($fmatter,$yin) = Load($yaml); # reload after substitution
our $_ = $yin;

while (@ARGV) {
  my $dofile = shift;
  if ( -e $dofile ) {
    printf STDERR "// executing %s file\n",$dofile;
    do "$dofile";
  }
}

if (exists $_->{attributes}) {
  my $traits = [];
  foreach my $a (@{$_->{attributes}}) {
    next if (exists $a->{trait_type});
    my $type = (keys %$a)[0];
    my $trait_type = $type; $trait_type =~ s/_/ /g;
    my $value = $a->{$type};
    push @{$traits}, { trait_type => $trait_type, value => $value };
  }
  $_->{attributes} = $traits;
}


#JSON::XS->new->utf8->pretty->canonical->encode ($_)
my $json = JSON::XS->new->pretty->canonical; # canonical : sort keys
print $json->encode($_);

exit $?;

1;
