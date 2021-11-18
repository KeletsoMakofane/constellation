
############## ADMIN ###############
pubmed_baseline <- "https://ftp.ncbi.nlm.nih.gov/pubmed/baseline/"
pubmed_update   <- "https://ftp.ncbi.nlm.nih.gov/pubmed/updatefiles/"

storage.data.directory    <- paste0(root.data.directory, "data_pubmed_raw/")
clean.data.directory      <- paste0(root.data.directory, "data_pubmed_clean/")

mopup_files <- TRUE

if (!mopup_files){
  unlink(storage.data.directory, recursive = TRUE, force = TRUE)
  unlink(clean.data.directory, recursive = TRUE, force = TRUE)

  dir.create(storage.data.directory)
  dir.create(clean.data.directory)
}


############## GET FILENAMES ###############
file_names_base <- httr::GET(pubmed_baseline) %>%
                  xml2::read_html() %>%
                  xml2::xml_contents() %>%
                  xml2::xml_children() %>%
                  xml2::xml_find_all("//a") %>%
                  xml2::xml_text() %>%
                  {.[str_detect(., "xml")]} %>%
                  {.[!str_detect(., "md5")]}
                  
download_source_base       <- paste0(pubmed_baseline, file_names_base)
download_destination_base  <- paste0(storage.data.directory, file_names_base)
cleaning_destination_base  <- paste0(clean.data.directory, file_names_base)

file_names_upd <- httr::GET(pubmed_update) %>%
  xml2::read_html() %>%
  xml2::xml_contents() %>%
  xml2::xml_children() %>%
  xml2::xml_find_all("//a") %>%
  xml2::xml_text() %>%
  {.[str_detect(., "xml")]} %>%
  {.[!str_detect(., "md5")]}

download_source_upd       <- paste0(pubmed_update, file_names_upd)
download_destination_upd  <- paste0(storage.data.directory, file_names_upd)
cleaning_destination_upd  <- paste0(clean.data.directory, file_names_upd)

file_names            <- c(file_names_base, file_names_upd)
download_source       <- c(download_source_base, download_source_upd)
download_destination  <- c(download_destination_base, download_destination_base)
cleaning_destination  <- c(cleaning_destination_base, cleaning_destination_upd)


strip_linebreaks <- function(text){
  text %>% trimws() %>% str_replace_all("[:blank:]"," ") %>% str_replace_all("[:space:]"," ") %>% str_replace_all('"', '|') %>% str_replace_all("'", "|") %>% str_replace_all(",", ";")
}


first_valid <- function(vec){
  if (all(is.na(vec))) return(NA)
  
  vec[!is.na(vec)][1]
}

############## DOWNLOAD FUNCTIONS ###############

get_papers_basic_info <- function(file){
    id                 <- xml2::xml_find_first(file, ".//PMID")          %>% xml2::xml_text()  %>% strip_linebreaks()
    year               <- xml2::xml_find_first(file, ".//PubDate")       %>% xml2::xml_text() %>% str_extract("[:digit:][:digit:][:digit:][:digit:]")  %>% strip_linebreaks()
    title              <- xml2::xml_find_first(file, ".//ArticleTitle")  %>% xml2::xml_text()  %>% strip_linebreaks()
    key_words          <- xml2::xml_find_first(file, ".//KeyWordList")   %>% xml2::xml_text()  %>% strip_linebreaks()
    journal_id         <- xml2::xml_find_first(file, ".//NlmUniqueID")   %>% xml2::xml_text()  %>% strip_linebreaks()
    journal_title      <- xml2::xml_find_first(file, ".//Journal/Title") %>% xml2::xml_text()  %>% strip_linebreaks()
    abstract           <- xml2::xml_find_first(file, ".//AbstractText")  %>% xml2::xml_text()  %>% strip_linebreaks()


  
  try({
    papers <- data.frame(id = id,
                         title = title, 
                         abstract = abstract, 
                         journal_id = journal_id,
                         journal_title = journal_title,
                         year = year)
    
    return(papers)
  })
    
  return(NULL)
}

