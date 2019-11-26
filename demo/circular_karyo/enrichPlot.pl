#!/Bio/bin/perl
#-----------------------------------------------+
#    [APM] This script was created by amp.pl    |
#    [APM] Created time: 2019-11-08 15:43:32    |
#-----------------------------------------------+
# name: enrichPlot.pl
# func: 
# version: 1.0

use strict;
use warnings;
use List::Util qw/max min/;
use FindBin qw/$Bin/;

use Getopt::Std;

my $sbv = "/Bio/bin/perl /home/aipeng/work/develepment/SBV/bin/sbv.pl";
my $styles_conf = "/home/aipeng/work/develepment/SBV/demo/circular_karyo/styles.karyo.conf";

my %opts = (m=>"bar",p=>10,f=>"auto",s=>"qvalue",S=>"rf",t=>20);
getopts("m:p:f:t:o:s:S:d:",\%opts);

&usage unless @ARGV == 1;
my $result = shift @ARGV;

$opts{f} = check_format($opts{f},$result);

my %colors = (
BP=>"F7CB16",CC=>"BFE046",MF=>"65C3FC",
'Biological Process'=>"F7CB16",
'Molecular Function'=>'65C3FC',
'Cellular Component'=>'BFE046',

DO=>"EFA707",Rectome=>"EFA707",

"Metabolism"=>"F7CB16","Genetic Information Processing"=>"E66440",
"Environmental Information Processing"=>"954276",
"Cellular Processes"=>"2E166C","Organismal Systems"=>"0193DC",
"Human Diseases"=>"0DA78F","Drug Development"=>"84C126",

degs=>"EF0707",up=>"69115D",down=>"838BC5",fg=>"69115D",
);
        
my @all_class = $opts{f} eq "go" ? ('Biological Process','Molecular Function','Cellular Component') : 
                $opts{f} eq "ko" ? ("Metabolism","Genetic Information Processing","Environmental Information Processing",
                                    "Cellular Processes","Organismal Systems","Human Diseases","Drug Development") : 
                $opts{f} eq "do" ? ("DO") : 
                $opts{f} eq "rectome" ? ("Rectome") : ();

my $isdiff = $opts{d} ? 1 : 0;
my %degs = read_degs($opts{d}) if ($opts{d});

open my $ofh_karyo , ">" , "karyotype.txt"   or die $!;
open my $ofh_gnum  , ">" , "gene_number.txt" or die $!;
open my $ofh_degs  , ">" , "degs_number.txt" or die $!;
open my $ofh_rf    , ">" , "rich_factor.txt" or die $!;
open my $ofh_ratio , ">" , "degs_ratio.txt"  or die $!;
open my $ofh_scatter , ">" , "gene_number.scatter.txt" or die $!;

my @data = read_result($result,$opts{f});
@data = rawdata_sort(@data) if ($opts{s} && $opts{s} ne "no");
@data = @data[0 .. $opts{t}-1] if ($opts{t});
@data = data_sort(@data) if ($opts{S} && $opts{s} ne "no");
my $term_num = scalar @data;

die "The number of term is too much (>30), [$term_num], 20 is recommended!\n" if ($term_num > 30);

# deal the background gene number
my @bgnums = map { $_->[4]  } @data;
my $max_bgnum = max(@bgnums);
my $islog10 = $opts{m} eq "bar" ? 1 : 0;
$max_bgnum = log10($max_bgnum) if $islog10;
$max_bgnum = 3 if ($max_bgnum < 3);

# deal the rich factor
my @rfs = map { $_->[6] } @data;
my $max_rf = max(@rfs) * 10;
$max_rf = int($max_rf) == $max_rf ? $max_rf/10 : (int($max_rf)+1)/10;

# deal the foreground gene number
my @fgnums = map { $_->[3] } @data;

# calc the scatter size 
my $min = min(@bgnums);
my $max = $max_bgnum;
my $width = $max - $min;
my $s0 = 20;
my $s1 = 40;
my $size = $s1 - $s0;

my %class = ();

