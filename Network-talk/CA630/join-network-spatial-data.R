## 2017 Pedometrics talk on Soilscapes / Networks
## P. Roudier and D.E. Beaudette


library(igraph)
library(RColorBrewer)
library(sharpshootR)
library(plyr)

library(rgdal)
library(sp)
library(raster)
library(rasterVis)


# load relevant data
load('cached-nasis.rda')
load('cached-mu.rda')
load('cached-graph.rda')


## associate nodes with map units, two options:
## simple majority:
## membership by component percent:

# simple method: reduce musym--compname to 1:1 via majority rule
# assumption: there are never >1 components with the same name
# caveat: some map unit symbols will have NO association with graph, based on previous subsetting rules: NULL delineations on map
mu.agg.majority <- function(i) {
  # keep the largest component
  idx <- order(i$comppct_r, decreasing = TRUE)
  res <- i[idx, ][1, , drop=FALSE]
  return(res)
}


# create mu -> graph lookup table
mu.LUT <- ddply(x, 'musym', mu.agg.majority)


# compnames in graph but not mu.LUT
setdiff(V(g)$name, unique(mu.LUT$compname))

# in mu.LUT but not in graph
setdiff(unique(mu.LUT$compname), V(g)$name)

# join musym -- graph via component name
d <- join(mu.LUT, d, by='compname')

# join() / merge() do strange things in the presence of NA...
d.no.na <- d[which(!is.na(d$musym)), ]

# samity-check: musym in map missing from graph--musym association
# none missing: good
setdiff(unique(x$musym), d.no.na$musym)

# sanity check: there should be a 1:1 relationship between
# OK
all(rowSums(as.matrix(table(d$musym, d$cluster))) < 2)


## note: there are a couple clusters without corresponding polygons!
# this breaks in the presence of NA...
mu <- merge(mu, d.no.na, by.x='musym', by.y='musym')

# filter-out polygons with no assigned cluster
mu <- mu[which(!is.na(mu$cluster)), ]


# viz using raster methods
r <- rasterize(mu, raster(extent(mu), resolution=90), field='cluster')

## kludge for plotting categories
# convert to categorical raster
r <- as.factor(r)
rat <- levels(r)[[1]]

# use previously computed legend of unique cluster IDs and colors
# note that the raster legend is missing 3 clusters
rat$color <- leg$color[match(rat$ID, leg$cluster)]

## TODO: add in a reasonable "name" for each cluster
rat$name <- rat$ID


# pack RAT back into raster
levels(r) <- rat

# simple plot in R, colors hard to see
levelplot(r, col.regions=levels(r)[[1]]$color, xlab="", ylab="", att='name', maxpixels=1e5)

# save to external formats for map / figure making
writeOGR(mu, dsn='.', layer='graph-and-mu-polygons', driver='ESRI Shapefile', overwrite_layer = TRUE)
writeRaster(r, file='mu-polygons-graph-clusters.tif', datatype='INT1U', format='GTiff', options=c("COMPRESS=LZW"), overwrite=TRUE)



