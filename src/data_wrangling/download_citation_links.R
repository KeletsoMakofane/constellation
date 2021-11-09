

############## ADMIN ###############
# open articles data and get pmids
# break pmids up into chunks of 10000



filenames <- list.files(paste0(root.data.directory, "data_pubmed_clean/")) %>%
  {.[str_detect(., "articles_")]} %>%
  paste0(root.data.directory, "data_pubmed_clean/", .)


pmid_list <- list()
  
for (i in seq_along(filenames)) {
  pmid_list[[i]] <- read.csv(filenames[i]) %>%
    dplyr::pull(id_paper)
}

pmid_list_chunks_pre <- list()

for (i in seq_along(pmid_list)){
  pmid_list_chunks_pre[[i]] <- split(pmid_list[[i]], ceiling(seq_along(pmid_list[[i]])/1000))
}
  
pmid_list_chunks <- unlist(pmid_list_chunks_pre, recursive=FALSE)

############### PREPARE ENDPOINTS ###############
base_url          <-  "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi"
base_param        <-  "dbfrom=pubmed&db=pubmed&linkname=pubmed_pubmed_citedin&tool='CollaborationExplorer'&email='kmakofane@g.harvard.edu'&retmax=10000000000"




############### POST ###############
# iterate over chunks of pmids
  # create an enpoint
  # post a query to history server
  # get back total number of results
  # create a set of indices for iterated download

  # Iterate over nidices
    # get back all entries for that query
    # clean data
    # save csv


add_destination_to_links <- function(node) {
  destination <- node %>%
    xml2::xml_find_first(".//IdList/Id") %>%
    xml2::xml_text()
  
   node %>%
    xml2::xml_children() %>%
    xml2::xml_children() %>%
    xml2::xml_children() %>%
    xml2::xml_set_attr(., "destination", destination)
   
   return(NULL)
  
}



for (i in seq_along(pmid_list_chunks)){
  Sys.sleep(0.34)
  print(Sys.time())
  
  ids <- pmid_list_chunks[[i]] %>%
    paste0("id=", .) %>%
    paste(., collapse = "&") 
  
  payload <- paste(base_param, ids)
  
  response <- httr::POST(base_url, body = payload)
  
  result <-   response %>%
    xml2::read_xml() %>%
    xml2::xml_find_all(".//LinkSet") 
  
  result %>% lapply(add_destination_to_links)
  
  
  
  from    <- xml2::xml_find_all(result, ".//Link/Id") %>% xml2::xml_text()
  to      <- xml2::xml_find_all(result, ".//Link/Id") %>% xml2::xml_attr("destination")
  
  try({link_table <- data.frame(from = from, to = to)
  write.csv(link_table, paste0(root.data.directory, "data_pubmed_clean/citation_edges_", i, ".csv"))
  print(paste(i, "out of", length(pmid_list_chunks)))})
}
