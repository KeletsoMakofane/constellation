clean.data.directory      <- paste0(root.data.directory, "data_pubmed_clean/")
final.data.directory      <- paste0(root.data.directory, "import/")
filenames                 <- list.files(clean.data.directory)

filenames_authors <- filenames %>%
  {.[str_detect(., "author_nodes_")]} %>%
  paste0(clean.data.directory, .)

filenames_papers <- filenames %>%
  {.[str_detect(., "paper_nodes_")]}  %>%
  paste0(clean.data.directory, .)

filenames_author_paper_edges <- filenames %>%
  {.[str_detect(., "author_paper_edges_")]}  %>%
  paste0(clean.data.directory, .)

filenames_citation_edges <- filenames %>%
  {.[str_detect(., "citation_edges")]}  %>%
  paste0(clean.data.directory, .)

# if (file.exists(paste0(final.data.directory, "author_nodes.csv"))) unlink(paste0(final.data.directory, "author_nodes.csv"), recursive = FALSE)
# 
# 
# for (i in seq_along(filenames_authors)){
#   try({
#     a <- read_csv(filenames_authors[i]) %>%
#       dplyr::filter(!is.na(author_name) & author_name != "") %>%
#       dplyr::rename(`name:ID` = author_name) %>%
#       dplyr::mutate(`:LABEL` = "Author") 
#     
#       write_csv(a, paste0(final.data.directory, "author_nodes.csv"), append = (i != 1), col_names=FALSE)
#       write_csv(filter(a, FALSE), paste0(final.data.directory, "author_nodes_headers.csv"), col_names=TRUE)
#       
#       rm(a)
#       
#       print(paste(i, "of", length(filenames_authors), "authors"))
#     })
# }

#if (file.exists(paste0(final.data.directory, "paper_nodes.csv"))) unlink(paste0(final.data.directory, "paper_nodes.csv"), recursive = FALSE)
if (file.exists(paste0(final.data.directory, "paper_nodes_2.csv"))) unlink(paste0(final.data.directory, "paper_nodes_2.csv"), recursive = FALSE)


#for (i in seq_along(filenames_papers)){
for (i in 580:length(filenames_papers)){
  try({
    b <- read_csv(filenames_papers[i]) %>%
      dplyr::mutate(id = as.numeric(id)) %>%
      dplyr::filter(!is.na(id)) %>%
      dplyr::mutate(id = paste0("pap_", id)) %>%
      dplyr::rename(`id:ID` = id, `year:int` = year) %>%
      dplyr::mutate(`:LABEL` = "Paper") 
    
      write_csv(b, paste0(final.data.directory, "paper_nodes_2.csv"), append = (i != 1), col_names=FALSE)
      write_csv(b %>% filter(FALSE), paste0(final.data.directory, "paper_nodes_headers.csv"), col_names=TRUE)
    
      rm(b)
      
    print(paste(i, "of", length(filenames_papers), "papers"))
    })
}

if (file.exists(paste0(final.data.directory, "author_paper_edges.csv"))) unlink(paste0(final.data.directory, "author_paper_edges.csv"), recursive = FALSE)


for (i in seq_along(filenames_author_paper_edges)){
  try({
    b <- read_csv(filenames_author_paper_edges[i]) %>%
      dplyr::mutate(author_pmid = as.numeric(author_pmid), author_name = trimws(as.character(author_name))) %>%
      dplyr::filter(!is.na(author_pmid) & !is.na(author_name) & author_name != "") %>%
      dplyr::mutate(author_pmid = paste0("pap_", author_pmid)) %>%
      dplyr::rename(`:START_ID` = author_name, `:END_ID` = author_pmid) %>%
      dplyr::mutate(`:TYPE` = "WROTE") 
    
    write_csv(b, paste0(final.data.directory, "author_paper_edges.csv"), append = (i != 1), col_names= FALSE)
    write_csv(b %>% filter(FALSE), paste0(final.data.directory, "author_paper_edges_headers.csv"), col_names= TRUE)
    
    rm(b)
    
    print(paste(i, "of", length(filenames_author_paper_edges), "author_paper_edges"))
  })
}

if (file.exists(paste0(final.data.directory, "citation_edges.csv"))) unlink(paste0(final.data.directory, "citation_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_citation_edges)){
  try({
    b <- read_csv(filenames_citation_edges[i]) %>%
      dplyr::mutate(author_pmid_from = as.numeric(author_pmid_from), author_pmid_to = as.numeric(author_pmid_to)) %>%
      dplyr::filter(!is.na(author_pmid_from) & !is.na(author_pmid_to)) %>%
      dplyr::mutate(author_pmid_from = paste0("pap_", author_pmid_from), author_pmid_to = paste0("pap_", author_pmid_to)) %>%
      dplyr::rename(`:START_ID` = author_pmid_from, `:END_ID` = author_pmid_to) %>%
      dplyr::mutate(`:TYPE` = "CITED") 
    
    write_csv(b, paste0(final.data.directory, "citation_edges.csv"), append = (i != 1), col_names=FALSE)
    write_csv(b %>% filter(FALSE), paste0(final.data.directory, "citation_edges_headers.csv"), col_names=TRUE)
    
    rm(b)
    
    print(paste(i, "of", length(filenames_author_paper_edges), "citation_edges.csv"))
  })
}