foreach (@data){
    my ($id,$term,$class,$fgnum,$bgnum,$qvalue,$rf) = @$_;
    
    $bgnum = log10($bgnum) if $islog10;

    my $name = $& if ($id =~ /\d+/);
    my $color = $colors{$class} or die "[$class] is not exists!";
    $class{$class} = 1;

    print $ofh_karyo "$id\t$name\t1\t$max_bgnum\t$color\n";
    print $ofh_rf    "$id\t0\t$max_bgnum\t$rf\tfill=$color\n";
    
    my $fill = qv2color($qvalue);
    print $ofh_gnum  "$id\t0\t$bgnum\tfill=$fill\n";
    
    if ($fgnum =~ /;/){
        $isdiff = 1;

        my ($up,$down) = split /;/ , $fgnum;
        my $ratio = $up / ($up + $down);
        my $break = $max_bgnum * $ratio;
        print $ofh_degs "$id\t0\t$break\tfill=$colors{up}\n";
        print $ofh_degs "$id\t$break\t$max_bgnum\tfill=$colors{down}\n";
        
        $ratio = sprintf "%d" , $ratio * 100;
        my $text = sprintf "%d%%,%d%%" , $ratio , 100-$ratio;
        print $ofh_ratio "$id\t0\t$max_bgnum\t$text\n";

        $fgnum = $up + $down;
    }else{
        $fgnum = log10($fgnum) if $islog10;
        print $ofh_degs "$id\t0\t$fgnum\tfill=$colors{fg}\n";
        #$isdiff = 1;
        #my $ratio = rand(1);
        #my $break = $max_bgnum * $ratio;
        #print $ofh_degs "$id\t0\t$break\tfill=$colors{up}\n";
        #print $ofh_degs "$id\t$break\t$max_bgnum\tfill=$colors{down}\n";
        #$ratio = sprintf "%d" , $ratio * 100;
        #my $text = sprintf "%d%%,%d%%" , $ratio , 100-$ratio;
        #print $ofh_ratio "$id\t0\t$max_bgnum\t$text\n";
    }
    
    my $r = ($bgnum - $min)/$width;
    my $s = $s0 + $size * $r;
    print $ofh_scatter "$id\t0\t$max_bgnum\t0.5\tradius=$s;fill=$fill;val=$bgnum;\n";
}

close $_ for ( $ofh_karyo , $ofh_gnum , $ofh_degs , $ofh_rf , $ofh_ratio , $ofh_scatter );

if ($opts{m} eq "bar"){
    my $prefix = $opts{o} // uc($opts{f}) . "_enrich_circular";
    &create_karyo("bar",$opts{f},$isdiff,"$prefix.conf");
    system("$sbv karyo -conf $prefix.conf -out $prefix");
}else{
    my $prefix = $opts{o} // uc($opts{f}) . "_enrich_circular.scatter";
    &create_karyo("scatter",$opts{f},$isdiff,"$prefix.conf");
    system("$sbv karyo -conf $prefix.conf -out $prefix");
}

