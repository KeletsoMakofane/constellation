
############ UTITLITY FUNCTIONS #################
first_valid <- function(vec){
  if (all(is.na(vec))) return(NA)
  
  vec[!is.na(vec)][1]
}

strip_linebreaks <- function(text){
  text %>% str_replace_all("[:blank:]"," ") %>% str_replace_all("[:space:]"," ")
}


############## URLS ###############
exporter_projects    <- "https://exporter.nih.gov/ExPORTER_Catalog.aspx?sid=0&index=0"
exporter_linktable   <- "https://exporter.nih.gov/ExPORTER_Catalog.aspx?sid=0&index=5"

storage.data.directory    <- paste0(root.data.directory, "data_funding_raw/")
clean.data.directory      <- paste0(root.data.directory, "data_funding_clean/")

unlink(storage.data.directory, recursive = TRUE, force = TRUE)
unlink(clean.data.directory, recursive = TRUE, force = TRUE)

dir.create(storage.data.directory)
dir.create(clean.data.directory)



############ Directories #################
storage.data.directory    <- paste0(root.data.directory, "data_funding_raw/")
clean.data.directory      <- paste0(root.data.directory, "data_funding_clean/")

############## GET FILENAMES ###############
file_names_projects <- httr::GET(exporter_projects) %>%
  xml2::read_html() %>%
  xml2::xml_contents() %>%
  xml2::xml_children() %>%
  xml2::xml_find_all("//a") %>%
  xml2::xml_attr("href") %>%
  {.[str_detect(., "CSVs")]} %>%
  {.[!str_detect(., "https")]} %>%
  {.[!is.na(.)]}

file_directory_projects <- file_names_projects %>%
  paste0("https://exporter.nih.gov/", .)


file_names_links <- httr::GET(exporter_linktable) %>%
  xml2::read_html() %>%
  xml2::xml_contents() %>%
  xml2::xml_children() %>%
  xml2::xml_find_all("//a") %>%
  xml2::xml_attr("href") %>%
  {.[str_detect(., "CSVs")]} %>%
  {.[!str_detect(., "https")]} %>%
  {.[!is.na(.)]}

file_directory_links <- file_names_links %>%
  paste0("https://exporter.nih.gov/", .)


filenames <- list.files(storage.data.directory)

filenames_proj <- filenames %>%
  {.[str_detect(., "project_file_")]}

filenames_link <- filenames %>%
  {.[str_detect(., "link_file_")]}



############ DOWNLOAD FUNCTIONS #################

get_project_nodes <- function(file_project){
  file_project %>%
    dplyr::select(id_project, title, year, indirect_cost, direct_cost, total_cost, total_cost_subproject) %>%
    unique() %>%
    dplyr::group_by(id_project) %>%
    dplyr::summarize(title = first(title), 
                     year = first(year), 
                     indirect_cost = first_valid(indirect_cost),
                     direct_cost = first_valid(direct_cost),
                     total_cost = first_valid(total_cost), 
                     total_cost_subproject = first_valid(total_cost_subproject)) %>% 
    mutate(across(contains("cost"), function(x) ifelse(is.na(x), 0, x))) %>%
    mutate(title = strip_linebreaks(title))
}


get_investigator_info <- function(file_project){
  file_project %>%
    dplyr::select(id_investigator, name_investigator, id_project) %>%
    dplyr::mutate(id_investigator = str_remove(id_investigator, fixed("(contact)")), name_investigator = str_remove(name_investigator, fixed("(contact)"))) %>%
    dplyr::mutate(id_investigator = str_split(id_investigator, ";"),
                  name_investigator = str_split(name_investigator, ";"))
}

get_investigator_nodes <- function(investigator_info){
  extract_name_id_investigators <- function(x, y){
    x <- x %>% trimws() %>% {.[. != ""]} 
    
    y <- y %>% trimws() %>% {.[. != ""]} 
    
    if (length(x) > 0 & length(y) > 0) return(data.frame(id_investigator = x, name_investigator = y))
    
    return(NULL)
  }
  
  purrr::map2(investigator_info$id_investigator,  investigator_info$name_investigator, extract_name_id_investigators) %>%
    bind_rows() %>%
    dplyr::filter(trimws(id_investigator) != "" & trimws(name_investigator) != "")
  
}

get_investigator_project_edges <- function(investigator_info){
  extract_investigator_project <- function(x, y){
    x <-  x %>% trimws() %>% {.[. != ""]}
    
    y <- y %>% trimws() %>% {.[. != ""]}
    
    if (length(x) > 0 & length(y) > 0) return(data.frame(id_investigator = x, id_project = y))
    
    return(NULL)
  }
  
  purrr::map2(investigator_info$id_investigator,  investigator_info$id_project, extract_investigator_project) %>% 
    bind_rows() %>%
    dplyr::filter(trimws(id_project) != "" & trimws(id_investigator) != "")
}

