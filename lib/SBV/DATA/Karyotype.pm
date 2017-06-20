package SBV::DATA::Karyotype;
#------------------------------------------------+
#    [APM] This moudle is generated by amp.pl    |
#    [APM] Created time: 2013-07-05 10:46:00     |
#------------------------------------------------+
=pod

=head1 Name

SBV::DATA::Karyotype

=head1 Synopsis

This module is not meant to be used directly

=head1 Feedback

Author: Peng Ai
Email:  aipeng0520@163.com

=head1 Version

Version history

=head2 v1.0

Date: 2013-07-05 10:46:00

=cut


use strict;
use warnings;
require Exporter;

use FindBin;
use lib "$FindBin::RealBin";
use lib "$FindBin::RealBin/..";
use lib "$FindBin::RealBin/lib";
use lib "$FindBin::RealBin/../lib";

use SBV::Constants;
use SBV::DEBUG;


#-------------------------------------------------------------------------------
#  name: read_karyotype_file
#  file format: 
#  chr label start end color
#-------------------------------------------------------------------------------
sub read_karyotype_file
{
	my $file = shift;
	my $karyotype;

	open FH,$file or die;
	my $order = 0;
	while(<FH>)
	{
		chomp;
		next if (/^#/);
		my ($chr,$label,$sta,$end,$color) = split /\t/;
		my $size = abs($end - $sta) + 1;
		my $reverse = $end > $sta ? 0 : 1;
		$color = SBV::Colors::fetch_color($color);
		my $data = {
			name => $chr,
			label => $label,
			sta => $sta,
			end => $end,
			size => $size,
			color => $color,
			display_order => $order,
			display => 0,
			reverse => $reverse
		};

		$order ++;

		ERROR('karyotype_chr_exists_err') if (exists $karyotype->{$chr});
		$karyotype->{$chr} = $data;
	}
	close FH;

	return $karyotype;
}
