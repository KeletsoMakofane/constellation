clean.data.directory      <- paste0(root.data.directory, "data_pubmed_clean/")
final.data.directory      <- paste0(root.data.directory, "import/")
filenames                 <- list.files(clean.data.directory)

filenames_authors <- filenames %>%
  {.[str_detect(., "authors_")]} %>%
  paste0(clean.data.directory, .)

filenames_papers <- filenames %>%
  {.[str_detect(., "papers_")]}  %>%
  paste0(clean.data.directory, .)

filenames_author_paper_edges <- filenames %>%
  {.[str_detect(., "author_paper_edges_")]}  %>%
  paste0(clean.data.directory, .)

if (file.exists(paste0(final.data.directory, "authors.csv"))) unlink(paste0(final.data.directory, "authors.csv"), recursive = FALSE)

for (i in seq_along(filenames_authors)){
  try({
    a <- read_csv(filenames_authors[i]) %>%
      dplyr::mutate(across(everything(), as.character)) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, '"', '|'))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "'", "|"))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, ",", ";"))) %>%
      dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x)))
    
      write_csv(a, paste0(final.data.directory, "authors.csv"), append = TRUE, col_names=!file.exists(paste0(final.data.directory, "authors.csv")))
      
      rm(a)
      
      print(paste(i, "of", length(filenames_authors), "authors"))
    })
}

if (file.exists(paste0(final.data.directory, "papers.csv"))) unlink(paste0(final.data.directory, "papers.csv"), recursive = FALSE)

for (i in seq_along(filenames_papers)){
  try({
    b <- read_csv(filenames_papers[i]) %>%
      dplyr::mutate(across(everything(), as.character)) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, '"', '|'))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "'", "|"))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, ",", ";"))) %>%
      dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x)))
    
      write_csv(b, paste0(final.data.directory, "papers.csv"), append = TRUE, col_names=!file.exists(paste0(final.data.directory, "papers.csv")))
  
      rm(b)
      
    print(paste(i, "of", length(filenames_papers), "papers"))
    })
}

if (file.exists(paste0(final.data.directory, "author_paper_edges.csv"))) unlink(paste0(final.data.directory, "author_paper_edges.csv"), recursive = FALSE)

for (i in seq_along(filenames_author_paper_edges)){
  try({
    b <- read_csv(filenames_author_paper_edges[i]) %>%
      dplyr::mutate(across(everything(), as.character)) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, '"', '|'))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "'", "|"))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, ",", ";"))) %>%
      dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x)))
    
    write_csv(b, paste0(final.data.directory, "author_paper_edges.csv"), append = TRUE, col_names=!file.exists(paste0(final.data.directory, "author_paper_edges.csv")))
    
    rm(b)
    
    print(paste(i, "of", length(filenames_author_paper_edges), "author_paper_edges"))
  })
}




