package SBV::IMAGE::PIE;
#------------------------------------------------+
#    [APM] This moudle is generated by amp.pl    |
#    [APM] Created time: 2013-11-25 10:50:06     |
#------------------------------------------------+
=pod

=head1 Name

SBV::IMAGE::PIE

=head1 Synopsis

This module is not meant to be used directly

=head1 Feedback

Author: Peng Ai
Email:  aipeng0520@163.com

=head1 Version

Version history

=head2 v1.0

Date: 2013-11-25 10:50:07

=cut


use strict;
use warnings;
require Exporter;

use Math::Round;
use FindBin;
use lib "$FindBin::RealBin";
use lib "$FindBin::RealBin/lib";
use lib "$FindBin::RealBin/../";
use lib "$FindBin::RealBin/../lib";

use SBV::Constants;
use SBV::DEBUG;

sub new 
{
	my ($class,$file,$conf) = @_;
	my $obj = {};
	
	$obj->{conf} = $conf;
	$obj->{data} = _load_data_file($file,$conf);
	bless $obj , $class;
	$obj->load_conf($conf);

	return $obj;
}

sub load_conf
{
	my ($self,$conf) = @_;
	
	$self->{ox} = $conf->{ox} or die;
	$self->{oy} = $conf->{oy} or die;
	$self->{oty} = $conf->{oty} or die;
	$self->{tw} = $conf->{tw} or die;
	$self->{th} = $conf->{th} or die;

	$conf->{legend} = 1 unless (defined $conf->{legend});
	$conf->{filter} = "01" unless (defined $conf->{filter});
	$conf->{angle_offset} = -90 unless (defined $conf->{angle_offset});

	$self->{filter} = $conf->{filter};
	$self->{angle_offset} = $conf->{angle_offset};
	
	# set the colors
	my @data = @{$self->{data}};
	my $num = scalar @data;
	my @colors;
	if (defined $conf->{color})
	{
		#@colors = SBV::CONF::fetch_val($conf,"color");
		#@colors = map {SBV::Colors::fetch_color($_)} @colors;
		@colors = SBV::Colors::fetch_brewer_color($conf->{color});
		if (@colors < $num)
		{
			WARN("the colors you defined is not enough for pie") ;
			@colors = SBV::Colors::rainbow($num);
		}
	}
	else
	{
		@colors = SBV::Colors::rainbow($num);
	}
	$self->{colors} = \@colors;
	
	$self->title($conf->{title}) if ($conf->{title});
	$self->legend(SBV::CONF::fetch_first_conf('legend',$self->{conf})) if ($conf->{show_legend});
}

sub title
{
	my ($self,$str) = @_;
	my $font = SBV::Font->fetch_font('CLASStitle');
	my $textH = $font->fetch_text_height;

	if ($str)
	{
		$self->{th} -= $textH + $SBV::conf->{vspace}*2;
		$self->{oty} += $textH + $SBV::conf->{vspace}*2;
		$self->{title} = $str;
	}
	elsif (defined $self->{title})
	{
		$self->{oty} -= $textH + $SBV::conf->{vspace}*2;
		$self->{th} += $textH + $SBV::conf->{vspace}*2;
		$self->{title} = undef;
	}
}

sub legend
{
	my ($self,$lconf) = @_;
	
	my @data = @{$self->{data}};
	
	my $colors = $self->{colors};
	my $shapes = [0];
	my $sum = 0;
    map { $sum += $$_[1] } @data;
    my @labels = map {
        my $label = $$_[0];
        $label .= ": $$_[1]" if ($self->{conf}->{show_val});

        my $per = sprintf("%.2f",$$_[1]*100/$sum);
        $label .= " ($per%)" if ($self->{conf}->{show_percentage});
    } @data;
    
	$lconf->{pos} = "outright";
	my $legend = SBV::STONE::LEGEND->new(conf=>$lconf,fill=>$colors,shape=>$shapes,label=>\@labels);
	$self->{legend} = $legend;
	$self->{tw} -= $legend->{width};
}

