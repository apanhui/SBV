package SBV::CONF;
#------------------------------------------------+
#    [APM] This moudle is generated by amp.pl    |
#    [APM] Creat time: 2013-05-13 15:57:09       |
#------------------------------------------------+
=pod

=head1 Name

SBV::CONF -- check and load config file

=head1 Synopsis

This module is not meant to be used directly

=head1 Feedback

Author: Peng Ai
Email:  aipeng0520@163.com

=head1 Version

Version history

=head2 v1.0

Date: 2013-05-13 15:57:09

=cut

use strict;
use warnings;

use FindBin;
use Config::General;
use File::Basename qw(dirname basename);

use lib "$FindBin::RealBin";
use lib "$FindBin::RealBin/..";
use lib "$FindBin::RealBin/lib";
use lib "$FindBin::RealBin/../lib";

use SBV::DEBUG;
use SBV::STAT;
use SBV::Constants;
use SBV;

use base 'Exporter';
my @Export = qw(load_conf fetch_symbol_class fetch_margin fetch_first_conf fetch_infile extract_conf fetch_size attrs2style);
my @Export_OK = qw(load_conf fetch_symbol_class fetch_margin fetch_first_conf fetch_infile extract_conf fetch_size attrs2style);

# load configuration file
sub load_conf
{
	my $confF = shift;
	
	$confF = check_path($confF,"$confF.conf");

	if ($confF eq "")
	{
		ERROR('no_conf_path');
	}
	
	timeLOG("found conf file: $confF");

	my @confPath = (
		dirname($confF),
		dirname($confF)."etc",
		"$FindBin::RealBin",
		"$FindBin::RealBin/etc",
		"$FindBin::RealBin/../etc",
		"$FindBin::RealBin/.."
	);

	my $conf = Config::General->new(
		-SplitPolicy       => 'equalsign',
		-ConfigFile        => $confF,
		-AllowMultiOptions => 1,
		-LowerCaseNames    => 1,
		-IncludeAgain      => 1,
		-ConfigPath        => \@confPath,
		-AutoTrue => 1
	);
	
	my $conf_root = { $conf->getall };
	
	&init_conf($conf_root);

	return $conf_root;
}


#===  FUNCTION  ================================================================
#         NAME: init_conf
#      PURPOSE: init conf hash
#   PARAMETERS: conf_hash root
#      RETURNS: null
#  DESCRIPTION: init conf hash, for some tags give the default if not defined 
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub init_conf
{
	my $conf_root = shift;

	# init the graph size  and background
	default($conf_root,"width",600);
	default($conf_root,"height",600);
	default($conf_root,"background",0);

	my $bg = $conf_root->{background};
	if ($bg =~ /^url:(.+)/)
	{	$bg = $1;
		if (! -e "$FindBin::RealBin/../images/$bg")
		{
			WARN("the background image $bg is not found","close the background");
		}
	}

	# init output 
	#default($conf_root,"dir",".");
	#default($conf_root,"file","sbv");

	# init edge margin
	default($conf_root,"margin",20);
	
	# init vertical and horizontal spacing 
	default($conf_root,"hspace",4);
	default($conf_root,"vspace",4);
	
	# set character for conf root 
	my $margin = fetch_margin ($conf_root);
	$conf_root->{x} = 0;
	$conf_root->{y} = $conf_root->{height};
	$conf_root->{ty} = 0;
	$conf_root->{ox} = $conf_root->{x} + $margin->{left};
	$conf_root->{oy} = $conf_root->{y} - $margin->{bottom};
	$conf_root->{oty} = $conf_root->{ty} + $margin->{top};
	$conf_root->{tw} = $conf_root->{width} - $margin->{left} - $margin->{right};
	$conf_root->{th} = $conf_root->{height} - $margin->{top} - $margin->{bottom};

	return;
}

# init rectangular coordinate system 
sub init_coord_conf
{
	my $conf = shift;
	&init_plot_conf($conf);
}

