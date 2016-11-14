library(shiny)
library(tidyverse)
library(choroplethrMaps)
library(choroplethr)
data(county.regions)
library(viridis)

CB = readRDS("CB.rds")
  
sectors = na.omit(unique(CB$NAICS2012_TTL))

states = county.regions$state.name[!(county.regions$state.name) %in% c("hawaii", "alaska")]


shinyUI(fluidPage(

  # Application title
  titlePanel("US County Business Patterns"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      selectInput("sector",
                  "Number of bins:",
                  choices = sectors),
      selectInput("year",
                  "year:",
                  choices = 2012:2014)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("map")
    )
  )
))
