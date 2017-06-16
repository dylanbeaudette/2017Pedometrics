## 2017 Pedometrics talk on Soilscapes / Networks
## P. Roudier and D.E. Beaudette


library(igraph)
library(RColorBrewer)
library(sharpshootR)
library(plyr)

# load cached NASIS data
load('cached-nasis.rda')

# convert component data into adjacency matrix, weighted by component percentage
m <- component.adj.matrix(x, mu='musym', co='compname', wt='comppct_r')

## TODO: hand-make graph for more control
# make graph using defaults specified in sharpshootR::plotSoilRelationGraph()
g <- plotSoilRelationGraph(m, main='Calaveras/Tuolumne Co. Soil Survey', plot.style = 'none')

# community / cluster labels are returned as of
# https://github.com/ncss-tech/sharpshootR/commit/5797803c46b1043f658d852624d09ca15df89f17
V(g)$cluster

## important note: the graph and associated communities / colors are stable between runs (set.seed used in plotSoilRelationGraph)
## this means we can rely on the cluster numbers as an index to expert interpretation

# load expert interp and add to graph attributes
d.interp <- read.csv(file='expert-interp.csv', stringsAsFactors = FALSE)
V(g)$notes <- d.interp$notes[match(V(g)$cluster, d.interp$cluster)]

# extract vertex attributes for interpretation and linking to MU data
d <- as_data_frame(g, what='vertices')
names(d)[1] <- 'compname'


## only need to do this to help with expert interpretation
# # make text file with component names within each cluster
# sink(file = 'cluster-correlation-notes.txt')
# d_ply(d, 'cluster', function(i) {
#   cat(paste0('--------------', i$cluster[1], '---------------\n'))
#   write.table(i[, c('compname')], row.names=FALSE, col.names = FALSE)
#   })
# sink()


# nasty hack to get a reasonable legend
leg <- unique(data.frame(cluster=V(g)$cluster, color=V(g)$color, notes=V(g)$notes, stringsAsFactors = FALSE))
leg <- leg[order(leg$cluster), ]

# save a copy of the output for expert review
pdf(file='ca630-network.pdf', width=15, height=15)
par(mar=c(0,0,2,0))
plotSoilRelationGraph(m, vertex.scaling.factor=1, main='Calaveras/Tuolumne Co. Soil Survey', vertex.label.family='sans', vertex.label.cex=0.65)

legend('bottomleft', legend=paste0(leg$cluster, ') ', leg$notes), col=leg$color, pch=15, ncol = 4, cex=0.5)
dev.off()



# save
save(m, g, d, leg, file='cached-graph.rda')

