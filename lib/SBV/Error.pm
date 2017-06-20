package SBV::Error;
#------------------------------------------------+
#    [APM] This moudle is generated by amp.pl    |
#    [APM] Creat time: 2013-05-13 15:29:40       |
#------------------------------------------------+
=pod

=head1 Name

SBV::Error -- defined the error for SBV

=head1 Synopsis

This module is not meant to be used directly

=head1 Feedback

Author: Peng Ai
Email:  aipeng0520@163.com

=head1 Version

Version history

=head2 v1.0

Date: 2013-05-13 15:29:40

=cut

use strict;
use warnings;

our %ERROR;

%ERROR = (
	# map type error
	'no_type' => 'SBV image type must be defined for running SBV',
	'image_type_err' => "can't recognize the SBV type",
	
	# Configuration error
	'no_conf' => 'Configuration file must be defined for running SBV',
	'no_conf_path' => "Configuration file path is not correct, please check and set the correct file path.",
	'no_conf_plot' => "config about plot is needed.",
	'no_conf_pie' => "config about pie is needed",
	'no_conf_child' => 'Configuration for specific child is not exists',
	'illegal_style' => 'the style key is illegal',
	
	# color error
	'color_format_err' => 'This color format is not supported by SBV.',
	'no_file_color' => "the color is not defined in the file, please reset the Configuration file",
	'rainbow_num_err' => "the colors number must be equal to or greater than 0",

	# file error
	'no_file' => 'The file is not defined',
	'no_file_plot' => 'You must set the data file for plot',
	'no_file_exists' => 'The file is not exists',

	# data file error
	'no_data_format' => 'This format is not supported',
	'table_column_diff' => "The column number is must be same in one table file",
	'no_data_err' => "There is no available data in the data file(please check the rownames is defined or not)",

	# 
	'no_loc' => "can't find the localtion info",

	'legend_loc_err' => "can't recognize the legend location character",
	'legend_text_err' => "legend text must be set",
	'legend_no_types_err' => "types is needed for legend draw",
	'legend_no_cols_err' => "cols is needed for legend draw",
	'legend_no_pchs_err' => "pchs is needed for legend draw",

	'no_attr' => "the attribute is not exists",

	# frame
	'frame_row_len_err' => "the line number in the data is different",
	'frame_col_len_err' => "the colomn number in the data is different",

	# pch 
	'no_pch_err' => "this symbol pch type is not supported now",
	'plot_type_HA_err' => "the type 'h' and 'a' is not compatible",
	
	# axis
	'axis_point_coord_err' => "the axis origin point coord and axis length must be defined!",
	'axis_length_err' => "the axis length must be defined and must be positive",
	'axis_parent_err' => "the axis parent object must be defined",

	#karyotype
	'karyotype_not_exists' => 'karyotype is not exists',
	'karyotype_overflow' => 'karyotype is overflow',
	'karyotype_chr_exists_err' => 'the chr is defined multi times in the karyotype file',
	'ticks_oriental_err' => "the oriental text is illegal",
	'no_plot_type' => "plot type must be defined for plot",
	
	# ggplot2
	'ggplot2_eval_err' => 'there are error in the the ggplot2 command',
	'ggplot2_no_data' => 'the data is must be assigned for drawing ggplot2 graph',
	'ggplot2_no_z'   => 'the z name is not assigned',
	'ggplot2_stat_method_err' => 'this method is not supported now',
	'ggplot2_order_err' => 'the names in order is not exists in data',
	'no_axis_limit' => 'the yaxis or xaxis limit is not defined',
	
	# venn
	'venn_sample_num_err' => "now just support 2-5 samples venn graph",

	# tree
	'negative_length_err' => "the length can't be negative interger",
	'tree_width_err' => "the tree width can't be negative interger",

	# heatmap 
	'err_heatmap_order' => "the heatmap order info must be in ['default','tree']",

	# pie 
	'pie_radius_er' => "the width or height is not enough for pie",
	
	# hcgd
	'chr_round_ratio_err' => "the chromosomes rounded ratio must be in 0-0.5",

	'END'=>'END'
);
