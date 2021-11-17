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
  {.[str_detect(., "project_paper_edges")]} %>%
  paste0(clean.data.directory, .)

filenames_project_subproject_edges <- filenames %>%
  {.[str_detect(., "project_subproject_edges_")]} %>%
  paste0(clean.data.directory, .)



if (file.exists(paste0(final.data.directory, "investigator_nodes.csv"))) unlink(paste0(final.data.directory, "investigator_nodes.csv"), recursive = FALSE)

for (i in seq_along(filenames_investigator_nodes)){
  try({
    a <- read_csv(filenames_investigator_nodes[i]) %>%
      dplyr::mutate(id_investigator = as.numeric(id_investigator), name_investigator = trimws(as.character(name_investigator))) %>%
      dplyr::filter(!is.na(id_investigator) & !is.na(name_investigator) & name_investigator != "") %>%
      dplyr::mutate(id_investigator = paste0("inv_", id_investigator), name_investigator = trimws(as.character(name_investigator))) %>%
      dplyr::group_by(id_investigator) %>%
      dplyr::summarize(across(everything(), first)) %>%
      dplyr::rename(`id:ID` = id_investigator, name = name_investigator) %>%
      dplyr::mutate(`:LABEL` = "Investigator") 
      
    write_csv(a, paste0(final.data.directory, "investigator_nodes.csv"), append = (i != 1), col_names= FALSE)
    write_csv(a %>% filter(FALSE), paste0(final.data.directory, "investigator_nodes_headers.csv"),  col_names= TRUE)
    
    print(paste(i, "of", length(filenames_investigator_nodes), "investigator_nodes"))
  })
}


if (file.exists(paste0(final.data.directory, "investigator_project_edges.csv"))) unlink(paste0(final.data.directory, "investigator_project_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_investigator_project_edges)){
  try({
    a <- read_csv(filenames_investigator_project_edges[i]) %>%
      dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x))) %>%
      dplyr::mutate(id_investigator = as.numeric(id_investigator), id_project = trimws(as.character(id_project))) %>%
      dplyr::mutate(id_investigator = paste0("inv_", id_investigator), id_project = trimws(as.character(id_project))) %>%
      dplyr::filter(!is.na(id_investigator) & !is.na(id_investigator) & id_investigator != "") %>%
      dplyr::rename(`:START_ID` = id_investigator, `:END_ID` = id_project) %>%
      dplyr::mutate(`:TYPE` = "LED")  
      
    write_csv(a, paste0(final.data.directory, "investigator_project_edges.csv"), append = (i != 1), col_names=FALSE)
    write_csv(a %>% filter(FALSE), paste0(final.data.directory, "investigator_project_edges_headers.csv"),  col_names=TRUE)
    
    print(paste(i, "of", length(filenames_investigator_project_edges), "investigator_project_edges"))
  })
}

if (file.exists(paste0(final.data.directory, "organization_nodes.csv"))) unlink(paste0(final.data.directory, "organization_nodes.csv"), recursive = FALSE)

for (i in seq_along(filenames_organization_nodes)){
  try({
    a <- read_csv(filenames_organization_nodes[i]) %>%
      dplyr::mutate(id_organization = as.numeric(id_organization)) %>%
      dplyr::mutate(id_organization = paste0("org_", id_organization)) %>%
      dplyr::group_by(id_organization) %>%
      dplyr::summarize(across(everything(), first)) %>%
      dplyr::filter(!is.na(id_organization)) %>%
      dplyr::rename(`id:ID` = id_organization, name = name_organization, city = city_organization) %>%
      dplyr::mutate(`:LABEL` = "Organization")  
    
    write_csv(a, paste0(final.data.directory, "organization_nodes.csv"),  append = (i != 1), col_names= FALSE)
    write_csv(a %>% filter(FALSE), paste0(final.data.directory, "organization_nodes_headers.csv"), col_names= TRUE)
    
    print(paste(i, "of", length(filenames_organization_nodes), "organization_nodes"))
  })
}

