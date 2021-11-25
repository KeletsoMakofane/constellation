############## ADMIN ###############
clean.data.directory      <- paste0(root.data.directory, "import/")


###### FUNCTIONS ######
post_search <- function(query){
  search_results_base_link        <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&tool='CollaborationExplorer'&email='kmakofane@g.harvard.edu'&usehistory=y"
  search_results_ret_max          <- "retmax=0"
  search_results_search           <- paste0("term=", str_replace_all(query, " ", "+"))
  search_results_endpoint         <- paste(search_results_base_link, search_results_ret_max, search_results_search, sep = "&")
  
  search_results <- search_results_endpoint %>%
    httr::GET() %>%
    XML::xmlParse() %>%
    XML::xmlToList() %>%
    {.[c("QueryKey", "WebEnv", "Count")]} 
  
  names(search_results) <- c("query_key", "web_env", "count")
  search_results$count <- as.numeric(search_results$count)
  
  search_results
}


fetch_search_chunk <- function(query_list, query_name , chunk_size, ret_start = 0){
  Sys.sleep(0.4)
  fetch_results_base_link        <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&tool='CollaborationExplorer'&email='kmakofane@g.harvard.edu'"
  fetch_results_ret_max          <- paste0("retmax=", chunk_size)
  fetch_results_ret_start        <- paste0("retstart=", ret_start)
  fetch_results_parameters       <- paste0("WebEnv=", query_list$web_env, "&", "query_key=", query_list$query_key)
  fetch_results_endpoint         <- paste(fetch_results_base_link, fetch_results_ret_max, fetch_results_ret_start, fetch_results_parameters, sep = "&")

  ids <- fetch_results_endpoint %>%
    httr::GET() %>%
    xml2::read_xml() %>%
    xml2::xml_find_first("./IdList") %>%
    xml2::xml_children() %>%
    xml2::xml_text()
  
    data.frame(id = paste0("pap_", ids)) %>%
    write_csv(paste0(clean.data.directory, query_name,".csv"), append = TRUE) 
}

fetch_search <- function(query_list, query_name = "racism_ids", chunk_size = 35000){
  nchunks <- ceiling(query_list$count/chunk_size)
  retstart_seq <- seq(from=0, to = query_list$count, by = chunk_size)
  
  if (file.exists(paste0(clean.data.directory, query_name,".csv"))) unlink(paste0(clean.data.directory, query_name,".csv"), recursive = FALSE)
  
  if (nchunks > 0){
    for (i in 1:nchunks){
      fetch_search_chunk(query_list = query_list, query_name = query_name, chunk_size = chunk_size, ret_start = retstart_seq[i])
      cat(paste("downloaded", i, "of", nchunks, "files"))
    }
  }
}


term_racism        <- '("Prejudice"[Mesh:NoExp] OR "Racism"[Mesh] OR racism[tiab] OR racial bias*[tiab] OR racial prejudice*[tiab] OR racial discrimination*[tiab] OR race discrimination*[tiab])'
term_covid         <- '((("Coronavirus"[MeSH] OR "Coronavirus Infections"[Mesh] OR coronavirus[tiab]) AND (novel[tiab] OR wuhan[tiab] OR china[tiab] OR 2019[tiab] OR 19[tiab])) OR "COVID-19"[Mesh] OR "SARS-CoV-2"[Mesh] OR "COVID-19 Testing"[Mesh] OR "COVID-19 Vaccines"[Mesh] OR covid[tiab] OR covid19[tiab] OR 2019nCoV[tiab] OR SARS-CoV-2[tiab] OR SARSCoV2[tiab] OR SARSCoV-2[tiab] OR SARS-CoV2[tiab] OR HCov2[tiab] OR 2019-ncov[tiab] OR COVID-19[tiab] OR coronavirus[tiab])'
term_racism_covid  <- '((("Coronavirus"[MeSH] OR "Coronavirus Infections"[Mesh] OR coronavirus[tiab]) AND (novel[tiab] OR wuhan[tiab] OR china[tiab] OR 2019[tiab] OR 19[tiab])) OR "COVID-19"[Mesh] OR "SARS-CoV-2"[Mesh] OR "COVID-19 Testing"[Mesh] OR "COVID-19 Vaccines"[Mesh] OR covid[tiab] OR covid19[tiab] OR 2019nCoV[tiab] OR SARS-CoV-2[tiab] OR SARSCoV2[tiab] OR SARSCoV-2[tiab] OR SARS-CoV2[tiab] OR HCov2[tiab] OR 2019-ncov[tiab] OR COVID-19[tiab] OR coronavirus[tiab]) AND ("Prejudice"[Mesh:NoExp] OR "Racism"[Mesh] OR racism[tiab] OR racial bias*[tiab] OR racial prejudice*[tiab] OR racial discrimination*[tiab] OR race discrimination*[tiab])'


term_racism %>%
  post_search() %>%
  fetch_search(query_name = "racism_ids")

term_covid %>%
  post_search() %>%
  fetch_search(query_name = "covid_ids")

term_racism_covid %>%
  post_search() %>%
  fetch_search(query_name = "racism_covid_ids")