get_organization_and_project_info <- function(file_project){
  file_project %>%
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
}

get_organization_nodes <- function(organization_and_project_info){
  organization_and_project_info %>%
    dplyr::select(id_organization, name_organization, city_organization) %>%
    dplyr::group_by(id_organization) %>%
    dplyr::summarize(name_organization = first_valid(name_organization), city_organization = first_valid(city_organization) )
}

get_organization_project_edges <- function(organization_and_project_info){
  organization_and_project_info %>%
    dplyr::select(id_organization, id_project) %>%
    drop_na() %>%
    dplyr::filter(id_organization != "NA" & id_organization != "" & id_project != "NA" & id_project != "") %>%
    unique()
}

get_project_sub_project_edges <- function(file_project){
  file_project %>% 
    dplyr::select(id_project, core_project_number, year) %>%
    dplyr::mutate(id_subproject = paste(core_project_number, year, "0", sep = "_")) %>%
    unique() %>%
    dplyr::filter(id_project != id_subproject) %>%
    dplyr::select(id_project, id_subproject)
}

get_project_paper_edges <- function(file_links){
  file_links %>%
    dplyr::rename(id_paper = PMID, id_project = PROJECT_NUMBER) 
}


download_and_clean_data_links <- function(i){
  download.file(file_directory_links[i]   , paste0(storage.data.directory, "link_file_"   , i, ".zip"))
  
  try({file_links                  <- read_csv(paste0(storage.data.directory, "link_file_"   , i, ".zip"))})
  try({project_paper_edges         <- get_project_paper_edges(file_links)})
  
  counter_done <- 0
  try({ 
    write_csv(project_paper_edges,         paste0(clean.data.directory, "project_paper_edges_", i, ".csv")) 
    counter_done <- counter_done + 1
  })
  
  if (counter_done == 1){
    file.remove(paste0(storage.data.directory, "link_file_"   , i, ".zip"))
    print(paste("links download", i, "of", length(indices),  "done"))
  } else {
    print(paste("links download", i, "of", length(indices),  "failed********"))
  }
  
  return(NULL)
  
}

download_and_clean_data_projects <- function(i){
  download.file(file_directory_projects[i], paste0(storage.data.directory, "project_file_", i, ".zip"))

  
  project_clean_pre <- read_csv(paste0(storage.data.directory, "project_file_"   , i, ".zip")) %>%
    dplyr::mutate(across(everything(), function(x) iconv(x, to = "UTF-8")))
    
  
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
  
  file_project <- project_clean_pre %>%
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
  
  
  
  try({project_nodes                 <- get_project_nodes(file_project)})
  try({project_subproject_edges     <- get_project_sub_project_edges(file_project)})
  
  try({investigator_info            <- get_investigator_info(file_project)})
  try({investigator_nodes           <- get_investigator_nodes(investigator_info)})
  try({investigator_project_edges   <- get_investigator_project_edges(investigator_info)})
  
  try({organization_and_project_info <- get_organization_and_project_info(file_project)})
  try({organization_nodes            <- get_organization_nodes(organization_and_project_info)})
  try({organization_project_edges    <- get_organization_project_edges(organization_and_project_info)})
  
  counter_done <- 0
  
  try({ 
    write_csv(project_nodes,              paste0(clean.data.directory, "project_nodes_",        i, ".csv")) 
    counter_done <- counter_done + 1
  })
  
  try({ 
    write_csv(project_subproject_edges,  paste0(clean.data.directory, "project_subproject_edges_",        i, ".csv")) 
    counter_done <- counter_done + 1
  })
  
  
  
  try({ 
    write_csv(organization_nodes,         paste0(clean.data.directory, "organization_nodes_",       i, ".csv")) 
    counter_done <- counter_done + 1
  })
  
  try({ 
    write_csv(investigator_nodes,         paste0(clean.data.directory, "investigator_nodes_", i, ".csv")) 
    counter_done <- counter_done + 1
  })
  
  try({ 
    write_csv(organization_project_edges,         paste0(clean.data.directory, "organization_project_edges_", i, ".csv")) 
    counter_done <- counter_done + 1
  })
  
  
  try({ 
    write_csv(investigator_project_edges,         paste0(clean.data.directory, "investigator_project_edges_", i, ".csv")) 
    counter_done <- counter_done + 1
  })
  
  
  
  if (counter_done == 6){
    file.remove(paste0(storage.data.directory, "project_file_", i, ".zip"))
    print(paste("project download", i, "of", length(indices),  "done"))
  } else {
    print(paste("project download", i, "of", length(indices),  "failed********"))
  }
  
  return(NULL)
}

############ EXECUTE DOWNLOAD FUNCTIONS #################

indices <- seq_along(file_names_projects)

if (local) indices <- 1:10

for (i in 43:length(indices)){
  download_and_clean_data_projects(i)
  download_and_clean_data_links(i)
}










