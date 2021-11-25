library(here)
library(tidyverse)

# WHICH SCRIPTS TO RUN?
download_pubmed     <- FALSE
download_funding    <- FALSE
download_citations  <- FALSE
download_data_indexes  <- FALSE

clean_pubmed        <- FALSE
clean_funding       <- FALSE
clean_citation      <- FALSE

prep_for_upload     <- FALSE
upload_to_aws       <- TRUE
import_to_aws       <- FALSE

# CHOOSE FILEPATHS
local <- str_detect(here(), "keletsomakofane/Documents/")

if (local){
  root.working.directory  <- "/Users/keletsomakofane/Documents/_gitrepos/constellations/src/data_wrangling/"
  root.data.directory     <- "/Users/keletsomakofane/Documents/_data/constellations/"
  root.security.directory <- "/Users/keletsomakofane/Documents/_security/"

} else {
  root.working.directory  <- "~/shared_space/thesis_kem073/_gitrepos/constellations/src/data_wrangling/"
  root.data.directory 	  <- "~/shared_space/kem073_proj/_data/constellations/"
  root.security.directory <- "~/shared_space/thesis_kem073/_security/"
}


# EXECUTE SCRIPTS
if (download_pubmed)    source(paste0(root.working.directory, "1_download_pubmed_data.R"), verbose = TRUE)
if (download_funding)   source(paste0(root.working.directory, "1_download_funding_data.R"), verbose = TRUE)
if (download_citations) source(paste0(root.working.directory, "1_download_citation_links_data.R"), verbose = TRUE)
if (download_data_indexes) source(paste0(root.working.directory, "1_data_indexing.R"), verbose = TRUE)

if (clean_pubmed)       source(paste0(root.working.directory, "2_clean_pubmed_data.R"), verbose = TRUE)
if (clean_funding)      source(paste0(root.working.directory, "2_clean_funding_data.R"), verbose = TRUE)
if (clean_citation)     source(paste0(root.working.directory, "2_clean_citation_links_data.R"), verbose = TRUE)

if (prep_for_upload)    source(paste0(root.working.directory, "3_prep_data_for_upload.R"), verbose = TRUE)
if (upload_to_aws)      source(paste0(root.working.directory, "4_upload_data_to_aws.R"), verbose = TRUE)
if (import_to_aws)      source(paste0(root.working.directory, "5_bulk_data_import_neo4j.R"), verbose = TRUE)