if (file.exists(paste0(final.data.directory, "organization_project_edges.csv"))) unlink(paste0(final.data.directory, "organization_project_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_organization_project_edges)){
  try({
    a <- read_csv(filenames_organization_project_edges[i]) %>%
      dplyr::mutate(id_organization = as.numeric(id_organization), id_project = trimws(as.character(id_project))) %>%
      dplyr::mutate(id_organization = paste0("org_", id_organization), id_project = trimws(as.character(id_project))) %>%
      dplyr::filter(!is.na(id_organization) & !is.na(id_project) & id_project != "") %>%
      dplyr::rename(`:START_ID` = id_organization, `:END_ID` = id_project) %>%
      dplyr::mutate(`:TYPE` = "HOSTED") 
    
      write_csv(a, paste0(final.data.directory, "organization_project_edges.csv"),  append = (i != 1), col_names= FALSE)
      write_csv(a %>% filter(FALSE), paste0(final.data.directory, "organization_project_edges_headers.csv"),   col_names= TRUE)
    
    print(paste(i, "of", length(filenames_organization_project_edges), "organization_project_edges"))
  })
}


if (file.exists(paste0(final.data.directory, "project_nodes.csv"))) unlink(paste0(final.data.directory, "project_nodes.csv"), recursive = FALSE)

for (i in seq_along(filenames_project_nodes)){
  try({
    a <- read_csv(filenames_project_nodes[i]) %>%
      dplyr::mutate(id_project = as.character(trimws(id_project))) %>%
      dplyr::group_by(id_project) %>%
      dplyr::summarise(across(everything(), first)) %>%
      dplyr::filter(!is.na(id_project) & id_project != "") %>%
      dplyr::rename(`id:ID` = id_project) %>%
      dplyr::mutate(`:LABEL` = "Project")  
      
      write_csv(a, paste0(final.data.directory, "project_nodes.csv"),  append = (i != 1), col_names= FALSE)
      write_csv(a %>% filter(FALSE), paste0(final.data.directory, "project_nodes_headers.csv"), col_names= TRUE)
    
    print(paste(i, "of", length(filenames_project_nodes), "project_nodes"))
  })
}


if (file.exists(paste0(final.data.directory, "project_paper_edges.csv"))) unlink(paste0(final.data.directory, "project_paper_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_project_paper_edges)){
  try({
    a <- read_csv(filenames_project_paper_edges[i]) %>%
      dplyr::mutate(id_paper = as.numeric(id_paper), id_project = trimws(as.character(id_project))) %>%
      dplyr::mutate(id_paper = paste0("pap_", id_paper), id_project = trimws(as.character(id_project))) %>%
      dplyr::filter(!is.na(id_paper) & !is.na(id_project) & id_project != "") %>%
      dplyr::rename(`:START_ID` = id_project, `:END_ID` = id_paper) %>%
      dplyr::mutate(`:TYPE` = "SUPPORTED") 
    
      write_csv(a, paste0(final.data.directory, "project_paper_edges.csv"),  append = (i != 1), col_names= FALSE)
      write_csv(a %>% filter(FALSE), paste0(final.data.directory, "project_paper_edges_headers.csv"),  col_names= TRUE)
    
    print(paste(i, "of", length(filenames_project_paper_edges), "project_paper_edges"))
  })
}



if (file.exists(paste0(final.data.directory, "project_subproject_edges.csv"))) unlink(paste0(final.data.directory, "project_subproject_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_project_subproject_edges)){
  try({
    a <- read_csv(filenames_project_subproject_edges[i]) %>%
      dplyr::mutate(id_project = trimws(as.character(id_project)), id_subproject = trimws(as.character(id_subproject))) %>%
      dplyr::filter(!is.na(id_project) & !is.na(id_subproject)) %>%
      dplyr::rename(`:START_ID` = id_project, `:END_ID` = id_subproject) %>%
      dplyr::mutate(`:TYPE` = "BEGAT") 
    
      write_csv(a, paste0(final.data.directory, "project_subproject_edges.csv"), append = (i != 1), col_names= FALSE)
      write_csv(a %>% filter(FALSE), paste0(final.data.directory, "project_subproject_edges_headers.csv"),  col_names= TRUE)
    
    print(paste(i, "of", length(filenames_project_subproject_edges), "project_subproject_edges"))
  })
}


if (file.exists(paste0(final.data.directory, "project_paper_edges.csv"))) unlink(paste0(final.data.directory, "project_paper_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_project_paper_edges)){
  try({
    a <- read_csv(filenames_project_paper_edges[i]) %>%
      dplyr::mutate(across(everything(), as.character)) %>%
      dplyr::mutate(id_paper = as.numeric(id_paper), id_project = trimws(as.character(id_project))) %>%
      dplyr::filter(!is.na(id_paper) & !is.na(id_project) & id_project != "")  %>%
      dplyr::rename(`:START_ID` = id_project, `:END_ID` = id_paper)
    
    write_csv(a, paste0(final.data.directory, "project_paper_edges.csv"), append = (i != 1), col_names= FALSE)
    write_csv(a %>% filter(FALSE), paste0(final.data.directory, "project_paper_edges_headers.csv"),  col_names= TRUE)
    
    print(paste(i, "of", length(filenames_project_paper_edges), "project_paper_edges"))
  })
}

