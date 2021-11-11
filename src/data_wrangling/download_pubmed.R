
############## ADMIN ###############
pubmed_baseline <- "https://ftp.ncbi.nlm.nih.gov/pubmed/baseline/"
pubmed_update   <- "https://ftp.ncbi.nlm.nih.gov/pubmed/updatefiles/"

storage.data.directory    <- paste0(root.data.directory, "data_pubmed_raw/")
clean.data.directory      <- paste0(root.data.directory, "data_pubmed_clean/")


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

file_names <- c(file_names_base, file_names_upd)
download_source       <- c(download_source_base, download_source_upd)
download_destination  <- c(download_destination_base, download_destination_base)
cleaning_destination  <- c(cleaning_destination_base, cleaning_destination_upd)
  
  
download_helper_articles <- function(i){
  download.file(download_source[i], download_destination[i])
}



clean_helper <- function(i){
  file <- xml2::read_xml(download_destination[i]) %>%
    xml2::xml_children()
  
  year         <- xml2::xml_find_first(file, ".//PubDate") %>% xml2::xml_text() %>% str_extract("[:digit:][:digit:][:digit:][:digit:]")
  selected     <- year %>%
                      as.numeric() %>%
                      {. >= 2003}
  
  if (!any(selected)){
    return(NULL) 
    file.remove(file_names[i])
    
  } else {
    file <- file[selected]
  }
  
  id           <- xml2::xml_find_first(file, ".//PMID") %>% xml2::xml_text()
  title        <- xml2::xml_find_first(file, ".//ArticleTitle") %>% xml2::xml_text()
  abstract     <- xml2::xml_find_first(file, ".//AbstractText") %>% xml2::xml_text() 
  key_words    <- xml2::xml_find_first(file, ".//KeyWordList") %>% xml2::xml_text() 
  journal_id      <- xml2::xml_find_first(file, ".//NlmUniqueID") %>% xml2::xml_text() 
  journal_title      <- xml2::xml_find_first(file, ".//Journal/Title") %>% xml2::xml_text() 
  year         <- xml2::xml_find_first(file, ".//PubDate") %>% xml2::xml_text() %>% str_extract("[:digit:][:digit:][:digit:][:digit:]")
  
  try({
    papers <- data.frame(id = id,
                         title = title, 
                         abstract = abstract, 
                         journal_id = journal_id,
                         journal_title = journal_title,
                         year = year
    ) 
  })
  
  mesh_list      <- xml2::xml_find_first(file, ".//MeshHeadingList") 
  author_list    <- xml2::xml_find_first(file, ".//AuthorList") 
  
  add_pmid_to_grandkids <- function(i) {
    mesh_list[i] %>%
      xml2::xml_children() %>%
      xml2::xml_children() %>%
      xml2::xml_set_attr(., "pmid", id[i])
    
    author_list[i] %>%
      xml2::xml_children() %>%
      xml2::xml_children() %>%
      xml2::xml_set_attr(., "pmid", id[i])
  }
  
  seq_along(mesh_list) %>% lapply(add_pmid_to_grandkids)
  
  mesh_desc_major           <- xml2::xml_find_first(mesh_list, ".//DescriptorName[@MajorTopicYN='Y']") %>% xml2::xml_text()
  mesh_desc_nonmajor        <- xml2::xml_find_first(mesh_list, ".//DescriptorName[@MajorTopicYN='N']") %>% xml2::xml_text() 
  mesh_qual_major           <- xml2::xml_find_first(mesh_list, ".//QualifierName[@MajorTopicYN='Y']") %>% xml2::xml_text() 
  mesh_qual_nonmajor        <- xml2::xml_find_first(mesh_list, ".//QualifierName[@MajorTopicYN='N']") %>% xml2::xml_text() 
  mesh_pmid                 <- xml2::xml_find_first(mesh_list, ".//QualifierName[@MajorTopicYN='N']") %>% xml2::xml_attr("pmid") 

  
  try({
    mesh_terms <- data.frame(mesh_desc_major = mesh_desc_major,
               mesh_desc_nonmajor = mesh_desc_nonmajor, 
               mesh_qual_major = mesh_qual_major, 
               mesh_qual_nonmajor = mesh_qual_nonmajor,
               mesh_pmid = mesh_pmid
               ) %>%
      dplyr::group_by(mesh_pmid) %>%
      summarize(mesh_desc_major = paste(mesh_desc_major, collapse = ";"),
                mesh_desc_nonmajor = paste(mesh_desc_nonmajor, collapse = ";"),
                mesh_qual_major = paste(mesh_qual_major, collapse = ";"),
                mesh_qual_nonmajor = paste(mesh_qual_nonmajor, collapse = ";"))
    
    papers <- papers %>%
      left_join(mesh_terms, by = c("id" = "mesh_pmid"))
    
  })
  
  lastname    <- author_list %>% xml2::xml_children() %>% xml2::xml_find_first(".//LastName") %>% xml2::xml_text()
  forename    <- author_list %>% xml2::xml_children() %>% xml2::xml_find_first(".//ForeName") %>% xml2::xml_text()
  initials    <- author_list %>% xml2::xml_children() %>% xml2::xml_find_first(".//Initials") %>% xml2::xml_text()
  author_pmid <- author_list %>% xml2::xml_children() %>% xml2::xml_find_first(".//LastName") %>% xml2::xml_attr("pmid") 
  
  try({
    author_paper_edges    <- data.frame(lastname = lastname,
                             forename = forename, 
                             initials = initials, 
                             id_paper = author_pmid) %>%
      drop_na() %>%
      mutate(name_author = paste(forename, lastname)) %>%
      dplyr::select(id_paper, name_author)
    
    authors <- author_paper_edges %>%
      dplyr::select(-id_paper) %>%
      unique()
  })
  

    result <- list()
    result$papers <- papers
    result$author_paper_edges <- author_paper_edges
    result$authors <- authors
    result
    
  

  
}

helper_download_and_clean <- function(i){
  
  download_helper_articles(i)
  result <- clean_helper(i)
  
  if (is_null(result)) return(NULL)
  
  try({
      write_csv(result$papers,              paste0(clean.data.directory, "papers_", i, ".csv"))
      write_csv(result$authors,             paste0(clean.data.directory, "authors_", i, ".csv"))
      write_csv(result$author_paper_edges,  paste0(clean.data.directory, "author_paper_edges_", i, ".csv"))
      file.remove(download_destination[i])
    
    
  })
  
  rm(result)
}

if (local) parallel::mclapply(900:901, helper_download_and_clean, mc.cores = parallel::detectCores() - 4)
if (!local) parallel::mclapply(seq_along(file_names), helper_download_and_clean, mc.cores = 8)

