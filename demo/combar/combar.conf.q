dir = .
file = combar.svg 

height = 600
width = 1200

hspace = 6

<combar>
file = /Bio/Project/PROJECT/GDR0419/add_analysis_graph/kegg/all.kegg.bar.dat.q.txt
header = 1

margin = 20 200 20 20

# tick size int aixs x or y 
tick_size_x = 6
tick_size_y = 6

# free_x = 0, means all bars use the same scale ticks
# free_x = 1, means all bars use the different scale ticks
free_x = 0

# x limits, effective with free_x = 0
# xlim = 0 400

# the bar height (thickness), relative value, 0-1
size = 0.6

colors = 55A0FB
xlab = Number of genes

# show the col names or not 
display_colnames = 1
display_rownames = 1

#<<include legend.conf>>
</combar>

<styles>
<<include styles.combar.conf>>
</styple>
