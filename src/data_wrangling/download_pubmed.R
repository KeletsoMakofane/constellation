
############## ADMIN ###############
pubmed_baseline <- "https://ftp.ncbi.nlm.nih.gov/pubmed/baseline/"
pubmed_update   <- "https://ftp.ncbi.nlm.nih.gov/pubmed/updatefiles/"

storage.data.directory    <- paste0(root.data.directory, "data_pubmed_raw/")


############## BASELINE ###############
file_names <- httr::GET(pubmed_baseline) %>%
                  xml2::read_html() %>%
                  xml2::xml_contents() %>%
                  xml2::xml_children() %>%
                  xml2::xml_find_all("//a") %>%
                  xml2::xml_text() %>%
                  {.[str_detect(., "xml")]} %>%
                  {.[!str_detect(., "md5")]}
                  
download_source       <- paste0(pubmed_baseline, file_names)
download_destination  <- paste0(storage.data.directory, file_names)

download_helper <- function(i){
  download.file(download_source[i], download_destination[i])
}

clean_helper <- function(i){
  file <- xml2::read_xml(download_destination[i]) %>%
    xml2::xml_children()
  
  year         <- xml2::xml_find_first(file, ".//PubDate") %>% xml2::xml_text() %>% str_extract("[:digit:][:digit:][:digit:][:digit:]")
  selected     <- year %>%
                      as.numeric() %>%
                      {. >= 2003}
  
  if (!any(selected)) return(NULL) else file <- file[selected]
  
  id           <- xml2::xml_find_first(file, ".//PMID") %>% xml2::xml_text()
  title        <- xml2::xml_find_first(file, ".//ArticleTitle") %>% xml2::xml_text()
  abstract     <- xml2::xml_find_first(file, ".//AbstractText") %>% xml2::xml_text() 
  key_words    <- xml2::xml_find_first(file, ".//KeyWordList") %>% xml2::xml_text() 
  journal_id      <- xml2::xml_find_first(file, ".//NlmUniqueID") %>% xml2::xml_text() 
  journal_title      <- xml2::xml_find_first(file, ".//Journal/Title") %>% xml2::xml_text() 
  
  mesh_list    <- xml2::xml_find_first(file, ".//MeshHeadingList") 
  
  mesh_desc_major        <- mesh_list %>%
    xml2::xml_children() %>%
    xml2::xml_find_first(".//DescriptorName[@MajorTopicYN='Y']")
    
  
  
  mesh_desc_nonmajor        <- xml2::xml_find_first(file, ".//AbstractText") %>% xml2::xml_text() 
  mesh_qual_major        <- xml2::xml_find_first(file, ".//AbstractText") %>% xml2::xml_text() 
  mesh_qual_nonmajor        <- xml2::xml_find_first(file, ".//AbstractText") %>% xml2::xml_text() 

  
  try({
    data.frame(id = id,
               title = title, 
               abstract = abstract, 
               key_words = key_words,
               )
    
  })
  
}



# baseline link
# scan page for file links
# paralell download links


############## UPDATES ###############

# baseline link
# scan page for file links
# paralell download links
