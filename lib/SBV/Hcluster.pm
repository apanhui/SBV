package SBV::Hcluster;
#------------------------------------------------+
#    [APM] This moudle is generated by amp.pl    |
#    [APM] Created time: 2014-05-15 14:52:41     |
#------------------------------------------------+
=pod

=head1 Name

SBV::Hcluster

=head1 Synopsis

This module is not meant to be used directly

=head1 Function

Do hierarchical clustering and output newick tree result file

=head1 Feedback

Author: Peng Ai
Email:  aipeng0520@163.com

=head1 Version

Version history

=head2 v1.0

Date: 2014-05-15 14:52:41

=cut

use strict;
use warnings;
require Exporter;

use Algorithm::Cluster::Record;
use Algorithm::Cluster qw/kcluster/;
use FindBin;

use lib "$FindBin::RealBin";
use lib "$FindBin::RealBin/lib";
use lib "$FindBin::RealBin/..";
use lib "$FindBin::RealBin/../lib";

use SBV::DATA::Frame;

sub new
{
	my ($class,$file) = @_;
	my $object = {};
	
	my $record = Algorithm::Cluster::Record->new();
	open INPUT,$file or die $!;
	$record->read(*INPUT);
	$object->{data} = $record;

	bless $object , $class;
	return $object;
}

sub hcluster
{
	my $self = shift;
	my %opts = @_;
	
	my $record = $self->{data};
	my $tree = $record->treecluster(%opts);
	$self->{tree} = $tree;
}

sub save
{
	my $self = shift;
	my %opts = @_;

	my $file = $opts{file} or die "the file to save tree is needed\n";
	my $names = $opts{name} or die "the names are needed\n";
	my $tree = $self->{tree};
	my @order;

	my $n = $tree->length();
	my %hash;
	my $flag = 0;
	for(my$i=0;$i<$n;$i++)
	{
		$flag --;
		my $node = $tree->get($i);
		my $left = $node->left();
		my $right = $node->right();
		my $dis = $node->distance();
		
		push @order , $names->[$left] if ($left >= 0);
		push @order , $names->[$right] if ($right >= 0);
		
		my $left_name = $hash{$left} ? $hash{$left} : $names->[$left];
		my $right_name = $hash{$right} ? $hash{$right} : $names->[$right];
		
		# the leaf is default in left
		if ($hash{$left} && ! $hash{$right})
		{
			($left_name,$right_name) = ($right_name,$left_name);
		}

		$hash{$flag} = "($left_name:$dis,$right_name:$dis)";
	}

	open OUT,">",$file or die "$!";
	print OUT $hash{$flag};
	close OUT;
	
	die "fata error!\n" unless ($#order == $#$names);
	$self->{order} = \@order;
}
