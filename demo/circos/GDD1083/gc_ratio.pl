#!usr/bin/perl -w
use strict;
use Getopt::Long;
use FindBin qw($Bin);
use lib "/home/aipeng/work/develepment/draw/lib";
use SEQUENCE;
use Bio::SeqIO;

my ($step,$win,$outdir,$help);
GetOptions(
	"step:i"=>\$step,
	"win:i"=>\$win,
	"outdir:s"=>\$outdir,
	"help"=>\$help,
);

$outdir ||="./";
$win ||= 10000;
$step ||= 100;
#my $file=shift;
if (defined $help || !defined $step || !defined $win || @ARGV!=1 ){
	print "perl $Bin/gc_ratio.pl -step 100 -win 10000 -outdir ./  genome_file\n";
	exit 0;

}

my $file=shift;
my $inseq = Bio::SeqIO->new(
	-file =>"$file",
	-format=>"fasta",
	);


my $longest=0;
my $longest_id;
#open KARYO,">$outdir/karyotype.txt";
open GC,">$outdir/gc_ratio.txt";
open GDSKEW,">$outdir/SKEW_ratio.txt";
while (my $seq_obj = $inseq->next_seq){
	my $id = $seq_obj->id;
	my $seq=$seq_obj->seq;
	my $length=$seq_obj->length;
	next unless $length>$win;
	if ($length>$longest){
		$longest=$length;
		$longest_id=$id;
	}
	my $gc_num=$seq=~tr/GCgc/GCgc/;
#	my $gc_ratio=sprintf("%.2f",$gc_num/$length);
	my $gc_ratio=$gc_num/$length;
	my (@gc_rate,@gc_skew);
	Cal_GC($seq,$win,$step,\@gc_rate);
	Cal_GCSKEW($seq,$win,$step,\@gc_skew);
	my $i;
	my $flag=0;
	for ($i=0;$i<$length-1-$win;$i+=$step){
		my $start=$i+1;
		my $end=$start+$win-1;
		$gc_rate[$flag]=$gc_rate[$flag]/100;
		my $diff=$gc_rate[$flag]-$gc_ratio;
		if ($diff>=0){
			print GC "$id\t$start\t$end\t$diff\tfill=lred\n";
#			print GCDOWN "$id\t$start\t$end\t0\n";
		}
		else{
			print GC "$id\t$start\t$end\t$diff\tfill=lblue\n";
#			print GCUP "$id\t$start\t$end\t0\n";
		}
		if ($gc_skew[$flag]>=0){
			print GDSKEW "$id\t$start\t$end\t$gc_skew[$flag]\tfill=lred\n";
		}
		else{
			print GDSKEW "$id\t$start\t$end\t$gc_skew[$flag]\tfill=lblue\n";
		}
		$flag++;
	}
#		for(my$j=$i;$j<$length-1-$step;$j+=$step){
#		if ($flag==scalar(@gc_rate)){
			my $start=$i+1;
			my $diff=$gc_rate[$flag]/100-$gc_ratio;
			if ($diff>0){
				print GC "$id\t$start\t$length\t$diff\tfill=lred\n";
#				print GCDOWN "$id\t$start\t$length\t0\n";
			}
			else{
				print GC "$id\t$start\t$length\t$diff\tfill=lblue\n";
#				print GCUP "$id\t$start\t$length\t0\n";
			}
			if ($gc_skew[$flag]>=0){
				print GDSKEW "$id\t$start\t$length\t$gc_skew[$flag]\tfill=lred\n";
			}
			else{
				print GDSKEW "$id\t$start\t$length\t$gc_skew[$flag]\tfill=lblue\n";
			}
#		}
#	}
}
close GC;
close GDSKEW;
open KARYO,">$outdir/karyotype.txt";
print KARYO "$longest_id\t$longest_id\t1\t$longest\n";

close KARYO;
