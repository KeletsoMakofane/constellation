library(here)
library(tidyverse)

# WHICH SCRIPTS TO RUN?
download_pubmed     <- TRUE
download_funding    <- FALSE
download_citations  <- FALSE

clean_pubmed        <- TRUE
clean_funding       <- FALSE

prep_for_upload     <- FALSE

# CHOOSE FILEPATHS
local <- str_detect(here(), "keletsomakofane/Documents/")

if (local){
  root.working.directory <- "/Users/keletsomakofane/Documents/_gitrepos/constellations/src/data_wrangling/"
  root.data.directory    <- "/Users/keletsomakofane/Documents/_data/constellations/"

} else {
  root.working.directory <- "~/shared_space/thesis_kem073/_gitrepos/constellations/src/data_wrangling/"
  root.data.directory 	 <- "~/shared_space/kem073_proj/_data/constellations/"
}


# EXECUTE SCRIPTS
if (download_pubmed)    source(paste0(root.working.directory, "1_download_pubmed_data.R"), verbose = TRUE)
if (download_funding)   source(paste0(root.working.directory, "1_download_funding_data.R"), verbose = TRUE)
if (download_citations) source(paste0(root.working.directory, "1_download_citation_links_data.R"), verbose = TRUE)

if (clean_pubmed)       source(paste0(root.working.directory, "2_clean_pubmed_data.R"), verbose = TRUE)
if (clean_funding)      source(paste0(root.working.directory, "2_clean_funding_data.R"), verbose = TRUE)

if (prep_for_upload)    source(paste0(root.working.directory, "3_prep_data_for_upload.R"), verbose = TRUE)



