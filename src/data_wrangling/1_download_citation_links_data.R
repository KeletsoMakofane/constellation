

############## ADMIN ###############
# open articles data and get pmids
# break pmids up into chunks of 10000




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




fetch_and_clean_batch_pre <- function(i, j){
  Sys.sleep(0.34)
  
  ids <- data.table::fread(paste0(root.data.directory, "import/paper_nodes_", j, ".csv"), skip = (i-1)*2000, nrows = 2000) %>%
    pull(V4) %>%
    str_replace("pap_", "") %>%
    paste0("id=", .) %>%
    paste(., collapse = "&") 
  
  payload  <- paste(base_param, ids)
  response <- httr::POST(base_url, body = payload)
  result   <- response %>%
               xml2::read_xml() %>%
               xml2::xml_find_all(".//LinkSet") 
  
  result %>% lapply(add_destination_to_links)
  
  from    <- xml2::xml_find_all(result, ".//Link/Id") %>% xml2::xml_text()
  to      <- xml2::xml_find_all(result, ".//Link/Id") %>% xml2::xml_attr("destination")
  
  link_table <- data.frame(from = from, to = to)
  write_csv(link_table, paste0(root.data.directory, "data_pubmed_clean/citation_edges_", j, "_", i, ".csv"))

}


fetch_and_clean_batch <- purrr::possibly(fetch_and_clean_batch_pre, otherwise = NULL)




for (j in 1:4){

  system(paste("echo >>", paste0(root.data.directory, "import/paper_nodes_", j, ".csv")))
  total <- R.utils::countLines(paste0(root.data.directory, "import/paper_nodes_", j, ".csv"))
  nbatches <- ceiling(total/2000)
  
  if (j == 1) nbatches <-  712
  
  for (i in 1:nbatches){
    
    fetch_and_clean_batch(i, j)
    
  }
}

#redo 1-35 for j = 1

