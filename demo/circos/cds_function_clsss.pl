#!usr/bin/perl -w
use strict;
#my %color=(
#J=>"255,0,0",A=>"255,153,0",K=>"255,203,47",L=>"255,153,153",B=>"255,179,140",D=>"204,0,51",Y=>"153,51,102",V=>"153,102,153",T=>"255,153,204",M=>"51,204,51",N=>"204,255,255",Z=>"0,255,255",W=>"153,51,153",U=>"204,204,102",O=>"153,204,0",C=>"255,255,0",G=>"153,204,255",E=>"153,204,51",F=>"0,0,255",H=>"204,255,255",I=>"0,255,0",P=>"102,51,0",Q=>"0,51,102",R=>"153,153,153",S=>"51,51,51",);
my %color=(
J=>"FF0000",
A=>"FF9900",
K=>"FFCB2F",
L=>"FF9999",
B=>"FFB38C",
D=>"CC0033",
Y=>"993366",
V=>"996699",
T=>"FF99CC",
M=>"33CC33",
N=>"CCFFFF",
Z=>"00FFFF",
W=>"993399",
U=>"CCCC66",
O=>"99CC00",
C=>"FFFF00",
G=>"99CCFF",
E=>"99CC33",
F=>"0000FF",
H=>"CCFFFF",
I=>"00FF00",
P=>"663300",
Q=>"003366",
R=>"999999",
S=>"333333",
);
my $class_file =shift;
my $gtf=shift;
my $prefix=shift;
my %class;
open IN,$class_file or die $!;
<IN>;
while (<IN>)
{
	chomp;
	my @a=split /\t/,$_;
	foreach my $i (2 .. $#a)
	{
		my @b=split /\,/,$a[$i];
		if (exists $color{$a[0]}){
			$class{$b[0]}=$color{$a[0]};
		}
	}
}
close IN;

open IN,$gtf or die $!;
open OUT1, ">$prefix/plus.txt" or die $!;
open OUT2, ">$prefix/minus.txt" or die $!;
while (<IN>)
{
	chomp;
	next if /^#/;
	my @a=split /\t/,$_;
	if ($a[2] eq "mRNA" && $a[8] =~/ID=(.*?);/)
	{
		my $id=$1;
		if (exists $class{$id})
		{
			if ($a[6] eq "+")
			{
				print OUT1 "$a[0] $a[3] $a[4] fill=$class{$id}\n";	
			}		
			else
			{
				print OUT2 "$a[0] $a[3] $a[4] fill=$class{$id}\n";
			}
		}
		else
		{
			if ($a[6] eq "+")
			{
				print OUT1  "$a[0] $a[3] $a[4] fill=333333\n";
			}
			else
			{
				print OUT2 "$a[0] $a[3] $a[4] fill=333333\n";
			}
		}
		
	}
}
close IN;
