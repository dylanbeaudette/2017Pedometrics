library(aqp)
library(sharpshootR)
library(soilDB)
library(igraph)
library(cluster)
library(ape)
library(MASS)

data(sp4)
depths(sp4) <- id ~ top + bottom


## TODO: consider an option for returning similarity instead of distances
d <- profile_compare(sp4, c('ex_Ca_to_Mg', 'CEC_7'), k=0, max_d=50)

d.m <- as.matrix(d)

## this method results in a linear transformation of D -> S
# convert distance mat to similarity mat
m <- max(d.m) - d.m

# ## this method results in a non-linear transformation of D -> S
# m <- 1 / (1 + d.m)


## distributions are now much more similar: duh: all of the 0's ! was causing confusion
m[lower.tri(m)] <- NA
# set diag to 0: no self-loops
diag(m) <- NA

par(mar=c(4,4,3,1), mfrow=c(2,2))
hist(d.m)
hist(m)
plot(quantile(d.m, probs = seq(0,1, by=0.1), na.rm=TRUE), quantile(m, probs = seq(0,1, by=0.1), na.rm=TRUE), xlab='dist', ylab='sim', las=1)
abline(0,1)
plot(d.m, m)

## use 0 instead of NA, more explicitly encodes similarity
# only keep the upper triangle for non-directional networks
m[lower.tri(m)] <- 0
# set diag to 0: no self-loops
diag(m) <- 0



## compare max spanning tree (sim. matrix) vs. min spanning tree (dist. matrix)
## should be the same: yes
par(mar=c(1,1,3,1), mfrow=c(1,2))
plotSoilRelationGraph(m, spanning.tree = 'max', main='Similarity Matrix\nMax Spanning Tree')
plotSoilRelationGraph(d.m, spanning.tree = 'min', main='Distance Matrix\nMin Spanning Tree')



# NMDS
s <- sammon(d)

par(mar=c(1,1,1,1), mfrow=c(2,4))
plot(as.phylo(as.hclust(diana(d))), main='Divising Hierarchical Clustering', cex=1)

plot(s$points, type='n', axes=FALSE, main='NMDS')
text(s$points, rownames(s$points))
box()

plotSoilRelationGraph(m, spanning.tree = 'max', main='Max Spanning Tree')
box()
plotSoilRelationGraph(m, spanning.tree = 'min', main='Min Spanning Tree')
box()

plotSoilRelationGraph(m, del.edges=0.05, main='Edges > Q05')
box()
plotSoilRelationGraph(m, del.edges=0.25, main='Edges > Q25')
box()
plotSoilRelationGraph(m, del.edges=0.50, main='Edges > Q50')
box()
plotSoilRelationGraph(m, del.edges=0.75, main='Edges > Q75')
box()


# more informative
png(file='soil-profile-distance-MDS-graphs.png', type = 'cairo', antialias = 'subpixel', width=1000, height=800, res = 90)
layout(matrix(c(1,1,1,2,3,4,5,6,7), nrow = 3, byrow = TRUE))
# layout.show(7)
par(mar=c(1,1,3,1))

plotProfileDendrogram(sp4, diana(d), dend.y.scale = max(d), scaling.factor = (1/max(d) * 15), y.offset = 5, width=0.15, cex.names=0.75, color='ex_Ca_to_Mg', col.label='Exchageable Ca to Mg Ratio')

plot(s$points, type='n', axes=FALSE, main='NMDS')
text(s$points, rownames(s$points))
box()

plotSoilRelationGraph(m, spanning.tree='max', main='Max Span. Tree', vertex.label.family='sans')
box()

plotSoilRelationGraph(m, spanning.tree=0.75, main='Max Span. Tree + Edges > Q75', vertex.label.family='sans')
box()
plotSoilRelationGraph(m, spanning.tree=0.50, main='Max Span. Tree + Edges > Q50', vertex.label.family='sans')
box()
plotSoilRelationGraph(m, spanning.tree=0.25, main='Max Span. Tree + Edges > Q25', vertex.label.family='sans')
box()
plotSoilRelationGraph(m, spanning.tree=0.05, main='Max Span. Tree + Edges > Q05', vertex.label.family='sans')
box()

dev.off()




