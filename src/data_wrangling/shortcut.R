library(here)
library(tidyverse)



  root.working.directory <- "~/shared_space/thesis_kem073/_gitrepos/constellations/src/data_wrangling/"
  root.data.directory 	 <- "~/shared_space/kem073_proj/_data/constellations/"

  
  
  final.data.directory      <- paste0(root.data.directory, "import/")
  
  papers_nodes           <- data.table::fread(paste0(final.data.directory, "papers.csv"))
  papers_nodes_unique    <- unique(papers_nodes)
  data.table::fwrite(papers_nodes_unique, paste0(final.data.directory, "papers.csv"), col.names = FALSE)
  
  authors_nodes           <- data.table::fread(paste0(final.data.directory, "authors.csv"))
  authors_nodes_unique    <- unique(authors_nodes)
  data.table::fwrite(authors_nodes_unique, paste0(final.data.directory, "authors.csv"), col.names = FALSE)
  
  organizations_nodes           <- data.table::fread(paste0(final.data.directory, "organization_nodes.csv"))
  organizations_nodes_unique    <- unique(organizations_nodes)
  data.table::fwrite(organizations_nodes_unique, paste0(final.data.directory, "organization_nodes.csv"), col.names = FALSE)
  
  investigators_nodes           <- data.table::fread(paste0(final.data.directory, "investigator_nodes.csv"))
  investigators_nodes_unique    <- unique(investigators_nodes)
  data.table::fwrite(investigators_nodes_unique, paste0(final.data.directory, "investigator_nodes.csv"), col.names = FALSE)
  
  project_nodes           <- data.table::fread(paste0(final.data.directory, "project_nodes.csv"))
  project_nodes_unique    <- unique(project_nodes)
  data.table::fwrite(project_nodes_unique, paste0(final.data.directory, "project_nodes.csv"), col.names = FALSE)