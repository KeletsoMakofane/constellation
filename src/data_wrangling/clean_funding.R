clean.data.directory      <- paste0(root.data.directory, "data_funding_clean/")
final.data.directory      <- paste0(root.data.directory, "import/")
filenames                 <- list.files(clean.data.directory)

filenames_investigator_nodes <- filenames %>%
  {.[str_detect(., "investigator_nodes_")]} %>%
  paste0(clean.data.directory, .)

filenames_investigator_project_edges <- filenames %>%
  {.[str_detect(., "investigator_project_edges_")]} %>%
  paste0(clean.data.directory, .)

filenames_organization_nodes <- filenames %>%
  {.[str_detect(., "organization_nodes_")]} %>%
  paste0(clean.data.directory, .)

filenames_organization_project_edges <- filenames %>%
  {.[str_detect(., "organization_project_edges_")]} %>%
  paste0(clean.data.directory, .)

filenames_project_nodes <- filenames %>%
  {.[str_detect(., "project_nodes_")]} %>%
  paste0(clean.data.directory, .)

filenames_project_paper_edges <- filenames %>%
  {.[str_detect(., "project_paper_edges_")]} %>%
  paste0(clean.data.directory, .)

filenames_project_subproject_edges <- filenames %>%
  {.[str_detect(., "project_subproject_edges_")]} %>%
  paste0(clean.data.directory, .)




if (file.exists(paste0(final.data.directory, "investigator_nodes.csv"))) unlink(paste0(final.data.directory, "investigator_nodes.csv"), recursive = FALSE)

for (i in seq_along(filenames_investigator_nodes)){
  try({
    read.csv(filenames_investigator_nodes[i], header = TRUE) %>%
      write.table(paste0(final.data.directory, "investigator_nodes.csv"), sep = ",", append = TRUE, col.names=!file.exists(paste0(final.data.directory, "investigator_nodes.csv")), row.names = FALSE)
    
    print(paste(i, "of", length(filenames_investigator_nodes), "investigator_nodes"))
  })
}


if (file.exists(paste0(final.data.directory, "investigator_project_edges.csv"))) unlink(paste0(final.data.directory, "investigator_project_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_investigator_project_edges)){
  try({
    read.csv(filenames_investigator_project_edges[i], header = TRUE) %>%
      write.table(paste0(final.data.directory, "investigator_project_edges.csv"), sep = ",", append = TRUE, col.names=!file.exists(paste0(final.data.directory, "investigator_project_edges.csv")), row.names = FALSE)
    
    print(paste(i, "of", length(filenames_investigator_project_edges), "investigator_project_edges"))
  })
}

if (file.exists(paste0(final.data.directory, "organization_nodes.csv"))) unlink(paste0(final.data.directory, "organization_nodes.csv"), recursive = FALSE)

for (i in seq_along(filenames_organization_nodes)){
  try({
    read.csv(filenames_organization_nodes[i], header = TRUE) %>%
      write.table(paste0(final.data.directory, "organization_nodes.csv"), sep = ",", append = TRUE, col.names=!file.exists(paste0(final.data.directory, "organization_nodes.csv")), row.names = FALSE)
    
    print(paste(i, "of", length(filenames_organization_nodes), "organization_nodes"))
  })
}

if (file.exists(paste0(final.data.directory, "organization_project_edges.csv"))) unlink(paste0(final.data.directory, "organization_project_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_organization_project_edges)){
  try({
    read.csv(filenames_organization_project_edges[i], header = TRUE) %>%
      write.table(paste0(final.data.directory, "organization_project_edges.csv"), sep = ",", append = TRUE, col.names=!file.exists(paste0(final.data.directory, "organization_project_edges.csv")), row.names = FALSE)
    
    print(paste(i, "of", length(filenames_organization_project_edges), "organization_project_edges"))
  })
}


if (file.exists(paste0(final.data.directory, "project_nodes.csv"))) unlink(paste0(final.data.directory, "project_nodes.csv"), recursive = FALSE)

for (i in seq_along(filenames_project_nodes)){
  try({
    read.csv(filenames_project_nodes[i], header = TRUE) %>%
      write.table(paste0(final.data.directory, "project_nodes.csv"), sep = ",", append = TRUE, col.names=!file.exists(paste0(final.data.directory, "project_nodes.csv")), row.names = FALSE)
    
    print(paste(i, "of", length(filenames_project_nodes), "project_nodes"))
  })
}


if (file.exists(paste0(final.data.directory, "project_paper_edges.csv"))) unlink(paste0(final.data.directory, "project_paper_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_project_paper_edges)){
  try({
    read.csv(filenames_project_paper_edges[i], header = TRUE) %>%
      write.table(paste0(final.data.directory, "project_paper_edges.csv"), sep = ",", append = TRUE, col.names=!file.exists(paste0(final.data.directory, "project_paper_edges.csv")), row.names = FALSE)
    
    print(paste(i, "of", length(filenames_project_paper_edges), "project_paper_edges"))
  })
}



if (file.exists(paste0(final.data.directory, "project_subproject_edges.csv"))) unlink(paste0(final.data.directory, "project_subproject_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_project_subproject_edges)){
  try({
    read.csv(filenames_project_subproject_edges[i], header = TRUE) %>%
      write.table(paste0(final.data.directory, "project_subproject_edges.csv"), sep = ",", append = TRUE, col.names=!file.exists(paste0(final.data.directory, "project_subproject_edges.csv")), row.names = FALSE)
    
    print(paste(i, "of", length(filenames_project_subproject_edges), "project_subproject_edges"))
  })
}





