get_mesh_list <- function(file){
  id                 <- xml2::xml_find_first(file, ".//PMID")          %>% xml2::xml_text()  %>% strip_linebreaks()
  
  helper_add_pmid_to_grandkids <- function(j) {
    
    mesh_list[j] %>%
      xml2::xml_children() %>%
      xml2::xml_children() %>%
      xml2::xml_set_attr(., "pmid", id[j])
    
  }
  
  
  mesh_list      <- xml2::xml_find_first(file, ".//MeshHeadingList") 

  seq_along(mesh_list) %>% lapply(helper_add_pmid_to_grandkids)
  
  mesh_desc_major           <- xml2::xml_find_first(mesh_list, ".//DescriptorName[@MajorTopicYN='Y']") %>% xml2::xml_text() %>% strip_linebreaks()
  mesh_desc_nonmajor        <- xml2::xml_find_first(mesh_list, ".//DescriptorName[@MajorTopicYN='N']") %>% xml2::xml_text()  %>% strip_linebreaks()
  mesh_qual_major           <- xml2::xml_find_first(mesh_list, ".//QualifierName[@MajorTopicYN='Y']") %>% xml2::xml_text()  %>% strip_linebreaks()
  mesh_qual_nonmajor        <- xml2::xml_find_first(mesh_list, ".//QualifierName[@MajorTopicYN='N']") %>% xml2::xml_text() %>% strip_linebreaks() 
  mesh_pmid                 <- xml2::xml_find_first(mesh_list, ".//QualifierName[@MajorTopicYN='N']") %>% xml2::xml_attr("pmid")  %>% strip_linebreaks()
  
  try({
    mesh_terms <- data.frame(mesh_desc_major = mesh_desc_major,
                             mesh_desc_nonmajor = mesh_desc_nonmajor, 
                             mesh_qual_major = mesh_qual_major, 
                             mesh_qual_nonmajor = mesh_qual_nonmajor,
                             mesh_pmid = mesh_pmid) %>%
      dplyr::group_by(mesh_pmid) %>%
      dplyr::summarize( mesh_desc_major    = paste(mesh_desc_major,    collapse = ";"),
                        mesh_desc_nonmajor = paste(mesh_desc_nonmajor, collapse = ";"),
                        mesh_qual_major    = paste(mesh_qual_major,    collapse = ";"),
                        mesh_qual_nonmajor = paste(mesh_qual_nonmajor, collapse = ";")) %>%
      dplyr::ungroup()
    
    return(mesh_terms)
    
  })
  
  return(NULL)
}

get_paper_nodes <- function(file){
  basic <- get_papers_basic_info(file)
  mesh  <- get_mesh_list(file)
  
  try({
    result <- basic %>%
      left_join(mesh, by = c("id" = "mesh_pmid"))
    
    return(result)
  })
  
  result_basic <- basic %>%
    dplyr::mutate(mesh_desc_major = NA, 
                  mesh_desc_nonmajor = NA, 
                  mesh_qual_major = NA, 
                  mesh_qual_nonmajor = NA)
  
  cat("mesh terms empty")
  return(result_basic)
}

get_author_paper_edges <- function(file){
  id                 <- xml2::xml_find_first(file, ".//PMID")          %>% xml2::xml_text()  %>% strip_linebreaks()
  
  
  helper_add_pmid_to_grandkids <- function(j) {
    
    
    
    author_list[j] %>%
      xml2::xml_children() %>%
      xml2::xml_children() %>%
      xml2::xml_set_attr(., "pmid", id[j])
    
  }
  
  
  
  author_list    <- xml2::xml_find_first(file, ".//AuthorList") 
  
  seq_along(author_list) %>% lapply(helper_add_pmid_to_grandkids)
  
  lastname    <- author_list %>% xml2::xml_children() %>% xml2::xml_find_first(".//LastName") %>% xml2::xml_text() %>% strip_linebreaks()
  forename    <- author_list %>% xml2::xml_children() %>% xml2::xml_find_first(".//ForeName") %>% xml2::xml_text() %>% strip_linebreaks()
  initials    <- author_list %>% xml2::xml_children() %>% xml2::xml_find_first(".//Initials") %>% xml2::xml_text() %>% strip_linebreaks()
  author_pmid <- author_list %>% xml2::xml_children() %>% xml2::xml_find_first(".//LastName") %>% xml2::xml_attr("pmid")  %>% strip_linebreaks()
  
  try({
    authors    <- data.frame(lastname = lastname,
                             forename = forename, 
                             initials = initials, 
                             author_pmid = author_pmid) %>%
      dplyr::mutate(author_name = paste(forename, lastname))
    
    return(authors)
  })
  
  return(NULL)
  
}
  
