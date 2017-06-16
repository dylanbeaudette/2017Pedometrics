library(sharpshootR)
library(plyr)
library(reshape2)
library(vegan)

# load sample data associated with the amador soil series
data(amador)


d <- amador

## this is messy way to demonstrate anything.. but allows for some inspection of what is happening...
## perhaps a debugging output would help?

# arguments to component.adj.matrix()
mu='mukey'
co='compname'
wt='comppct_r'
method='community.matrix'
standardization='max'
metric='jaccard'
rm.orphans=TRUE
similarity=TRUE


## hack: move wt column into '.wt'
d$.wt <- d[[wt]]

# aggregate component percentages when multiple components of the same name are present
## note that we are using weights as moved into the new column '.wt'
d <- ddply(d, c(mu, co), summarise, weight=sum(.wt))
# re-order
d <- d[order(d[[mu]], d[[co]]), ]

# extract a list of component names that occur together
l <- dlply(d, mu, function(i) unique(i[[co]]))

# optionally keep map units with only a single component
if(rm.orphans) {
  # include only those components that occur with other components
  mu.multiple.components <- names(which(sapply(l, function(i) length(i) > 1)))
  
  # subset, keeping only those map units with > 1 component
  d <- d[which(d[[mu]] %in% mu.multiple.components), ]
}


# reshape to component x mukey community matrix
fm <- as.formula(paste(co, ' ~ ', mu, sep=''))
d.wide <- dcast(d, fm, value.var='weight', fill=0)

# convert into community matrix by moving first column -> row.names
d.mat <- as.matrix(d.wide[, -1])
dimnames(d.mat)[[1]] <- d.wide[[co]]


# second major step: expanded matrix of components-as-rows, map units-as-columns
# e.g. "community matrix"
(d.mat)


# standardization of community matrix
if(standardization != 'none')
  (d.mat <- decostand(d.mat, method=standardization))

# distance matrix
(m <- vegdist(d.mat, method=metric))

# convert to similarity matrix: S = max(D) - D [Kaufman & Rousseeuw]
if(similarity == TRUE) {
  m <- as.matrix(max(m) - m)
  mat.type <- 'similarity'
  
  # set diagonal and lower triangle to 0
  m[lower.tri(m)] <- 0
  diag(m) <- 0
  
  # set attributes related to this method
  attr(m, 'standardization') <- standardization
  attr(m, 'metric') <- metric
}

# similarity matrix == adjacency matrix
m