sub init_manhattan_conf
{
	my $conf = shift;
	
	default($conf,'fill','red green');
	default($conf,"size",1.5);
	default($conf,"symbol_width",2*$conf->{size});
	default($conf,"symbol_height",2*$conf->{size});
	default($conf,'xlab','Chromosomes');
	default($conf,'ylab','-log10(P)');
	default($conf,'chr_spacing','0u');
	
	&init_coord_conf($conf);
}

sub init_chrplot_conf
{
	my $conf = shift;
	
	#default($conf,"symbol_width",2*$conf->{size});
	#default($conf,"symbol_height",2*$conf->{size});
	default($conf,'xlab','Chromosomes');
	#default($conf,'ylab','-log10(P)');
	default($conf,'chr_spacing','0u');
	
	&init_coord_conf($conf);
}

sub init_maplot_conf 
{
	my $conf = shift;

	default($conf,"header",0);
	default($conf,"rownames",0);
	default($conf,"size",3);
	default($conf,"symbol_width",2*$conf->{size});
	default($conf,"symbol_height",2*$conf->{size});
	default($conf,"fill","black");
	default($conf,"xlab","A");
	default($conf,"ylab","M");

	&init_coord_conf($conf);
}

sub init_volcano_conf {
    my $conf = shift;

	default($conf,"header",1);
	default($conf,"rownames",1);
    default($conf,"size",2);
	default($conf,"fill","black");
	default($conf,"symbol_width",2*$conf->{size});
    default($conf,"symbol_height",2*$conf->{size});
	default($conf,"xlab","log2(FC)");
	default($conf,"ylab","-log10(FDR)");
    default($conf,"log2fc","log2FC");
    default($conf,"fdr","FDR");
    default($conf,"degs","significant");
    default($conf,"fill","red green blue");
    &init_coord_conf($conf);
}

sub init_freq_conf
{
	my $conf = shift;
	
	default($conf,"format","plain");
	default($conf,"type","dna");

	default($conf,"xlab","position");
	default($conf,"ylab","frequency");
	default($conf,"xnames","yes");
	
	default($conf->{yaxis},"tick","0 1.04 0.2");
	&init_coord_conf($conf);
}

sub init_bubble_conf
{
	my $conf = shift;
	
	default($conf,"col","black");
	default($conf,"fill","black");
	default($conf,"z_val_multiple",1);

	&init_coord_conf($conf);
}

sub init_rplot_conf
{
	my $conf = shift;
	
	default($conf,"col","red green blue");
	default($conf,"xlab","number of Genomes");
	default($conf,"ylab","Genes");
	default($conf,"size",3);
	default($conf,"symbol_width",2*$conf->{size});
	default($conf,"symbol_height",2*$conf->{size});
	default($conf,"xnames",0);

	&init_coord_conf($conf);
}

# init plot conf 
sub init_plot_conf
{
	my $conf = shift;

	default($conf,"header",0);
	default($conf,"rownames",0);
	#default($conf,"margin","20");
	
	if ($SBV::OPT{pattern} && $SBV::OPT{pattern} eq "ggplot2")
	{
		default($conf,"border","0000");
		default($conf,"background","ddd");
	}
	else
	{
		default($conf,"border","1111");
		default($conf,"background","fff");
	}

	my $bg = $conf->{background};
	if ($bg ne "open" && $bg ne "closed" && ! -e "$FindBin::RealBin/../images/$bg")
	{
		WARN("the background image $bg is not found","close the background");
	}
	
	default($conf,"shape",1);
	default($conf,"col","black");
	default($conf,"fill",'none');
	default($conf,"show_outrange",'no');
	#default($conf,"stroke_width",1);
	
	return;
}

# init legend conf
sub init_legend_conf
{
	my $conf = shift;
	
	default($conf,"border","0");
	default($conf,"margin","5");

	return;
}