# draw pie figure
sub plot
{
	my ($self,$parent) = @_;
	
	my $pieGroup = $parent->group(class=>"pie",id=>"pie_$SBV::idnum");
	$SBV::idnum ++;
	my $vi = $SBV::conf->{vspace};

	# background
	#$pieGroup->rect(x=>$self->{ox},y=>$self->{oy}-$self->{th},width=>$self->{tw},height=>$self->{th},
	#	style=>"fill:#ccc",class=>"background") ;
	
	# title
	my $font = SBV::Font->fetch_font('CLASStitle');	
	my $textH = $font->fetch_text_height;
	if (defined $self->{title})
	{
		my $textW = $font->fetch_text_width($self->{title});
		my $x = $self->{ox} + $self->{tw}/2 - $textW/2;
		my $y = $self->{conf}->{oty} + $vi + $textH;
		$pieGroup->text(x=>$x,y=>$y,class=>"title")->cdata($self->{title});
	}

	my @data = @{$self->{data}};
	
	# get the sum
	my $sum;
	my $label_width = 0;
	map {$sum+=$$_[1]} @data;
	
	# get the radius
	my %labels;
	$font = SBV::Font->fetch_font("label");
	$textH = $font->fetch_text_height;
	my $hi = $SBV::conf->{hspace};
	my $raise_r = 0;
	foreach my$record(@data)
	{
		my ($name,$val,$attrs) = @$record;
		my $marker = "";
			
		$marker .= $name;
		if ($attrs->{show_val})
		{
			$marker .= " $val";	
		}

		if ($attrs->{show_percentage})
		{
			my $per = nearest 0.1 , ($val * 100 / $sum); 
			$marker .= " $per%";
		}
		$labels{$name} = $marker;
		
		if ($attrs->{show_label} && $attrs->{show_label_orientation} eq "outer")
		{
			my $width = $font->fetch_text_width($marker) + $hi + $attrs->{label_links_length};
			$label_width = $width if ($label_width < $width);
		}

		if ($attrs->{raise_r})
		{
			$raise_r = $attrs->{raise_r} if ($attrs->{raise_r} > $raise_r);	
		}
	}
	
	my $cx = $self->{ox} + $self->{tw}/2;
	my $cy = $self->{oy} - $self->{th}/2;
	my $radius = $self->{tw} > $self->{th} ? $self->{th}/2 : $self->{tw}/2;
	$radius -= $label_width + $hi + $raise_r;
	ERROR('pie_radius_err') if ($radius < 0);
		
	# draw 
	my $temp = $self->{angle_offset} + 90;
	$temp = $temp % 360 if $temp > 360;
	my @colors = @{$self->{colors}};
	
	my $linkFlen = 8;
	foreach my$record(@data)
	{
		my ($name,$val,$attrs) = @$record;
		my $r0 = defined $attrs->{r0} ? $attrs->{r0} : 0;
		my $r1 = $attrs->{r1} || $radius;
		$r1 = $radius if ($r1 > $radius);
		my $color = shift @colors;
		my $raise_r = $attrs->{raise_r} || 0;

		my $angle = $val*360/$sum;
		my %fan = (start=>$temp,color=>$color,r1=>$r0,class=>'pie',raise=>$raise_r,parent=>$pieGroup);
		$fan{'filter'} = $self->{filter} if ($self->{filter});
		SBV::DRAW::Fan($cx,$cy,360,$temp+$angle,$r1,%fan);
		
		$r0 += $raise_r;
		$r1 += $raise_r;
		if ($attrs->{show_label})
		{
			my $arc = ($temp + $angle/2)*$TWOPI/360;
			
			if ($attrs->{show_label_orientation} eq "outer")
			{
				my $x1 = nearest 0.01 , ($cx + sin($arc)*$r1);
				my $y1 = nearest 0.01 , ($cy - cos($arc)*$r1);
				my $x2 = nearest 0.01 , ($cx + sin($arc)*($r1+$linkFlen));
				my $y2 = nearest 0.01 , ($cy - cos($arc)*($r1+$linkFlen));
				my $x3 = $x2;
				my $y3 = $y2;

				if ($attrs->{show_label_links})
				{
					$x3 = $arc > $PI ? $x2 - $attrs->{label_links_length} : $x2+$attrs->{label_links_length};
					$pieGroup->path(class=>"links",d=>"M$x1 $y1 L$x2 $y2 L$x3 $y3",style=>"fill:none;stroke:#000");	
				}

				if ($arc > $PI)
				{
					my $textW = $font->fetch_text_width($labels{$name});
					$pieGroup->text(class=>"label",x=>$x3-$hi-$textW,y=>$y3+$textH/2)->cdata($labels{$name});
				}
				else
				{
					$pieGroup->text(class=>"label",x=>$x3+$hi,y=>$y3+$textH/2)->cdata($labels{$name});
				}
			}
			else
			{
				my $x1 = nearest 0.01 , ($cx + sin($arc)*($r1+$r0)/2);
				my $y1 = nearest 0.01 , ($cy - cos($arc)*($r1+$r0)/2);
				my $textW = $font->fetch_text_width($labels{$name});
				$pieGroup->text(class=>"label",x=>$x1-$textW/2,y=>$y1+$textH/2)->cdata($labels{$name});
			}
		}

		$temp += $angle;
	}

	if (defined $self->{legend})
	{
		$self->{legend}->location($self);
		$self->{legend}->draw($pieGroup);
	}
}

sub _load_data_file
{
	my ($file,$conf,%param) = @_;
	my $sep = $param{-sep} || "\t";
	my @data;

	open FH,$file or die "$!";
	while(<FH>)
	{
		chomp;
		next if (/^#/ || $_ eq "");	
		my ($name,$val,$opts) = split /$sep/;
		
		# deal the options column
		my $attrs = {};
		my @tags = ("r0","r1","raise_r","show_label","show_label_links",
			"label_links_length","show_label_orientation","show_val","show_percentage");
		
		foreach my$tag(@tags)
		{
			$attrs->{$tag} = $conf->{$tag} if (exists $conf->{$tag});
		}

		if ($opts)
		{
			my @attrs = split /;/ , $opts;
			foreach my$attr(@attrs)
			{
				my ($tag,$val) = split /=/ , $attr;
				$attrs->{$tag} = $val;
			}
		}
		
		push @data , [$name,$val,$attrs];
	}
	close FH;

	return \@data;
}
