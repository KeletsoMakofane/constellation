library(here)
library(tidyverse)

local <- str_detect(here(), "keletsomakofane/Documents/")

if (local){
  root.working.directory <- "/Users/keletsomakofane/Documents/_gitrepos/constellations/src/data_wrangling/"
  root.data.directory    <- "/Users/keletsomakofane/Documents/_data/constellations/"
  
} else {
  root.working.directory <- "~/shared_space/thesis_kem073/_gitrepos/constellations/src/data_wrangling/"
  root.data.directory 	 <- "~/shared_space/kem073_proj/_data/constellations/"
}



  
  
  final.data.directory      <- paste0(root.data.directory, "import/")
  
  papers_nodes           <- data.table::fread(paste0(final.data.directory, "paper_nodes.csv"), header = FALSE)[, .(V2 = first(V2), V3 = first(V3), V4 = first(V4), V5 = first(V5), V6 = first(V6), V7 = first(V7), V8 = first(V8), V9 = first(V9), V10 = first(V10), V11 = first(V11)), by=list(V1)]
  papers_nodes_unique    <- unique(papers_nodes)
  data.table::fwrite(papers_nodes_unique, paste0(final.data.directory, "paper_nodes.csv"), col.names = FALSE)
  
  authors_nodes           <- data.table::fread(paste0(final.data.directory, "author_nodes.csv"), header = FALSE)[, .(V2 = first(V2)), by=list(V1)]
  authors_nodes_unique    <- unique(authors_nodes)
  data.table::fwrite(authors_nodes_unique, paste0(final.data.directory, "author)_nodes.csv"), col.names = FALSE)
  
  organizations_nodes           <- data.table::fread(paste0(final.data.directory, "organization_nodes.csv"), header = FALSE)[, .(V2 = first(V2), V3 = first(V3), V4 = first(V4)), by=list(V1)]
  organizations_nodes_unique    <- unique(organizations_nodes)
  data.table::fwrite(organizations_nodes_unique, paste0(final.data.directory, "organization_nodes.csv"), col.names = FALSE)
  
  investigators_nodes           <- data.table::fread(paste0(final.data.directory, "investigator_nodes.csv"), header = FALSE)[, .(V2 = first(V2), V3 = first(V3)), by=list(V1)]
  investigators_nodes_unique    <- unique(investigators_nodes)
  data.table::fwrite(investigators_nodes_unique, paste0(final.data.directory, "investigator_nodes.csv"), col.names = FALSE)
  
  project_nodes           <- data.table::fread(paste0(final.data.directory, "project_nodes.csv"), header = FALSE)[, .(V2 = first(V2), V3 = first(V3), V4 = first(V4), V5 = first(V5), V6 = first(V6), V7 = first(V7), V8 = first(V8)), by=list(V1)]
  project_nodes_unique    <- unique(project_nodes)
  data.table::fwrite(project_nodes_unique, paste0(final.data.directory, "project_nodes.csv"), col.names = FALSE)

  
  
  
  investigator_project_edges           <- data.table::fread(paste0(final.data.directory, "investigator_project_edges.csv"), header = FALSE)[V1 %in% investigators_nodes$V1][V2 %in% project_nodes$V1]
  data.table::fwrite(investigator_project_edges, paste0(final.data.directory, "investigator_project_edges.csv"), col.names = FALSE)
  
  organization_project_edges           <- data.table::fread(paste0(final.data.directory, "organization_project_edges.csv"), header = FALSE)[V1 %in% organizations_nodes$V1][V2 %in% project_nodes$V1]
  data.table::fwrite(organization_project_edges, paste0(final.data.directory, "organization_project_edges.csv"), col.names = FALSE)
  
  project_paper_edges           <- data.table::fread(paste0(final.data.directory, "project_paper_edges.csv"), header = FALSE)[V1 %in% papers_nodes$V1][, .(V2 = first(V2), V3 = first(V3)), by=list(V1)]
  data.table::fwrite(project_paper_edges, paste0(final.data.directory, "project_paper_edges.csv"), col.names = FALSE)
  
  project_subproject_edges           <- data.table::fread(paste0(final.data.directory, "project_subproject_edges.csv"), header = FALSE)[V1 %in% project_nodes$V1][V2 %in% project_nodes$V1]
  data.table::fwrite(project_subproject_edges, paste0(final.data.directory, "project_subproject_edges.csv"), col.names = FALSE)
  
  author_paper_edges           <- data.table::fread(paste0(final.data.directory, "author_paper_edges.csv"), header = FALSE)[V1 %in% papers_nodes$V1][V2 %in% authors_nodes$V1]
  data.table::fwrite(author_paper_edges, paste0(final.data.directory, "author_paper_edges.csv"), col.names = FALSE)
  
  citation_edges           <- data.table::fread(paste0(final.data.directory, "citation_edges.csv"), header = FALSE)[V1 %in% papers_nodes$V1][V2 %in% papers_nodes$V1]
  data.table::fwrite(citation_edges, paste0(final.data.directory, "citation_edges.csv"), col.names = FALSE)
  
  

  