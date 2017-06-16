# 2017 Pierre / Dylan Pedometrics Presentations

This is what we are trying to avoid:

![](https://imgs.xkcd.com/comics/state_word_map.png)


http://www.pedometrics2017.org/


## Mapping soilscapes using soil co-occurence networks

P. Roudier, D.E. Beaudette, D.R.J. O'Neale

Soils are arguably the most complex material on Earth, and present an important spatial variability. Across the landscape, different soils types will often be spatially intermingled. This is reflected by soil mapping units (SMU) being often composed of more than one soil taxa. The notion of soilscape reflects the fact that a landscape can be delineated into different such spatial units “including a limited number of soil classes that are geographically distributed according to an identifiable pattern” (Lagacherie et al., 2001).

The research field of network science offers new mathematical tools to visualize and analyze existing soil survey data, and explore its complex relational interactions. In this paper, we extract and visualize pedological information by analyzing the co-occurrence of soil taxa using a network approach. 

For any level of a given hierarchical soil classification system, the co-occurence of soil taxa within and between neighbouring SMUs can be described as a network graph. The structural properties of the resulting graphs can be analyzed, and tools such as community structure detection are used to classify their different nodes. Soilscapes are then delineated by mapping the identified communities back in geographical space. This approach also gives a method for quantifying the pedological complexity of different regions based on their constituent soil types, using metrics such as graph connectivity. Different levels of granularity for both the regional data and the soil classification data allow for views at different scales.

Network science offers the opportunity of new insights from looking at existing data in a new way. Soil survey data from S-Map (NZ) and USDA-NRCS (USA) are used to illustrate the value and originality of these new approaches.


### Notes

  1. different ways in which you can create the adjacency matrix, and
their relationship to "reality"

  2. interpretation of min vs. max spanning trees: correlation to reality

  3. conditional pruning of edges based on quantiles of edge weight

  4. max.spanning tree + edges with weight >= specified quantile. Some of these ideas are explored here: http://ncss-tech.github.io/AQP/sharpshootR/component-relation-graph.html

  5. networks / graphs as "efficient" representation of the "most important" pair-wise distances computed from soil profile data, see attached PNG and R files

  6. spatial adjacency networks, or some kind of hybrid between spatial + tabular adjacency information. This is a tough one, as the weight calculation is non-trivial and (of course) method-dependent. some ideas (not many!) here: http://ncss-tech.github.io/AQP/sharpshootR/common-soil-lines.html

  7. integration of "real" geomorphological observations into the process

  8. use of adj. matrix / graph to show transition probability sequence for soil color or horizon designation

  9. use of adj. matrix / graph to show correlation decisions for horizon designations or soil series


### More notes

Just read through the Phillips (2013) paper. I noticed a couple of things:

  * indicator vs. weighted adj. matrix development based on "touching" polygons

  * relatively tiny study areas with a small "chunk" of all possible occurrence of the named soils


... Thinking about ways in which we can answer questions such as "how
is this any different than Phillips (2013, 2016) ...


So far, we have developed a robust (I think..!) method of generating
weighted adjacency matrices using occurrence probability (component
percentage) within map units and a distance-via-community-matrix
analogue. A slide describing the theory and rationale would be wise. I
can do this, but the details are in:

`sharpshootR::component.adj.matrix(method == 'community.matrix')`

The basic idea is that:

  1. Arrange occurrence frequency (component percent) with components as rows, map units as columns. This is similar to the "community matrix from the ecology world: rows are sites and columns are species, cells are percent cover. In this case rows are soil series concepts and columns are "observations" (various map units), and cells are occurrence probability.

  2. compute distance matrix (pair-wise distances by row) for series concepts using a distance metric designed for community matrix analysis

  3. convert distance matrix into similarity matrix, the similarity
  matrix _is now the adjacency matrix_.

*restated*
mapunit / component records --> reshape into "community matrix" --> standardize and compute distance matrix (methods from numerical ecology) --> convert distance matrix into similarity matrix,  this is the adjacency matrix

check out the demo file in R for details and examples

  * the community matrix: rows are the soil series / components / siblings, and columns represent observational units or evidence
  * the cells in the matrix are proportions / probabilities, and analogous to the "percent cover" in a community matrix

Why go through all this trouble? Because co-occurrence probability
(weight) matters! Both in terms of co-occurrence weight within a map
units and weights associated with spatial connectivity (length of
shared perimeter, area, etc.).


### More notes

Integration of geomorphic signature would be nice way to link the "empirical" (graph-based) vs. "theoretical" (block diagrams / soil system diagrams) soilscapes.

Initialization of the network is important: by hypothetical region, collection of named soils, taxonomic information, climate, ...

Integration of spatial connectivity (first neighbor) would help span "gaps" (missing linkages that would otherwise be added by an expert) or harmonize data at survey area boundaries (e.g. incompatible map units due to survey vintage). For example, here is the max spanning tree of "1st-neighbor, unweighted adjacency" associated with the map units of CA630:

![](static_figures/ca630-spatial-first-neighbor-max-spanning-tree.png)

For future work: compare the map representation of these "communities / clusters" to the map representation of the tabular-data based adjacency data.

### In the CA630 example:

  1. the identified communities / clusters are largely a product of consistent and (I would argue) carefully constructed soil-landscape models

  2. therefore, the resulting map of communities is a fairly reasonable "general soils map" for the area

  3. the results are obvious to me, as I had a hand in crafting many of these map units--but not obvious to someone who hasn't worked in the area

  4. the graph / communities + a reasonable amount of "reading" should be enough to re-construct the major groupings of soils / landforms / lithology / climate (soil-forming factors / mental models / etc.) originally developed by the soil survey team, but usually not well preserved

  5. nodes (soil series / components) that link communities are usually common soils that occur in multiple suites of map units. this special place in the graph is probably worth investigating


## Algorithms for Quantitative Pedology

D.E. Beaudette and P. Roudier

The Algorithms for Quantitative Pedology (AQP) project was started in 2009 to organize a loosely-related set of concepts and source code on the topic of soil profile visualization, aggregation, and classification into an R package. Over the past 8 years, the project has grown into a suite of related R packages that enhance and simplify the quantitative analysis of soil profile data. Central to the AQP project is a new vocabulary of specialized functions and data structures that can accommodate the inherent complexity of soil profile information; freeing the scientist to focus on ideas rather than boilerplate data processing tasks. These functions and data structures have been extensively tested and documented, applied to projects involving hundreds of thousands of soil profiles, and deeply integrated into widely used tools such as SoilWeb. Components of the AQP project currently serve an important role in routine data analysis within the USDA-NRCS Soil Science Division. The AQP suite of R packages offer a convenient platform for bridging the gap between pedometric theory and practice.

http://ncss-tech.github.io/AQP/



### Notes

Thinking over some updates since 2011 / 2015:

* better conversion sRGB -> Munsell (shortest distance calc. in
CIELAB) in recent commit to GH

* color signature development via soilColorSignature()

* transition probabilities, genetic hz labels or soil color

* national and state-level maps of soil color via munsel2rgb() -- see attached

.. why am I listing this stuff here? The NEWS file has some relevant entries:

https://github.com/ncss-tech/aqp/blob/master/NEWS

Here are some of my favorites:

* `textureTriangleSummary()`
* `getClosestMunsellChip()`
* `hzTransitionProbabilities()`
* `groupedProfilePlot()`
* `aggregateColor()`

... but I am sure there are others. I'll look over the AQP poster from
last time and see what we can cram into the new version.

Also, should probably reply to Jose about kicking-off the new webpage
for Pedometrics.