# init suto conf 
sub init_auto_conf
{
	my $conf = shift;
	return ;
}

sub init_tree_conf
{
	my $conf = shift;
	default($conf,"format","nhx");
	default($conf,"align",1);
	default($conf,"ignore_branch_length",0);
	default($conf,"show_branch_length",0);
	default($conf,"show_distance_scale",1);
	default($conf,"angle",350);
	default($conf,"rotation",0);
	default($conf,"model","normal");
	default($conf,"radius",200);
	default($conf,"unit",0.01);
	default($conf,"oriental","left");
	default($conf,"linkage_type","dotted");
	
	#  for unrooted tree 
	default($conf,"size_ratio",0.5);
	default($conf,"x_offset",0.5);
	default($conf,"y_offset",0.5);

	$conf->{definition}->{cover} = "full" if ($conf->{definition} && ! exists $conf->{definition}->{cover});

	#$conf->{angle} = $TWOPI * $conf->{angle} / 360;
	#$conf->{rotation} = $TWOPI * $conf->{rotation} / 360;
}

sub init_taxtree_conf
{
	my $conf = shift;
	default($conf,"format","nhx");
	default($conf,"align",1);
	default($conf,"angle",350);
	default($conf,"rotation",0);
	default($conf,"model","normal");
	default($conf,"radius",20);
	default($conf,"start_radius",200);
	default($conf,"oriental","left");
}

sub init_heatmap_conf
{
	my $conf = shift;
	default($conf,"colors","f00 000 0f0");
	default($conf,"scale","none");

	default($conf->{horizontal},"order","tree");
	default($conf->{vertical},"order","tree");
	default($conf->{horizontal},"tree_size",100);
	default($conf->{vertical},"tree_size",100);

	init_tree_conf($conf->{horizontal});
	init_tree_conf($conf->{vertical});
	
	default($conf->{horizontal},"show_distance_scale",0);
	default($conf->{vertical},"show_distance_scale",0);
}

sub init_ppi_conf
{
	my $conf = shift;

	default($conf,"angle_offset",-90);
	default($conf,"show_legend",0);
	default($conf,"radius",200);

	default($conf,"color","#000");
	default($conf,"fill","#f92");
	default($conf,"size",5);

	default($conf,"show_label",1);
	default($conf,"label_theme","size:12;style:normal;weight:normal");

	default($conf,"link_color","#999");
	default($conf,"link_thickness",2);
}

# init tree datasets conf 
sub init_tree_datasets_conf
{
	my $conf = shift;

	default($conf,"type","marker");
	default($conf,"format","list2"); # file format
	default($conf,"color","#f00");
	default($conf,"header",0);
	default($conf,"width",20);
	default($conf,"height",1); 
	default($conf,"show_axis",0);

	return;
}

# init pie conf
sub init_pie_conf
{
	my $conf = shift;
	
	# data 
	default($conf,"header",0);
	
	default($conf,"angle_offset",-90);
	default($conf,"raise_r",0);
	default($conf,"filter","01");
	default($conf,"show_legend",0);

	default($conf,"r0",0);
	
	default($conf,"show_label",1);
	default($conf,"show_val",1);
	default($conf,"show_percentage",0);
	default($conf,"show_label_orientation","inner");
	default($conf,"show_label_links",0);
	default($conf,"label_links_length",10);

	return;
}

sub init_venn_conf
{
	my $conf = shift;

	default($conf,'fill','CMG_Lee');
	default($conf,'show_label','yes');
	default($conf,'show_logical_label','no');
	default($conf,'print_stat_info','no');

	default($conf,"stroke_width",0);
	default($conf,"circle_color","fff");
	default($conf,"circle_radius",1);
	default($conf,"rx",1);
	default($conf,"ry",1);
	default($conf,"offset",0);
}

