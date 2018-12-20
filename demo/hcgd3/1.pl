use strict;
use warnings;

our %aln;
open IN,"../2.classify/class.xls";
while (<IN>){
		chomp;
		my ($id,undef,$class)=split /\t/;
		$id=~s/\..//;
		my $flag;
		if ($class=~/R2R3/){
				$flag='blue';
		}elsif ($class=~/atypical/){
				$flag='red';
		}elsif ($class=~/MYB-related/){
				$flag='green';
		}else{
				die "$id\n";
		}
		if (exists $aln{$id}){
				die "$id\t$flag\t$aln{$id}\n" if  $aln{$id} ne $flag;
		}else{
				$aln{$id}=$flag;
		}
}
close IN;

open IN,"l.gene.gff";
open OUT,">l.gene.txt";
while (<IN>){
		chomp;
		my ($chr,$start,$end,$id)=(split /\t/)[0,3,4,8];
		$id=~s/;.+//;
		$id=~s/ID=//;
		print OUT "$chr\t$start\t$end\t$id\ttheme=fill:$aln{$id}\n";
}
close IN;
close OUT;

open IN,"m.gene.gff";
open OUT,">m.gene.txt";
while (<IN>){
		chomp;
		my ($chr,$start,$end,$id)=(split /\t/)[0,3,4,8];
		$id=~s/;.+//;
		$id=~s/ID=//;
		print OUT "$chr\t$start\t$end\t$id\ttheme=fill:$aln{$id}\n";
}
close IN;

