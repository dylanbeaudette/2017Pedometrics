#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Visualising co-occurence data in soil surveys"),
   
   fluidRow(
     
     tabsetPanel(
       
       #
       # California
       # 
       
       tabPanel(
        title = "California",
         # Map on the left
         # 
         column(
           width = 6,
           h4("Map of the soil series communities"),
           mapviewOutput('map', width = "100%", height = "600px")
         ),
         # Network on the right
         # 
         column(
           width = 6, 
           h4("Coresponding network"),
           networkD3::forceNetworkOutput('net', width = '100%', height = "600px")
         )
       ),
       
       #
       # New Zealand
       # 
       
       tabPanel(
         title = "New Zealand",
         # Map on the left
         # 
         column(
           width = 6,
           h4("Map of the soil series communities")#,
           # mapviewOutput('map')
         ),
         # Network on the right
         # 
         column(
           width = 6, 
           h4("Coresponding network")#,
           # networkD3::forceNetworkOutput('net')
         )
       )
     )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
  print(getwd())
  
  # Load data
  k <- readRDS('net-d3.rda')
  mu_union <- readRDS('mu-union.rda')
  
  # Map
  output$map <- renderMapview({
    mapview(
      mu_union, 
      zcol = 'cl', 
      col.regions = mu_union$color
    )
  })
  
  # Network
  colour_scale_data <- k$nodes %>% 
    group_by(group) %>% 
    summarise(color = unique(color)) %>% 
    mutate(cl = LETTERS[group], color_simple = stringr::str_sub(color, start = 1, end = 7))
  
  levs <- paste(colour_scale_data$group, collapse = '\", \"')
  cols <- paste(colour_scale_data$color_simple, collapse = '\", \"')
  
  colour_scale <- paste0('d3.scaleOrdinal().domain([', paste0('\"', levs, '\"'), ']).range([', paste0('\"', cols, '\"'), ']);')
  
  output$net <- renderForceNetwork({
    forceNetwork(
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
  })
    
}

# Run the application 
shinyApp(ui = ui, server = server)