# init hcgd conf 
sub init_hcgd_conf
{
	my $conf = shift;

	default($conf,'col_chr_number',12);
	default($conf,'row_chr_spacing',20);
	default($conf,'thickness',20);
	default($conf,'label_theme','size:14;weight:bold;fill:000');
	default($conf,'model','Ensembl'); # normal, NCBI, Ensembl
	default($conf,'chr_rounded_ratio',0.25);
	default($conf,'offset',0);

	default($conf->{ticks},"offset",0);
	default($conf->{ticks},"label_multiplier",1);
	default($conf->{ticks},"thickness",1);
	default($conf->{ticks},"size",8);
	default($conf->{ticks},"unit_label","");

	default($conf->{plots},"link_thickness",1);
	default($conf->{plots},"link_color","black");

	default($conf->{highlights},"shape",0);
	default($conf->{highlights},"color","none");
	default($conf->{highlights},"fill","black");
	default($conf->{highlights},"stroke_width",0);
}

# init lasv conf 
sub init_lasv_conf
{
	my $conf = shift;

	default($conf,'key','query');
	default($conf,"margin","20");
	default($conf,'graph',"simple");
	default($conf,'draw_first',0);
}

# init sdu conf 
sub init_sdu_conf
{
	my $conf = shift;

	default($conf,"num",80);
	default($conf,"subnum",10);
	default($conf,"line_spacing",8);
	default($conf,"theme","family:Courier New");

	default($conf,"nohead","no");

	default($conf->{decorates},"z",1);
	default($conf->{decorates},"theme","fill:red");
	default($conf->{decorates},"underline","no");
	default($conf->{decorates},"color","none");
	default($conf->{decorates},"stroke_width",0);
	default($conf->{decorates},"fill","none");
	default($conf->{decorates},"opacity",1);

	unless ($conf->{nohead})
	{
		default($conf,"thickness",20);
		default($conf,"header_color","none");
		default($conf,"spacing",60);
		default($conf->{decorates},"shape",0);
		default($conf->{decorates},"header_color","red");
	}

}

# init combar conf 
sub init_combar_conf
{
	my $conf = shift;
	
	default($conf,"header",1);
	default($conf,"tick_size_x",6);
	default($conf,"tick_size_y",4);
	default($conf,"free_x",0);
	default($conf,"size",0.8);
	default($conf,"xlab","");
	default($conf,"display_colnames",1);
	default($conf,"display_rownames",1);
	default($conf,"stroke_width",0);
	default($conf,"stroke","black");
}

# init karyo conf 
sub init_karyo_conf
{
	my $conf = shift;

	default($conf,"model","normal");
	
	default($conf->{ideogram},"show","yes");
	default($conf->{ideogram},"thickness",20);
	default($conf->{ideogram},"show_chromosomes_default","yes");
	default($conf->{ideogram},"chromosomes_color","yes");
	default($conf->{ideogram},"chromosomes_stroke_width",1);
	default($conf->{ideogram},"show_label","yes");
	default($conf->{ideogram},"label_with_tag","yes");
	default($conf->{ideogram},"label_parallel","yes");
	
	default($conf->{ticks},"offset",0);
	default($conf->{ticks},"label_multiplier",1);
	default($conf->{ticks},"thickness",1);
	default($conf->{ticks},"size",8);
	#default($conf->{ticks},"show_label","no");
	

	if ($conf->{model} eq "circular")
	{
		default($conf,"ratation",0);
		default($conf->{ticks},"orientation","outer");
	}
	else
	{
		default($conf,"start","0.5r");
		default($conf->{ideogram},"chromosomes_rounded_ends","yes");
		default($conf->{ticks},"orientation","up");
	}
}

#-------------------------------------------------------------------------------
#  default : set default value for hash with specific tag
#-------------------------------------------------------------------------------
sub default
{
	my $hash = shift;
	my $tag = shift;
	my $val = shift;

	$hash->{$tag} = $val if (! defined $hash->{$tag});
}

