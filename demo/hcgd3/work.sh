cut -f 1 ../2.classify/class.xls|grep 'L' |sort -u |shoppingList -l - -t ../0.download/Lj3.0_gene_models.gff3 -w buy >l.gff
cut -f 1 ../2.classify/class.xls|grep 'M' |sort -u |shoppingList -l - -t ../0.download/Mt4.0v1_genes_20130731_1800.gff3 -w buy >m.gff

cut -f 1 ../2.classify/class.xls|grep 'L' |sed 's/\..\+//' |sort -u|shoppingList -l - -t ../0.download/Lj3.0_gene_models.gff3 -w buy|grep '\sgene\s'>l.gene.gff
cut -f 1 ../2.classify/class.xls|grep 'M' |sed 's/\..\+//' |sort -u|shoppingList -l - -t ../0.download/Mt4.0v1_genes_20130731_1800.gff3 -w buy|grep '\sgene\s'>m.gene.gff