#-------------------------------------------------------------------------------
#  sun functions
#-------------------------------------------------------------------------------
sub create_karyo {
    my ($model,$format,$isdiff,$cnf_file) = @_;

    my $legends = create_legends($model,$format,$isdiff);
    open my $fh_legend , ">legends.conf" or die $!;
    print $fh_legend $legends;
    close $fh_legend;

    my $spacing = 0.1 / $max_rf;
    my $gnum_spacing = div_spacing ($max_bgnum , 3);
    my $power = $islog10 ? $opts{p} : 1;

    my $gnum_ticks = <<TEXT;
<ticks>
offset = 0
orientation = outer
<tick>
chromosomes = 
thickness = 1
size = 8
show_label = yes
spacing = $gnum_spacing
label_power = $power
tick_label_theme = 
</tick>
</ticks>
TEXT

    my $scatte_hls = <<TEXT;
<highlights>
<highlight>
file = degs_number.txt
r0 = 0.88r + 6u
r1 = 0.88r - 6u
</highlight>
</highlights>

TEXT
    my $bar_hls = <<TEXT;
<highlights>
<highlight>
file = gene_number.txt
r0 = 0.9r + 6u
r1 = 0.9r - 6u
</highlight>

<highlight>
file = degs_number.txt
r0 = 0.82r + 6u
r1 = 0.82r - 6u
</highlight>
</highlights>
TEXT

    my $scatte_plot = <<TEXT;
<plot>
file = gene_number.scatter.txt
type = scatter
r0 = 1r + 10u
r1 = 1r + 14u
min = 0
max = 1
fill = FA7589
clip = yes
opacity = 1
stroke_width = 0
show_val = yes
</plot>

<plot>
file = degs_ratio.txt
type = text
r0 = 0.86r - 6u
r1 = 0.86r - 10u
show_links = no
label_parallel = yes
</plot>
TEXT

my $bar_plot = <<TEXT;
<plot>
file = degs_ratio.txt
type = text
r0 = 0.8r - 6u
r1 = 0.8r - 10u
show_links = no
label_parallel = yes
</plot>
TEXT

    my $plot       = $model eq "scatter" ? $scatte_plot : $bar_plot;
    my $ticks      = $model eq "scatter" ? ""           : $gnum_ticks;
    my $highlights = $model eq "scatter" ? $scatte_hls  : $bar_hls;

    my $conf = <<CONF;
dir  = .
file = GOenrich_circular

width = 960
height = 720
margin = 20 160 20 20
background = 

<karyo>
file = karyotype.txt
model = circular
rotation = 0
radius = 300

<ideogram>
show = yes
thickness = 20
show_chromosomes_default = yes
chromosomes_color = yes
chromosomes_stroke_width = 0
show_label = yes
label_with_tag = no
label_center = yes
label_radius = 1r
label_parallel = yes

<spacing>
default=0.004r
</spacing>
</ideogram>

$ticks

$highlights

<plots>
$plot

<plot>
file = rich_factor.txt
type = histogram
r0 = 0.3r
r1 = 0.75r - 6u
min = 0 
max = $max_rf
stroke_width = 0

<backgrounds>
<background>
color = F0F0F0
</background>
</backgrounds>

<axes>
<axis>
spacing = ${spacing}r
color = D0D0D0
</axis>
</axes>

</p1ot>

</plots>
</karyo>

<<include legends.conf>>
<<include etc/colors.conf>>
<<include $styles_conf>>

CONF

    open my $ofh_conf , ">" , $cnf_file or die $!;
    print $ofh_conf $conf;
    close $ofh_conf;
}

sub create_legends {
    my ($model,$format,$isdiff) = @_;

    my @classes = keys %class;
    my $class_num = scalar @classes;
    
    my $gnum_shape = $model eq "scatter" ? 43 : 1;
    my $gnum_fill  = $model eq "scatter" ? "red" : "69115D";
    my $rf_fill    = $class_num == 1 ? $colors{$classes[0]} : "A0A0A0";
    my $label = $isdiff ? qq("'Rich Factor(0~1)' 'Number of Genes' Up-regulated Down-regulated") : 
                          qq('Rich Factor(0~1)' 'Number of Genes' 'Number of DEGs');
    my $shape = $isdiff ? "42 $gnum_shape 1 1" : "42 $gnum_shape $gnum_shape";
    my $fill  = $isdiff ? "$rf_fill red 69115D 838BC5" : "$rf_fill red $gnum_fill";
    my $center_legend = <<CONF;
<legend>
pos = center

label = $label
label_show = TRUE
label_pos = right
label_theme = size:12;font:arial;face:normal;

ncol   = 1
shape  = $shape
color  = none
fill   = $fill
width  = 40
height = 20
</legend>
CONF
    
    my $class_legend = "";
    my $clh  = 272 - 12*$class_num;
    my $qvlh = $clh + 24*($class_num+1);
    if ($class_num > 1){
        my @read_class = grep { $class{$_}  } @all_class;
        my @class_fill = map  { $colors{$_} } @read_class;
        @read_class = map { qq('$_') } @read_class;
        my $class_label = join " " , @read_class;
        my $class_fill  = join " " , @class_fill;

        $class_legend = <<CONF;
<legend>
pos = 800 $clh

label = $class_label
label_show = TRUE
label_pos = right
label_theme = size:12;font:arial;face:normal;

ncol = 1
shape = 0
color = none
fill  = $class_fill
width = 20
height = 20

</legend>
CONF
    }else{
        $qvlh = 250
    }

    
    my $qv_legend = <<CONF;
<legend>
pos = 800 $qvlh

title = -log10(Qvalue)
title_pos = top
title_theme = size:12;family:arial;weight:normal;
label = (0,1.3] (1.3,2] (2,5] (5,10] (10,15] (15,20] >=20
label_show = TRUE
label_pos  = right
width  = 20
height = 20
fill   = reds-7-seq
opacity = 1
color  = none
vspace = 4
</legend>
CONF
    
    my $legends = <<CONF;
<legends>
$center_legend

$class_legend

$qv_legend
</legends>
CONF
    return $legends;
}

