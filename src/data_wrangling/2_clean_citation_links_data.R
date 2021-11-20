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


if (file.exists(paste0(final.data.directory, "citation_edges.csv"))) unlink(paste0(final.data.directory, "citation_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_citation_edges)){
  try({
    b <- read_csv(filenames_citation_edges[i]) %>%
      dplyr::filter(!is.na(from) & !is.na(to)) %>%
      dplyr::mutate(author_pmid_from = paste0("pap_", from), author_pmid_to = paste0("pap_", to)) %>%
      dplyr::transmute(`:START_ID` = author_pmid_from, `:END_ID` = author_pmid_to, `:TYPE` = "CITED") 
    
    write_csv(b, paste0(final.data.directory, "citation_edges.csv"), append = (i != 1), col_names=FALSE)
    write_csv(b %>% filter(FALSE), paste0(final.data.directory, "citation_edges_headers.csv"), col_names=TRUE)
    
    rm(b)
    
    print(paste(i, "of", length(filenames_author_paper_edges), "citation_edges.csv"))
  })
}




