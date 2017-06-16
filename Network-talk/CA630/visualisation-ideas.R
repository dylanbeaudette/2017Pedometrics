library(sf)
library(dplyr)
library(mapview)

# Web map

detach(package:plyr)

# Union based on cluster ID
mu_union <- mu %>%
  sf::st_as_sf() %>% 
  dplyr::mutate(cl = LETTERS[cluster]) %>% 
  dplyr::group_by(cl) %>% 
  summarise(color = unique(color))

# Generation of the web map
mapview(mu_union, zcol = 'cl', col.regions = mu_union$color, legend = TRUE, layer.name = "", maxpoints = npts(mu_union))

# Networks

library(networkD3)

# g <- plotSoilRelationGraph(m, vertex.scaling.factor=1, main='Calaveras/Tuolumne Co. Soil Survey', vertex.label.family='sans', vertex.label.cex=0.65)

k <- igraph_to_networkD3(g, group = V(g)$cluster)

vertex_df <- data.frame(
  name = V(g)$name,
  color = V(g)$color,
  size = V(g)$size
)

k$nodes <- data.frame(k$nodes, vertex_df)
k$links <- data.frame(k$links, weight = E(g)$weight)

colour_scale_data <- k$nodes %>% 
  group_by(group) %>% 
  dplyr::summarise(color = unique(color)) %>% 
  mutate(cl = LETTERS[group], color_simple = stringr::str_sub(color, start = 1, end = 7))

levs <- paste(colour_scale_data$group, collapse = '\", \"')
cols <- paste(colour_scale_data$color_simple, collapse = '\", \"')

colour_scale <- paste0('d3.scaleOrdinal().domain([', paste0('\"', levs, '\"'), ']).range([', paste0('\"', cols, '\"'), ']);')

net_ca <- forceNetwork(
  Links = k$links, Nodes = k$nodes, 
  Source = "source",
  Target = "target",
  NodeID ="name",
  Group = "group",
  opacity = 0.9,
  opacityNoHover = 0.8,
  Nodesize = "size", 
  radiusCalculation = JS("d.nodesize^2 + 8"), 
  colourScale = JS(colour_scale),
  Value = "weight",
  linkWidth = JS("function(d) { return Math.sqrt(d.value); }"), 
  zoom = TRUE,
  legend = TRUE
 )

print(net_ca)

saveNetwork(network = net_ca, file = 'net-california.html')
  
# Fun with the new dev version of ggplot2

ggplot(mu_union) + 
  geom_sf(aes(fill = cl), colour = "grey70", lwd = 0.25) + 
  scale_fill_manual(values = colour_scale_data$color_simple) + 
  theme_bw()

ggplot(mu_union) + 
  geom_sf(data = st_as_sf(mu), aes(fill = NULL), colour = "grey70", lwd = 0.25) +
  geom_sf(aes(fill = cl), colour = "grey70", lwd = 0.25) + 
  scale_fill_manual(values = colour_scale_data$color_simple) + 
  facet_wrap(~cl) +
  theme_bw()

ggplot(mu_union) + 
  geom_sf(data = st_as_sf(mu), aes(fill = NULL), colour = "grey70", lwd = 0.25) +
  geom_sf(aes(fill = cl), lwd = 0) + 
  scale_fill_manual(values = colour_scale_data$color_simple) + 
  facet_wrap(~cl) +
  theme_bw() 

# Fun with ggraph

library(ggraph)

ggraph(g) + 
  geom_edge_link() + 
  geom_node_point(aes(colour = LETTERS[cluster], size = size)) +
  ggraph::theme_graph()

ggraph(g) + 
  geom_edge_link() + 
  geom_node_point(aes(colour = LETTERS[cluster], size = size)) +
  facet_nodes(~cluster) +
  ggraph::theme_graph()

