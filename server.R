library(shiny)
library(tidyverse)
library(choroplethrMaps)
library(choroplethr)
data(county.regions)
library(viridis)
library(cowplot)

data(county.regions)
data(df_pop_county)


CB = readRDS("CB.rds")

states = county.regions$state.name[!(county.regions$state.name) %in% c("hawaii", "alaska")]


shinyServer(
  function(input, output) {
    output$plot <- renderPlot(
      if (input$map) {
        CB %>%
          complete(region, YEAR, NAICS2012_TTL, fill = list(EMP = 0)) %>%
          filter(NAICS2012_TTL == input$sector) %>%
          filter(YEAR == input$year) %>%
          mutate(value = as.numeric(EMP)) %>%
          county_choropleth(title = paste0(input$sector, " (", input$year, ")"),
                            state_zoom = states, num_colors = 1) +
          scale_fill_viridis(trans = "log10", option = "B",
                             guide = guide_colorbar(title = "Employment")) +
          theme(
            axis.line =    element_blank(),
            axis.line.x =  element_blank(),
            axis.line.y =  element_blank(),
            panel.border = element_rect())
      } else {
        CB %>%
          complete(region, YEAR, NAICS2012_TTL, fill = list(EMP = 0)) %>%
          filter(NAICS2012_TTL == input$sector) %>%
          filter(YEAR == input$year) %>% 
          inner_join(df_pop_county) %>% 
          ggplot(aes(x = value, y = EMP)) +
          geom_point() +
          xlab("Population") +
          ylab("Employment") +
          ggtitle(paste0(input$sector, " (", input$year, ")"))
      }
    )
    output$text = renderText(
      if (input$map) {
        tidied_sector = ifelse(input$sector == "Total for all sectors", 
                               "all economic sectors", 
                               paste0("\"", input$sector, "\""))
        paste0("This map shows the number of people employed in each county in ", 
               tidied_sector,
               ", according to the US Census Bureau's County Business Patterns ",
               "data for ", input$year, ".")
      } else{
        tidied_sector = ifelse(input$sector == "Total for all sectors", 
                               "all economic sectors", 
                               paste0("\"", input$sector, "\""))
        
        correlation = CB %>%
          complete(region, YEAR, NAICS2012_TTL, fill = list(EMP = 0)) %>%
          filter(NAICS2012_TTL == input$sector) %>%
          filter(YEAR == input$year) %>% 
          inner_join(df_pop_county) %>% 
          select(EMP, value) %>% 
          cor()
        strengthly = cut(abs(correlation[1,2]), 
                         breaks = c(0, .15, .3, .7, .9, 1),
                         labels = c("very weakly", "weakly", "moderately", 
                                    "strongly", "very strongly"))
        paste0(
          "Executive summary: Employment in ",
          tidied_sector,
          " was ",
          strengthly,
          " correlated with population at the county level ",
          "in ",
          input$year,
          " (r=",
          format(correlation[1,2], digits = 2),
          ")."
        )
      }
    )
  }
)
