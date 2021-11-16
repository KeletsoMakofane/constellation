library(here)
library(tidyverse)

# WHICH SCRIPTS
download_pubmed     <- FALSE
clean_pubmed        <- TRUE

download_funding    <- FALSE
clean_funding       <- TRUE

download_citations  <- FALSE



local <- str_detect(here(), "keletsomakofane/Documents/")

if (local){
  root.working.directory <- "/Users/keletsomakofane/Documents/_gitrepos/constellations/src/data_wrangling/"
  root.data.directory    <- "/Users/keletsomakofane/Documents/_data/constellations/"

} else {
  root.working.directory <- "~/shared_space/thesis_kem073/_gitrepos/constellations/src/data_wrangling/"
  root.data.directory 	 <- "~/shared_space/kem073_proj/_data/constellations/"
}

if (download_pubmed) source(paste0(root.working.directory, "download_pubmed.R"), verbose = TRUE)
if (download_funding) source(paste0(root.working.directory, "download_funding.R"), verbose = TRUE)
if (download_citations) source(paste0(root.working.directory, "download_citation_links.R"), verbose = TRUE)

if (clean_pubmed) source(paste0(root.working.directory, "clean_pubmed.R"), verbose = TRUE)
if (clean_funding) source(paste0(root.working.directory, "clean_funding.R"), verbose = TRUE)

