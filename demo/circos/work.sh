perl gc_ratio.pl -step 100 -win 10000 KpC4.fa
awk '{print $1" "$3" "$4" fill_color=black"}' /Bio/Project/PROJECT/GDD1108/pipe/3_Component/KpC4/ncRNA/KpC4.tRNA |awk 'NR>3' >ncRNA.txt
awk '{print $1" "$4" "$5" fill_color=black"}' /Bio/Project/PROJECT/GDD1108/pipe/3_Component/KpC4/ncRNA/KpC4.rRNA.gff |grep -v "#" >>ncRNA.txt
perl cds_function_clsss.pl /Bio/Project/PROJECT/GDD1108/pipe/4_annot/KpC4/2_Basic_Databases_Annot/COG/KpC4.fa.cog.class.annot.xls /Bio/Project/PROJECT/GDD1108/pipe/3_Component/KpC4/Gene-Predict/KpC4.gff ./
perl /home/aipeng/work/develepment/SBV/bin/sbv.pl karyo -conf circular_karyo.conf