sub qv2color {
    my $qv = shift;

    my $color = $qv < 1.3  ? "vvlred"     : 
        $qv < 2    ? "vlred"   : 
        $qv < 5    ? "lred"    :
        $qv < 10   ? "red"     :
        $qv < 15   ? "dred"    : 
        $qv < 20   ?  "vdred"  : "vvdred";

    return $color;

}

sub div_spacing {
    my ( $max , $div ) = @_;
    
    my $spacing = $max / $div;
    $spacing  = sprintf ("%e",$spacing);
    my ($num,$unit) = split /e/ , $spacing;
    $num = int($num);
    $spacing = eval sprintf ("%d" , $num . "e" . $unit);
    
    return $spacing;
}

sub read_result {
    my $file = shift;
    my $format = lc shift;

    my %funcs = (
        go => \&read_go_result,
        ko => \&read_ko_result,
        do => \&read_do_result,
        rectome => \&read_rectome_result,
    );
    
    my @data = $funcs{$format} ? &{$funcs{$format}}($file) : die "the format [$format] is support!";
    return @data;
}

sub read_go_result {
    my $result = shift;
    my @data;
    my %fullname = ("BP"=>"Biological Process",MF=>"Molecular Function",CC=>"Cellular Component");

    open my $fh , $result or die $!;
    <$fh>;
    while(<$fh>){
        chomp;
        my ($class,$id,$term,$fgnum,$bgnum,$qvalue,$genes) = (split /\t/)[0,1,2,3,4,6,-1];
        $class = $fullname{$class} if ($fullname{$class});
        my $rf = sprintf "%.4f" , $fgnum / $bgnum;
        $fgnum = calc_updown($fgnum,$genes,\%degs) if ($opts{d});
        push @data , [$id,$term,$class,$fgnum,$bgnum,-log($qvalue)/log(10),$rf];
    }
    close $fh;
    return @data;
}

sub read_ko_result {
    my $result = shift;
    my @data;
    
    open my $fh , $result or die $!;
    <$fh>;
    while(<$fh>){
        chomp;
        my ($class,$pathway,$fgnum,$bgnum,$qvalue,$id,$genes) = (split /\t/)[0,2,3,4,6,7,-2];
        my $rf = sprintf "%.4f" , $fgnum / $bgnum;
        $fgnum = calc_updown($fgnum,$genes,\%degs) if ($opts{d});
        push @data , [$id,$pathway,$class,$fgnum,$bgnum,-log($qvalue)/log(10),$rf];
    }
    close $fh;
    return @data;
}

sub read_do_result {
    my $result = shift;
    my @data;
    
    open my $fh , $result or die $!;
    <$fh>;
    while(<$fh>){
        chomp;
        my ($id,$name,$fgnum,$bgnum,$qvalue,$genes) = (split /\t/)[0,1,3,4,6,-1];
        my $rf = sprintf "%.4f" , $fgnum / $bgnum;
        $fgnum = calc_updown($fgnum,$genes,\%degs) if ($opts{d});
        push @data , [$id,$name,"DO",$fgnum,$bgnum,-log($qvalue)/log(10),$rf];
    }
    close $fh;
    return @data;
}

