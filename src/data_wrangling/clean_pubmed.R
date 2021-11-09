clean.data.directory      <- paste0(root.data.directory, "data_pubmed_clean/")
final.data.directory      <- paste0(root.data.directory, "import/")
filenames                 <- list.files(clean.data.directory)

filenames_authors <- filenames %>%
  {.[str_detect(., "authors_")]} %>%
  paste0(clean.data.directory, .)

filenames_papers <- filenames %>%
  {.[str_detect(., "papers_")]}  %>%
  paste0(clean.data.directory, .)

if (file.exists(paste0(final.data.directory, "authors.csv"))) unlink(paste0(final.data.directory, "authors.csv"), recursive = FALSE)

for (i in seq_along(filenames_authors)){
  try({
    read.csv(filenames_authors[i], header = TRUE) %>%
      write.table(paste0(final.data.directory, "authors.csv"), sep = ",", append = TRUE, col.names=!file.exists(paste0(final.data.directory, "authors.csv")), row.names = FALSE)
  
    print(paste(i, "of", length(filenames_authors), "authors"))
    })
}

if (file.exists(paste0(final.data.directory, "papers.csv"))) unlink(paste0(final.data.directory, "papers.csv"), recursive = FALSE)

for (i in seq_along(filenames_papers)){
  try({
    read.csv(filenames_papers[i], header = TRUE) %>%
      write.table(paste0(final.data.directory, "papers.csv"), sep = ",", append = TRUE, col.names=!file.exists(paste0(final.data.directory, "papers.csv")), row.names = FALSE)
  
    print(paste(i, "of", length(filenames_papers)), "papers")
    })
}