#===  FUNCTION  ================================================================
#         NAME: fetch_first_conf
#      PURPOSE: get the first conf hash of specific tag
#   PARAMETERS: tag name, parent conf hash
#      RETURNS: first child conf hash
#  DESCRIPTION: ????
#       THROWS: no child conf hash, 
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub fetch_first_conf
{
	my %init_func = (
		'auto'      => \&init_auto_conf,
		'legend'    => \&init_legend_conf,

		'ggplot2'   => \&init_coord_conf,
		'boxplot'   => \&init_coord_conf,
		'bubble'    => \&init_coord_conf,
		'rplot'     => \&init_rplot_conf,
		'maplot'    => \&init_maplot_conf,
		'manhattan' => \&init_manhattan_conf,
		'chrplot'   => \&init_chrplot_conf,
        'volcano'   => \&init_volcano_conf,
		
		'pie'       => \&init_pie_conf,
		'venn'      => \&init_venn_conf,
		'ppi'       => \&init_ppi_conf,
		'freq'      => \&init_freq_conf,
		'lasv'      => \&init_lasv_conf,
		'tree'      => \&init_tree_conf,
		'taxtree'   => \&init_taxtree_conf,
		'heatmap'   => \&init_heatmap_conf,
		'karyo'     => \&init_karyo_conf,
		'hcgd'      => \&init_hcgd_conf,
		'sdu'       => \&init_sdu_conf,
		'combar'    => \&init_combar_conf,

		'datasets'  => \&init_tree_datasets_conf,
	);

	my $name = shift;
	my $parent = shift || $SBV::conf;
	my $flag = shift;
	$flag = 1 if (! defined $flag);
	
	ERROR('no_conf_child',$name) if (! $parent->{$name});

	my $aimConf = $parent->{$name};

	if (ref $aimConf eq "HASH")
	{
		$aimConf = $aimConf;
	}
	elsif (ref $aimConf eq "ARRAY")
	{
		$aimConf = $aimConf->[0];	
	}
	else
	{
		ERROR('no_conf_child',$name);	
	}
	
	&{$init_func{$name}}($aimConf) if (exists $init_func{$name});
	
	inherit($parent,$aimConf) if (1 == $flag);
	return $aimConf;
}

sub fetch_conf
{
	my %init_func = (
		'auto'      => \&init_auto_conf,
		'legend'    => \&init_legend_conf,

		'ggplot2'   => \&init_coord_conf,
		'boxplot'   => \&init_coord_conf,
		'bubble'    => \&init_coord_conf,
		'rplot'     => \&init_rplot_conf,
		'maplot'    => \&init_maplot_conf,
		'manhattan' => \&init_manhattan_conf,
		
		'pie'       => \&init_pie_conf,
		'venn'      => \&init_venn_conf,
		'ppi'       => \&init_ppi_conf,
		'freq'      => \&init_freq_conf,
		'lasv'      => \&init_lasv_conf,
		'tree'      => \&init_tree_conf,
		'taxtree'   => \&init_taxtree_conf,
		'heatmap'   => \&init_heatmap_conf,
		'karyo'     => \&init_karyo_conf,
		'hcgd'      => \&init_hcgd_conf,
		'sdu'       => \&init_sdu_conf,
		'combar'    => \&init_combar_conf,

		'datasets'  => \&init_tree_datasets_conf,
	);
	
	my $name = shift;
	my $parent = shift;
	my $conf = shift;
	my $flag = shift || 1;

	&{$init_func{$name}}($conf);
	inherit($parent,$conf);

	return;
}

# extract sub conf , return @array
sub extract_conf
{
	my ($parent,$tag) = @_;
	
	return () unless $parent->{$tag};
	my $subconf = $parent->{$tag};

	if (ref $subconf eq "ARRAY")
	{
		return @$subconf;
	}
	elsif (ref $subconf eq "HASH")
	{
		return ($subconf);	
	}
	else
	{
		return ();	
	}
}

