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

filenames_citation_edges <- filenames %>%
  {.[str_detect(., "citation_edges_")]}  %>%
  paste0(clean.data.directory, .)

if (file.exists(paste0(final.data.directory, "authors.csv"))) unlink(paste0(final.data.directory, "authors.csv"), recursive = FALSE)

#movieId:ID,title,year:int,:LABEL

for (i in seq_along(filenames_authors)){
  try({
    a <- read_csv(filenames_authors[i]) %>%
      dplyr::mutate(across(everything(), as.character)) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, '"', '|'))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "'", "|"))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, ",", ";"))) %>%
      dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x))) %>%
      dplyr::mutate(name_author = trimws(name_author)) %>%
      dplyr::group_by(name_author) %>%
      dplyr::summarize(across(everything(), first)) %>%
      dplyr::filter(!is.na(name_author) & name_author != "") %>%
      dplyr::rename(`name:ID` = name_author) %>%
      dplyr::mutate(`:LABEL` = "Author") %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "[:blank:]"," "))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "[:space:]"," ")))
    
      write_csv(a, paste0(final.data.directory, "authors.csv"), append = (i != 1), col_names=FALSE)
      write_csv(filter(a, FALSE), paste0(final.data.directory, "authors_headers.csv"), col_names=TRUE)
      
      rm(a)
      
      print(paste(i, "of", length(filenames_authors), "authors"))
    })
}

if (file.exists(paste0(final.data.directory, "papers.csv"))) unlink(paste0(final.data.directory, "papers.csv"), recursive = FALSE)
#counter <- 0
for (i in seq_along(filenames_papers)){
  #counter <- (i %% 20) + 1
  #counter <- 0
  
  
  try({
    b <- read_csv(filenames_papers[i]) %>%
      dplyr::mutate(across(everything(), as.character)) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, '"', '|'))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "'", "|"))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, ",", ";"))) %>%
      dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x))) %>%
      dplyr::mutate(id = as.numeric(id)) %>%
      dplyr::mutate(id = paste0("pap_", id)) %>%
      dplyr::filter(!is.na(id)) %>%
      dplyr::rename(`id:ID` = id, `year:int` = year) %>%
      dplyr::mutate(`:LABEL` = "Paper") %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "[:blank:]"," "))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "[:space:]"," ")))
    
      #write_csv(b, paste0(final.data.directory, "papers_", counter, ".csv"), append = (i != 1), col_names=!file.exists(paste0(final.data.directory, "papers_", counter, ".csv")))
      write_csv(b, paste0(final.data.directory, "papers.csv"), append = (i != 1), col_names=FALSE)
      write_csv(b %>% filter(FALSE), paste0(final.data.directory, "papers_headers.csv"), col_names=TRUE)
    
      rm(b)
      
    print(paste(i, "of", length(filenames_papers), "papers"))
    })
}

if (file.exists(paste0(final.data.directory, "author_paper_edges.csv"))) unlink(paste0(final.data.directory, "author_paper_edges.csv"), recursive = FALSE)

#:START_ID,role,:END_ID,:TYPE

for (i in seq_along(filenames_author_paper_edges)){
  try({
    b <- read_csv(filenames_author_paper_edges[i]) %>%
      dplyr::mutate(across(everything(), as.character)) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, '"', '|'))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "'", "|"))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, ",", ";"))) %>%
      dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x))) %>%
      dplyr::mutate(id_paper = as.numeric(id_paper), name_author = trimws(as.character(name_author))) %>%
      dplyr::mutate(id_paper = paste0("pap_", id_paper)) %>%
      dplyr::filter(!is.na(id_paper) & !is.na(name_author) & name_author != "") %>%
      dplyr::rename(`:START_ID` = name_author, `:END_ID` = id_paper) %>%
      dplyr::mutate(`:TYPE` = "WROTE") %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "[:blank:]"," "))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "[:space:]"," ")))
    
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
      dplyr::mutate(across(everything(), as.character)) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, '"', '|'))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "'", "|"))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, ",", ";"))) %>%
      dplyr::mutate(across(everything(), function(x) ifelse(is.na(x), "", x))) %>%
      dplyr::transmute(id_paper_from = from, id_paper_to = to) %>%
      dplyr::mutate(id_paper_from = as.numeric(id_paper_from), id_paper_to = as.numeric(id_paper_to)) %>%
      dplyr::mutate(id_paper_from = paste0("pap_", id_paper_from), id_paper_to = paste0("pap_", id_paper_to)) %>%
      dplyr::filter(!is.na(id_paper_from) & !is.na(id_paper_to)) %>%
      dplyr::rename(`:START_ID` = id_paper_from, `:END_ID` = id_paper_to) %>%
      dplyr::mutate(`:TYPE` = "CITED") %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "[:blank:]"," "))) %>%
      dplyr::mutate(across(everything(), function(x) str_replace_all(x, "[:space:]"," ")))
    
    write_csv(b, paste0(final.data.directory, "citation_edges.csv"), append = (i != 1), col_names=FALSE)
    write_csv(b %>% filter(FALSE), paste0(final.data.directory, "citation_edges_headers.csv"), col_names=TRUE)
    
    rm(b)
    
    print(paste(i, "of", length(filenames_author_paper_edges), "author_paper_edges"))
  })
}




