library(shiny)
library(tidyverse)
library(readr)
library(choroplethrMaps)
library(choroplethr)
data(county.regions)
library(viridis)


col_types = cols(
  .default = col_character(),
  YEAR = col_integer(),
  ESTAB = col_integer(),
  EMP = col_integer(),
  EMP_N = col_integer(),
  PAYQTR1 = col_integer(),
  PAYQTR1_N = col_integer(),
  PAYANN = col_double(),
  PAYANN_N = col_integer()
)

years = formatC(12:14, width = 2, flag = "0")
for (year in years) {
  stem = paste0("CB", year, "00A11")
  if (!file.exists(paste0(stem, ".dat"))) {
    download.file(paste0("http://www2.census.gov/econ20", year, "/CB/sector00/", 
                         stem, ".zip"), "CB1400A11.zip")
    unzip("CB1400A11.zip")
  }
}

raw_CB_data = dir(pattern = ".dat") %>% 
  map(read_delim, delim = "|", col_types = col_types) %>% 
  bind_rows()


CB = raw_CB_data %>% 
  filter(nchar(as.character(NAICS2012)) == 2) %>% 
  filter(GEOTYPE == "03") %>% 
  distinct(GEO_ID, NAICS2012, YEAR, .keep_all = TRUE) %>% 
  mutate(county.fips.character = paste0(ST, COUNTY)) %>% 
  right_join(county.regions, by = "county.fips.character")

saveRDS(CB, file = "CB.rds")