sub read_rectome_result {
    my $result = shift;
    my @data;
    
    open my $fh , $result or die $!;
    <$fh>;
    while(<$fh>){
        chomp;
        my ($id,$name,$fgnum,$bgnum,$qvalue,$genes) = (split /\t/)[0,1,3,4,6,-1];
        my $rf = sprintf "%.4f" , $fgnum / $bgnum;
        $fgnum = calc_updown($fgnum,$genes,\%degs) if ($opts{d});
        push @data , [$id,$name,"Rectome",$fgnum,$bgnum,-log($qvalue)/log(10),$rf];
    }
    close $fh;
    return @data;
}

sub log10 {
    return log($_[0]) / log($opts{p});
}

sub data_sort {
    my @data = @_;
    my %order = map { $all_class[$_] => $_ } 0 .. $#all_class;

    if ($opts{S} eq "qvalue"){
        @data = sort { $order{$a->[2]} <=> $order{$b->[2]} || $b->[5]<=>$a->[5] } @data;
    }elsif ($opts{S} eq "genes"){
        @data = sort { $order{$a->[2]} <=> $order{$b->[2]} || $b->[4]<=>$a->[4] } @data;
    }elsif ($opts{S} eq "degs"){
        @data = sort { $order{$a->[2]} <=> $order{$b->[2]} || $b->[3]<=>$a->[3] } @data;
    }elsif ($opts{S} eq "rf"){
        @data = sort { $order{$a->[2]} <=> $order{$b->[2]} || $b->[6]<=>$a->[6] } @data;
    }elsif ($opts{S} eq "class"){
        @data = sort { $order{$a->[2]} <=> $order{$b->[2]} } @data;
    }
    

    return @data;
}

sub rawdata_sort {
    my @data = @_;

    if ($opts{s} eq "qvalue"){
        @data = sort { $b->[5]<=>$a->[5] } @data;
    }elsif ($opts{s} eq "genes"){
        @data = sort { $b->[4]<=>$a->[4] } @data;
    }elsif ($opts{s} eq "degs"){
        @data = sort { $b->[3]<=>$a->[3] } @data;
    }elsif ($opts{s} eq "rf"){
        @data = sort { $b->[6]<=>$a->[6] } @data;
    }
    
    return @data;
}

sub check_format {
    my $format = lc shift;
    my $file = shift;
        
    if ($format eq "auto"){
        open my $fh , $file or die $!;
        <$fh>;
        my $line = <$fh>;
        my @fields = split /\t/ , $line;
        if ($fields[1] =~ /^GO:/){
            $format = "go";
        }elsif ($fields[7] =~ /^ko\d{5}$/){
            $format = "ko";
        }elsif ($fields[0] =~ /^DOID:\d+/){
            $format = "do";
        }elsif ($fields[0] =~ /^R-/){
            $format = "rectome";
        }
        close $fh;
    }

    return $format;
}

sub read_degs {
    my $file = shift;
    my %degs;

    open my $fh_degs , $file or die $!;
    while(<$fh_degs>){
        chomp;
        my ($id,$logfc) = split /\t/;
        my $flag = $logfc >= 1  ? "up"   :
                   $logfc <= -1 ? "down" : "no";
        
        $degs{$id} = $flag;
    }
    close $fh_degs;
    
    return %degs;
}

sub calc_updown {
    my ($fgnum,$genes,$degs) = @_;
    
    return $fgnum if ($fgnum =~ /;/);
    
    my $updown;
    my @up = grep { $degs->{$_} && $degs->{$_} eq "up" } map { s/\(.+\)//; $_ } split /;/ , $genes;
    my $up = scalar @up;
    my $down = $fgnum - $up;
    die "[$fgnum] degs list is conflict with enrich result file!" if ($down < 0);
    
    $updown = "$up;$down";
    return $updown;
}

sub usage {
    print <<HELP;

Usage:   perl $0 [options] <Enrichment analysis result>

Options: -m STR    the figure model, bar/scatter to plot annoted gene number, [bar]
         -p INT    the base of the logarithm  of annoted gene number, just for "bar" model [10]
         -s STR    sort the record before filter by 'qvalue|genes|degs|rf|no', [qvalue]
         -S STR    sort the record after  filter by 'qvalue|genes|degs|rf|class|no', [rf]
         -t INT    fetch the top number record, [20] 
         -o STR    the output file name, optional

HELP
    exit;
}