# fetch size (percent value)
sub fetch_size
{
	my ($raw,$sum) = @_;
    
    if ($raw =~ /^([\d\.]+)([ru]) ([+-]) ([\d\.]+)([ru])$/) {
        my $head = $2 eq "r" ? $1*$sum : $1;
        my $tail = $5 eq "r" ? $4*$sum : $4;
        my $sum = $3 eq "+" ? $head + $tail : $head - $tail;
        return $sum;
    }elsif($raw =~ /^([\d\.]+)r$/){
        return $1 * $sum;
    }elsif($raw =~ /^([\d\.]+)u$/){
        return $1;
    }elsif($raw =~ /^([\d\.]+)$/){
        return $raw;
    }else{
        die $raw;
    }
}

#-------------------------------------------------------------------------------
# inherit : inherit the location info from parent 
#-------------------------------------------------------------------------------
sub inherit
{
	my $parent = shift;
	my $child = shift;
	
	#------------------------
	# inherit location 
	#------------------------
	if (defined $parent->{width})
	{
		if (! exists $child->{width})
		{
			$child->{width} = $parent->{tw};
		}
		elsif (is01($child->{width}))
		{
			$child->{width} = $parent->{tw} * $child->{width};
		}
	}

	if (defined $parent->{height})
	{
		if (! exists $child->{height})
		{
			$child->{height} = $parent->{th};	
		}
		elsif ( is01($child->{height}) )
		{
			$child->{height} = $parent->{th} * $child->{height};
		}
	}

	if (defined $parent->{x})
	{
		if (! exists $child->{x})
		{
			$child->{x} = $parent->{ox};
		}
		elsif ( is01($child->{x}) )
		{
			$child->{x} = $parent->{ox} + $child->{x} * $parent->{tw};
		}
	}
	
	if (defined $parent->{y})
	{
		if (! exists $child->{y})
		{
			$child->{y} = $parent->{oy};	
		}
		elsif (is01($child->{y}))
		{
			$child->{y} = $parent->{oy} - $child->{y} * $parent->{th};
		}
	}

	# get child margin
	my $margin = fetch_margin($child);
	
	$child->{ty} = $child->{y} - $child->{height};
	$child->{ox} = $child->{x} + $margin->{left};
	
	$child->{oy} = $child->{y} - $margin->{bottom};
	$child->{oty} = $child->{ty} + $margin->{top};
	$child->{tw} = $child->{width} - $margin->{left} - $margin->{right};
	$child->{th} = $child->{height} - $margin->{top} - $margin->{bottom};
}

sub is01
{
	return 1 if ($_[0] <= 1 && $_[0] >= 0);
}
#------------------------------------------------------------------------------------
#---------------------------------------------------------------

sub fetch_infile
{
	my $temp = shift;
	my $infile;

	if (ref $temp eq "HASH")
	{
		$infile = $temp->{file};	
	}
	else
	{
		$infile = $temp;
	}
	
	ERROR('no_file') if (! defined $infile);

	$infile = check_path($infile);

	ERROR('no_file_exists') if ($infile eq "");

	return $infile;
}


#-------------------------------------------------------------------------------
#  fetch the edge_margin
#-------------------------------------------------------------------------------
sub fetch_margin
{
	my $conf = shift || $SBV::conf;
	if (! $conf->{'margin'})
	{
		return {top=>0,right=>0,bottom=>0,left=>0};
	}
	
	my $margin = $conf->{'margin'};

	my @margin = split (/\s+/,$margin);
	my $num = scalar @margin;

	if (1 == $num)
	{
		return {top=>$margin[0],right=>$margin[0],bottom=>$margin[0],left=>$margin[0]};	
	}
	elsif (4 == $num)
	{
		return {top=>$margin[0],right=>$margin[1],bottom=>$margin[2],left=>$margin[3]};	
	}
	else
	{
		WARN("margin config format is error, set the margin as 0");
		return {top=>0,right=>0,bottom=>0,left=>0};
	}
}

