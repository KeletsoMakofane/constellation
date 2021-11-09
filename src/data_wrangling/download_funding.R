
############ Functions #################
first_valid <- function(vec){
  if (all(is.na(vec))) return(NA)
  
  vec[!is.na(vec)][1]
}

############ Directories #################
storage.data.directory    <- paste0(root.data.directory, "data_funding_raw/")
clean.data.directory      <- paste0(root.data.directory, "data_funding_clean/")

filenames <- list.files(storage.data.directory)

filenames_proj <- filenames %>%
  {.[str_detect(., "_PRJ_")]}

filenames_link <- filenames %>%
  {.[str_detect(., "_PUBLNK_")]}

link_file_list <- list()

############ Projec-Paper Links #################

for (i in seq_along(filenames_link)){
  link_file_list[[i]] <- read.csv(paste0(storage.data.directory, filenames_link[i])) %>%
                              dplyr::rename(id_paper = PMID, id_project = PROJECT_NUMBER) 
}

project_paper_edges <- link_file_list %>%
  dplyr::bind_rows() 

write.csv(project_paper_edges, paste0(clean.data.directory, "project_paper_edges.csv") )


############ Nodes and Edges #################

for (i in seq_along(filenames_proj)){

  project_clean_pre <- read.csv(paste0(storage.data.directory, filenames_proj[i])) %>%
    dplyr::filter(CORE_PROJECT_NUM %in% project_paper_edges$id_project) 
  
  if (dim(project_clean_pre)[1] == 0) return(NULL)
  
  if (is.null(project_clean_pre$INDIRECT_COST_AMT)) project_clean_pre$INDIRECT_COST_AMT <- NA
  if (is.null(project_clean_pre$DIRECT_COST_AMT)) project_clean_pre$DIRECT_COST_AMT <- NA
  if (is.null(project_clean_pre$TOTAL_COST)) project_clean_pre$TOTAL_COST <- NA
  if (is.null(project_clean_pre$TOTAL_COST_SUB_PROJECT)) project_clean_pre$TOTAL_COST <- NA
  if (is.null(project_clean_pre$ORG_IPF_CODE)) project_clean_pre$ORG_IPF_CODE <- NA
  if (is.null(project_clean_pre$ORG_NAME)) project_clean_pre$ORG_NAME <- NA
  if (is.null(project_clean_pre$ORG_CITY)) project_clean_pre$ORG_CITY <- NA
  if (is.null(project_clean_pre$ORG_COUNTRY)) project_clean_pre$ORG_COUNTRY <- NA
  if (is.null(project_clean_pre$PI_IDS)) project_clean_pre$PI_IDS <- NA
  if (is.null(project_clean_pre$PI_NAMEs)) project_clean_pre$PI_NAMEs <- NA
  if (is.null(project_clean_pre$CORE_PROJECT_NUM)) project_clean_pre$CORE_PROJECT_NUM <- NA
  
  project_clean <- project_clean_pre %>%
    dplyr::mutate(SUBPROJECT_ID = ifelse(is.na(SUBPROJECT_ID), 0, SUBPROJECT_ID)) %>%
    dplyr::mutate(id_project = paste(CORE_PROJECT_NUM, FY, SUBPROJECT_ID, sep = "_")) %>%
    dplyr::mutate(title = PROJECT_TITLE, 
                  year = FY,
                  indirect_cost = INDIRECT_COST_AMT,
                  direct_cost = DIRECT_COST_AMT,
                  total_cost = TOTAL_COST,
                  total_cost_subproject = TOTAL_COST_SUB_PROJECT,
                  id_organization = ORG_IPF_CODE, 
                  name_organization = ORG_NAME,
                  city_organization = ORG_CITY,
                  city_country = ORG_COUNTRY,
                  id_investigator = PI_IDS,
                  name_investigator = PI_NAMEs,
                  core_project_number = CORE_PROJECT_NUM)
  
  project_nodes <- project_clean %>%
                      dplyr::select(id_project, title, year, indirect_cost, direct_cost, total_cost, total_cost_subproject) %>%
    unique() %>%
    dplyr::group_by(id_project) %>%
    dplyr::summarize(title = first(title), 
                     year = first(year), 
                     indirect_cost = first_valid(indirect_cost),
                     direct_cost = first_valid(direct_cost),
                     total_cost = first_valid(total_cost), 
                     total_cost_subproject = first_valid(total_cost_subproject)) %>% 
    mutate(across(contains("cost"), function(x) ifelse(is.na(x), 0, x)))
  
  
  
  organization_project_info <- project_clean %>%
    dplyr::select(id_organization, name_organization, city_organization, city_country, id_project) %>%
    unique() %>%
    dplyr::group_by(id_organization) %>%
    dplyr::mutate(name_organization = first_valid(name_organization), city_organization = first_valid(city_organization), city_country = first_valid(city_country)) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(name_organization) %>%
    dplyr::mutate(id_organization = first_valid(id_organization), 
                  city_organization = first_valid(city_organization), 
                  city_country = first_valid(city_country)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(name_organization = ifelse(is.na(name_organization), id_organization, name_organization),
                  id_organization = ifelse(is.na(id_organization), digest::digest2int(as.character(id_organization)), id_organization))
  
  organization_nodes <- organization_project_info %>%
    dplyr::select(id_organization, name_organization, city_organization) %>%
    dplyr::group_by(id_organization) %>%
    dplyr::summarize(name_organization = first_valid(name_organization), city_organization = first_valid(city_organization) )
  
  investigator_pre <- project_clean %>%
    dplyr::select(id_investigator, name_investigator, id_project) %>%
    dplyr::mutate(id_investigator = str_remove(id_investigator, fixed("(contact)")), name_investigator = str_remove(name_investigator, fixed("(contact)"))) %>%
    dplyr::mutate(id_investigator = str_split(id_investigator, ";"),
                  name_investigator = str_split(name_investigator, ";"))
  
  investigator_nodes <- purrr::map2(investigator_pre$id_investigator,  investigator_pre$name_investigator, function(x, y) {data.frame(id_investigator = x, name_investigator = y)}) %>%
    bind_rows() %>%
    dplyr::filter(trimws(id_investigator) != "" & trimws(name_investigator) != "")
  
  investigator_project_edges <- purrr::map2(investigator_pre$id_investigator,  investigator_pre$id_project, function(x, y) {data.frame(id_investigator = x, id_project = y)}) %>% 
    bind_rows() %>%
    dplyr::filter(trimws(id_project) != "" & trimws(id_investigator) != "")
  
  organization_project_edges <- organization_project_info %>%
    dplyr::select(id_organization, id_project) %>%
    drop_na() %>%
    dplyr::filter(id_organization != "NA" & id_organization != "" & id_project != "NA" & id_project != "") %>%
    unique()
  
  project_subproject_edges <- project_clean %>% 
    dplyr::select(id_project, core_project_number, year) %>%
    dplyr::mutate(id_subproject = paste(core_project_number, year, "0", sep = "_")) %>%
    unique() %>%
    dplyr::filter(id_project != id_subproject) %>%
    dplyr::select(id_project, id_subproject)
  
  
  
  write.csv(project_nodes, paste0(clean.data.directory, "project_nodes_", i, ".csv"))
  write.csv(organization_nodes, paste0(clean.data.directory, "organization_nodes_", i, ".csv"))
  write.csv(investigator_nodes, paste0(clean.data.directory, "investigator_nodes_", i, ".csv"))
  
  write.csv(investigator_project_edges, paste0(clean.data.directory, "investigator_project_edges_", i, ".csv"))
  write.csv(organization_project_edges, paste0(clean.data.directory, "organization_project_edges_", i, ".csv"))
  write.csv(project_subproject_edges, paste0(clean.data.directory, "project_subproject_edges_", i, ".csv"))
  
  rm(project_nodes)
  rm(organization_nodes)
  rm(investigator_nodes)
  rm(investigator_project_edges)
  rm(organization_project_edges)
  rm(project_subproject_edges)

}










