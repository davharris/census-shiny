library(shiny)
library(tidyverse)
library(choroplethrMaps)
library(choroplethr)
data(county.regions)
library(viridis)

CB = readRDS("CB.rds")

states = county.regions$state.name[!(county.regions$state.name) %in% c("hawaii", "alaska")]


shinyServer(function(input, output) {

  output$map <- renderPlot({
    CB %>% 
      complete(region, YEAR, NAICS2012_TTL, fill = list(EMP = 0)) %>% 
      filter(NAICS2012_TTL == input$sector) %>% 
      filter(YEAR == input$year) %>% 
      mutate(value = as.numeric(EMP)) %>% 
      county_choropleth(title = paste0(input$sector, " (", input$year, ")"),
                        state_zoom = states, num_colors = 1) + 
      scale_fill_viridis(trans = "log10", option = "B", 
                         guide = guide_colorbar(title = "Employment"))
  })

  output
})