sub fetch_symbol_class
{
	my $conf = shift;
	
	my @shape = fetch_val($conf,'shape');
	my @lwd = fetch_val($conf,'lwd');
	my @opacity = fetch_val($conf,'fill-opacity');
	#my @col = fetch_val($conf,'col');
	#my @fill = fetch_val($conf,'fill');
	#@col = map { SBV::Colors::fetch_color($_) } @col;
	#@fill = map { SBV::Colors::fetch_color($_) } @fill;
    my @col  = SBV::Colors::fetch_brewer_color($conf->{col});
    my @fill = SBV::Colors::fetch_brewer_color($conf->{fill});

	my $maxlen = MAX_ARRAY(\@shape,\@lwd,\@opacity,\@col,\@fill);

	my @result;
	foreach my$i ( 0 .. $maxlen - 1)
	{
		my $shape = $shape[$i] || $shape[0];
		my $lwd = $lwd[$i] || $lwd[0];
		
		my $opacity = $opacity[$i] || $opacity[0];
		$opacity = int $opacity;
		$opacity = 0 if ($opacity < 0);
		$opacity = 100 if ($opacity > 100);
		$opacity = sprintf("%x",$opacity);
		my $len = length $opacity;
		$opacity = 0 . $opacity if (1 == $len);
		
		my $col = $col[$i] || $col[0];
		$col =~ s/^#//;
		
		my $fill = $fill[$i] || $fill[0];
		$fill =~ s/^#//;

		my $class = join "" , ($shape,$lwd,$opacity,$col,$fill);
		push @result , "symbol$class";
	}

	return \@result;
}

# fetch x,y coordinate value with the specific name
# like: top, left ,right ,bottom, ....
sub fetch_xy
{
	my ($name,$width,$height,$conf) = @_;
	my ($x,$y);
	
	$name = lc $name;

	if ($name eq "top")
	{
		$x = $conf->{ox} + $conf->{tw}/2 - $width/2;
		$y = $conf->{oty};
	}
	elsif ($name eq "topleft")
	{
		$x = $conf->{ox};
		$y = $conf->{oty};
	}
	elsif ($name eq "topright")
	{
		$x = $conf->{ox} + $conf->{tw} - $width;
		$y = $conf->{oty};
	}
	elsif ($name eq "right")
	{
		$x = $conf->{ox} + $conf->{tw} - $width;
		$y = $conf->{oty} + $conf->{th}/2 - $height/2;
	}
	elsif ($name eq "bottom")
	{
		$x = $conf->{ox} + $conf->{tw}/2 - $width/2;
		$y = $conf->{oy} - $height;
	}
	elsif ($name eq "bottomleft")
	{
		$x = $conf->{ox};
		$y = $conf->{oy} - $height;
	}
	elsif ($name eq "bottomright")
	{
		$x = $conf->{ox} + $conf->{tw} - $width;
		$y = $conf->{oy} - $height;
	}
	elsif ($name eq "left")
	{
		$x = $conf->{ox};
		$y = $conf->{oty} + $conf->{th}/2 - $height/2;
	}
	elsif ($name eq "center")
	{
		$x = $conf->{ox} + $conf->{tw}/2 - $width/2;
		$y = $conf->{oty} + $conf->{th}/2 - $height/2;
	}
	elsif ($name eq "outright")
	{
		$x = $conf->{ox} + $conf->{tw} + $SBV::conf->{hspace};
		$y = $conf->{oty} + $conf->{th}/2 - $height/2;
	}
	elsif ($name =~ /(\d+)\s+(\d+)/)
	{
		$x = $1;
		$y = $2;
	}
	else 
	{
		ERROR('legend_loc_err',$name);	
	}

	return ($x,$y);
}

# fetch valus (default)
sub fetch_val
{
	my $conf = shift;
	my $name = shift;
	
	ERROR('no_attr',$name) if (! defined $conf->{$name});

	my @values = split /[\s\t]+/ , $conf->{$name};
	return @values;
}


