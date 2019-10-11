#!/Bio/bin/perl
#-----------------------------------------------+
#    [APM] This script was created by amp.pl    |
#    [APM] Created time: 2019-07-18 14:42:34    |
#-----------------------------------------------+
# name: creat.pl
# func: 
# version: 1.0

use strict;
use warnings;
use List::Util qw/min max/;

<>;

my @numbers;
my @records;

while(<>){
    chomp;
    my @vals = split /\t/ , $_;
    my $id = (split /\s/ , $vals[0])[0];
    my $qv = -log($vals[2])/log(10);

    push @records , [$id,$vals[1],$qv];
    push @numbers , $vals[1];

    last if ($. == 22);
}

my $min = min(@numbers);
my $max = max(@numbers);
my $width = $max - $min;

my $s0 = 20;
my $s1 = 40;
my $size = $s1 - $s0;

foreach (@records)
{
    my ($id,$number,$qv) = @$_;
    my $r = ($number - $min)/$width;
    my $s = $s0 + $size * $r;
    my $color = qv2color($qv);
    print "$id\t1\t1000\t0.5\tradius=$s;fill=$color;val=$number;\n";
}

sub qv2color {
    my $qv = shift;

    my $color = $qv < 1.3  ? "000"     : 
                $qv < 2    ? "vlred"   : 
                $qv < 5    ? "lred"    :
                $qv < 10   ? "red"     :
                $qv < 15   ? "dred"    : 
                $qv < 20   ?  "vdred"  : "vvdred";

    return $color;

}
