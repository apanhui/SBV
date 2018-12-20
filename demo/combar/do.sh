for i in *.path.xls; do awk -F "\t" '$4<0.05' $i > $i.p; done
awk -F "\t" '{printf("%s\t%s\t%s\t%s\n",$1,$2,"CK1-VS-CK2","Pathway")}' CK1-VS-CK2.path.xls.p > CK1-VS-CK2.path.xls.p.forBar