# fetch the radius
sub fetch_radius
{
	my $conf = shift;
	my $radius = min([$conf->{tw},$conf->{th}])/2;

	return $radius if (! defined $conf->{ideogram}->{radius});
	return rvalue($conf->{ideogram}->{radius},$radius);	
}

# fetch the spacing
sub fetch_spacing
{
	my $conf = shift;
	my $name = shift;
	
	return 0 if (! defined $conf->{spacing});
	
	my $spacing = rvalue($conf->{spacing}->{default},$TWOPI);
	return $spacing if (! defined $conf->{spacing}->{pairwise});
	
	foreach my$key (%{$conf->{spacing}->{pairwise}})
	{
		my ($name1,$name2) = split /;/ , $key;
		if ($name1 eq "$name")
		{
			return rvalue($conf->{spacing}->{pairwise}->{$key}->{spacing},$spacing);
		}
	}

	return $spacing;
}

# get relative value
sub rvalue
{
	my $value = shift;
	my $parent = shift;
	
	if ($value =~ /([\d\.]+)r$/)
	{
		return $parent * $1;	
	}
	else
	{
		$value;	
	}
}

sub MAX_ARRAY
{
	my $max = 0;
	foreach my$arr(@_)
	{
		my$num = scalar @$arr;
		$max = $num if ($max < $num);
	}

	return $max;
}

sub fetch_venn_style
{
	my $conf = shift;
	my $num = shift;
	my @styles;
	
	my @fill_color;
	if (! defined $conf->{fill}) # default CMG_Lee
	{
		@fill_color = ("#0000ff","#0099ff","#00cc00","#cc9900","#ff0000");
	}
	elsif ($conf->{fill} eq "rainbow")
	{
		@fill_color = SBV::Colors::rainbow($num);
	}
	# This fill colors is from the Radially-symmetrical Five-set Venn Diagram 
	# at wiki web site which is Devised by Branko Gruenbaum and rendered by CMG Lee.
	elsif ($conf->{fill} eq "CMG_Lee")
	{
		@fill_color = ("#0000ff","#0099ff","#00cc00","#cc9900","#ff0000");
	}
	elsif ($conf->{fill} eq "none")
	{
		@fill_color = ("none");
	}
	else
	{
		@fill_color = SBV::Colors::fetch_brewer_color($conf->{fill});
	}
	
	for my$i(0 .. $num-1)
	{
		my $f = loop_arr(\@fill_color,$i);
		$styles[$i] = "fill:$f;stroke-width:$conf->{stroke_width};";
	}
    

	if ($conf->{col})
	{
		#my @col = SBV::CONF::fetch_val($conf,"col");
		my @col = SBV::Colors::fetch_brewer_color($conf->{col});
		for my$i(0 .. $num-1)
		{
			my $c = loop_arr(\@col,$i);
			$styles[$i] .= "stroke:$c;";
		}
	}

	return @styles;
}

# 
sub fetch_styles
{
	my (%opts) = @_;
	
	default(\%opts,"stroke_width",1);
	default(\%opts,"fill","#000");
	default(\%opts,"color","#000");
	$opts{color} = SBV::Colors::fetch_color($opts{color});
	$opts{fill} = SBV::Colors::fetch_color($opts{fill});

	return "stroke:$opts{color};stroke-width:$opts{stroke_width};fill:$opts{fill}";
}

sub attrs2style {
    my %attrs = @_;

    my $color = $attrs{color} ? SBV::Colors::fetch_color($attrs{color}) : "black";
    my $fill  = $attrs{fill}  ? SBV::Colors::fetch_color($attrs{fill})  : "none";
    my $swidth = $attrs{stroke_width} || 0;
    
    my $style = "stroke:$color;stroke-width:$swidth;fill:$fill;";
    $style .= "fill-opacity:$attrs{opacity}" if ($attrs{opacity});

    return $style;
}
