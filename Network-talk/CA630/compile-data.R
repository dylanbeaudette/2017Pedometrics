## 2017 Pedometrics talk on Soilscapes / Networks
## P. Roudier and D.E. Beaudette


library(soilDB)
library(plyr)
library(rgdal)
library(sp)


# get NASIS data and consolidate
# http://ncss-tech.github.io/AQP/soilDB/NASIS-component-data.html

# get component data from NASIS
nc <- get_component_data_from_NASIS_db()

# get correlation table
nc.correlation <- get_component_correlation_data_from_NASIS_db()

# filter DMU / component records: only Provisional / Approved map units
# filering condition nc$dmuiid must be present in nc.correlation$dmuiid
idx <- which(nc$dmuiid %in% unique(nc.correlation$dmuiid))
nc <- nc[idx, ]

# subset columns in DMU/component records
nc <- nc[, c('coiid', 'dmuiid', 'dmudesc', 'compname', 'comppct_r', 'compkind', 'majcompflag', 'taxorder', 'taxsuborder', 'taxgrtgroup', 'taxsubgrp')]

# trim correlation table columns
nc.correlation <- nc.correlation[, c('muiid', 'dmuiid', 'musym', 'mukind', 'mustatus')]

# join DMU/components + correlation tables: need connection to MUSYM
x <- join(nc, nc.correlation, by='dmuiid', type='left')

# normalize component names
x$compname <- tolower(x$compname)

# remove misc. areas components
x <- subset(x, compkind != 'miscellaneous area')

# keep only major components? 
# NO: too limiting
# x <- subset(x, majcompflag == '1')

# remove some higher-order taxa components or other strange stuff
# ... sweeping cruft under the rug for now ... how did some of these get in here!?
x <- subset(x, ! compname %in% c('riparian', 'urban land', 'young gravels', 'alfic xerarents', 'orthents', 'lithic haploxeralfs', 'aquic haploxeralfs', 'ultic haploxeralfs'))

# check: OK
head(x)



## get / filter spatial data

# CRAP! my version or R is too old...
# why not try new sf library / class
# mu <- st_read()

# falling-back to the tried and tested sp-based methods
mu <- readOGR(dsn='L:/NRCS/MLRAShared/CA630/FG_CA630_OFFICIAL.gdb', layer='ca630_a', stringsAsFactors=FALSE)
# re-name map unit symbol column for ease of joining
names(mu)[1] <- 'musym'


# save for later
save(x, file='cached-nasis.rda')
save(mu, file='cached-mu.rda')

