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
    a <- read_csv(filenames_investigator_nodes[i]) %>%
      dplyr::mutate(across(everything(), as.character)) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, '"', '|'))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "'", "|"))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, ",", ";"))) %>%
      dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x)))
      
    write_csv(a, paste0(final.data.directory, "investigator_nodes.csv"), append = TRUE, col_names=!file.exists(paste0(final.data.directory, "investigator_nodes.csv")))
    
    print(paste(i, "of", length(filenames_investigator_nodes), "investigator_nodes"))
  })
}


if (file.exists(paste0(final.data.directory, "investigator_project_edges.csv"))) unlink(paste0(final.data.directory, "investigator_project_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_investigator_project_edges)){
  try({
    a <- read_csv(filenames_investigator_project_edges[i]) %>%
      dplyr::mutate(across(everything(), as.character)) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, '"', '|'))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "'", "|"))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, ",", ";"))) %>%
      dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x)))
      
    write_csv(a, paste0(final.data.directory, "investigator_project_edges.csv"), append = TRUE, col_names=!file.exists(paste0(final.data.directory, "investigator_project_edges.csv")))
    
    print(paste(i, "of", length(filenames_investigator_project_edges), "investigator_project_edges"))
  })
}

if (file.exists(paste0(final.data.directory, "organization_nodes.csv"))) unlink(paste0(final.data.directory, "organization_nodes.csv"), recursive = FALSE)

for (i in seq_along(filenames_organization_nodes)){
  try({
    a <- read_csv(filenames_organization_nodes[i]) %>%
      dplyr::mutate(across(everything(), as.character)) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, '"', '|'))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "'", "|"))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, ",", ";"))) %>%
      dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x)))
    
    write_csv(a, paste0(final.data.directory, "organization_nodes.csv"),  append = TRUE, col_names=!file.exists(paste0(final.data.directory, "organization_nodes.csv")))
    
    print(paste(i, "of", length(filenames_organization_nodes), "organization_nodes"))
  })
}

if (file.exists(paste0(final.data.directory, "organization_project_edges.csv"))) unlink(paste0(final.data.directory, "organization_project_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_organization_project_edges)){
  try({
    a <- read_csv(filenames_organization_project_edges[i]) %>%
      dplyr::mutate(across(everything(), as.character)) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, '"', '|'))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "'", "|"))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, ",", ";"))) %>%
      dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x)))
    
      write_csv(a, paste0(final.data.directory, "organization_project_edges.csv"),  append = TRUE, col_names=!file.exists(paste0(final.data.directory, "organization_project_edges.csv")))
    
    print(paste(i, "of", length(filenames_organization_project_edges), "organization_project_edges"))
  })
}


if (file.exists(paste0(final.data.directory, "project_nodes.csv"))) unlink(paste0(final.data.directory, "project_nodes.csv"), recursive = FALSE)

for (i in seq_along(filenames_project_nodes)){
  try({
    a <- read_csv(filenames_project_nodes[i]) %>%
      dplyr::mutate(across(everything(), as.character)) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, '"', '|'))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "'", "|"))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, ",", ";"))) %>%
      dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x)))
      
      write_csv(a, paste0(final.data.directory, "project_nodes.csv"),  append = TRUE, col_names=!file.exists(paste0(final.data.directory, "project_nodes.csv")))
    
    print(paste(i, "of", length(filenames_project_nodes), "project_nodes"))
  })
}


if (file.exists(paste0(final.data.directory, "project_paper_edges.csv"))) unlink(paste0(final.data.directory, "project_paper_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_project_paper_edges)){
  try({
    a <- read_csv(filenames_project_paper_edges[i]) %>%
      dplyr::mutate(across(everything(), as.character)) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, '"', '|'))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "'", "|"))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, ",", ";"))) %>%
      dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x)))
    
      write_csv(a, paste0(final.data.directory, "project_paper_edges.csv"),  append = TRUE, col_names=!file.exists(paste0(final.data.directory, "project_paper_edges.csv")))
    
    print(paste(i, "of", length(filenames_project_paper_edges), "project_paper_edges"))
  })
}



if (file.exists(paste0(final.data.directory, "project_subproject_edges.csv"))) unlink(paste0(final.data.directory, "project_subproject_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_project_subproject_edges)){
  try({
    a <- read_csv(filenames_project_subproject_edges[i]) %>%
      dplyr::mutate(across(everything(), as.character)) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, '"', '|'))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "'", "|"))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, ",", ";"))) %>%
      dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x)))
    
      write_csv(a, paste0(final.data.directory, "project_subproject_edges.csv"), append = TRUE, col_names=!file.exists(paste0(final.data.directory, "project_subproject_edges.csv")))
    
    print(paste(i, "of", length(filenames_project_subproject_edges), "project_subproject_edges"))
  })
}



if (file.exists(paste0(final.data.directory, "project_paper_edges.csv"))) unlink(paste0(final.data.directory, "project_paper_edges.csv"), recursive = FALSE)

try({
  a <- read_csv(paste0(clean.data.directory, "project_paper_edges.csv")) %>%
    dplyr::mutate(across(everything(), as.character)) %>%
    dplyr::mutate(across(everything(), function(x) str_replace_all(x, '"', '|'))) %>%
    dplyr::mutate(across(everything(), function(x) str_replace_all(x, "'", "|"))) %>%
    dplyr::mutate(across(everything(), function(x) str_replace_all(x, ",", ";"))) %>%
    dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x)))
  
  write_csv(a, paste0(final.data.directory, "project_paper_edges.csv"))
  
})






