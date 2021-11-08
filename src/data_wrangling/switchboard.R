library(here)
library(tidyverse)

local <- str_detect(here(), "keletsomakofane/Documents/")

if (local){
  root.working.directory <- "/Users/keletsomakofane/Documents/_gitrepos/constellations/src/data_wrangling/"
  root.data.directory    <- "/Users/keletsomakofane/Documents/_data/constellations/"

} else {
  root.working.directory <- "~/shared_space/thesis_kem073/_gitrepos/constellations/src/data_wrangling/"
  root.data.directory 	 <- "~/shared_space/kem073_proj/_data/"
}

source(paste0(root.working.directory, "download_pubmed.R"), verbose = TRUE)