get_author_nodes <- function(author_paper_edges){
  try({
    authors <- author_paper_edges %>% 
      dplyr::group_by(author_name) %>%
      dplyr::summarize(lastname = first_valid(lastname), forename = first_valid(forename), initials = first_valid(initials))
    
    return(authors)
  })
  return(NULL)
}


download_and_clean_data_pre <- function(i){
  download.file(download_source[i], download_destination[i]) 
  
  file               <- xml2::read_xml(download_destination[i]) %>% xml2::xml_children()   # open file
  
  
  paper_nodes        <- get_paper_nodes(file)
  author_paper_edges <- get_author_paper_edges(file)
  author_nodes       <- get_author_nodes(author_paper_edges)
  
  counter_done <- 0
  
  try({ 
    write_csv(paper_nodes,                paste0(clean.data.directory, "paper_nodes_",        i, ".csv")) 
    counter_done <- counter_done + 1
    })
  
  try({ 
    write_csv(author_nodes,               paste0(clean.data.directory, "author_nodes_",       i, ".csv")) 
    counter_done <- counter_done + 1
    })
  
  try({ 
    write_csv(author_paper_edges,         paste0(clean.data.directory, "author_paper_edges_", i, ".csv")) 
    counter_done <- counter_done + 1
    })
    
  
  if (counter_done == 3){
    file.remove(download_destination[i])
    print(paste("download", i, "successful"))
  } else {
    print(paste("download", i, "failed"))
  }
  

  return(NULL)
}

clean_data_mopup_pre <- function(i){
  
  file               <- xml2::read_xml(mop_up_list[i]) %>% xml2::xml_children()   # open file
  cat(paste("opened", mop_up_list[i]))
  
  paper_nodes        <- get_paper_nodes(file)
  cat(paste("got paper nodes"))
  author_paper_edges <- get_author_paper_edges(file)
  cat(paste("got author edges"))
  author_nodes       <- get_author_nodes(author_paper_edges)
  cat(paste("got author nodes"))
  
  counter_done <- 0
  
  try({ 
    write_csv(paper_nodes,                paste0(clean.data.directory, "paper_nodes_",        i, "_mopup.csv")) 
    counter_done <- counter_done + 1
    cat(paste("success saving paper nodes"))
  })
  
  try({ 
    write_csv(author_nodes,               paste0(clean.data.directory, "author_nodes_",       i, "_mopup.csv")) 
    counter_done <- counter_done + 1
    cat(paste("success saving author nodes"))
  })
  
  try({ 
    write_csv(author_paper_edges,         paste0(clean.data.directory, "author_paper_edges_", i, "_mopup.csv")) 
    counter_done <- counter_done + 1
    cat(paste("success saving autho+paper_edges"))
  })
  
  
  if (counter_done == 3){
    file.remove(mop_up_list[i])
    cat(paste("download mopup", i, "successful"))
  } else {
    cat(paste("download mopup", i, "failed"))
  }
  
  
  return(NULL)
}

download_and_clean_data <- possibly(download_and_clean_data_pre, otherwise = NULL)
clean_data_mopup <- possibly(clean_data_mopup_pre, otherwise = NULL)


############## EXECUTE DOWNLOAD FUNCTIONS ###############

if (local & !mopup_files) {
  download_and_clean_data(900)
  Sys.sleep(1)
  download_and_clean_data(901)
  Sys.sleep(1)
  download_and_clean_data(902)
  Sys.sleep(1)
}

if (local & mopup_files) {
  file_names_mopup <- list.files(path = storage.data.directory)
  mop_up_list <- paste0(storage.data.directory, file_names_mopup)[1:3]
  
  clean_data_mopup(1)
  Sys.sleep(1)
  clean_data_mopup(2)
  Sys.sleep(1)
  clean_data_mopup(3)
  Sys.sleep(1)
}


if (!local & !mopup_files) parallel::mclapply(seq_along(file_names), download_and_clean_data, mc.cores = 8)



if (!local & mopup_files){
  
  file_names_mopup <- list.files(path = storage.data.directory)
  mop_up_list <- paste0(storage.data.directory, file_names_mopup)
  parallel::mclapply(seq_along(file_names_mopup), clean_data_mopup, mc.cores = 8)
} 

