library(tidyverse)

system('esearch -db pubmed -query "Keletso Makofane" | efetch -format xml | xtract -pattern PubmedArticle -tab "|" -def "N/A"  -sep  "@@" -element MedlineCitation/PMID  PubDate/Year PubDate/MedlineDate  ForeName LastName Initials ArticleTitle Title MedlineTA AbstractText > article_data.txt')
system('esearch -db pubmed -query "Keletso Makofane" | elink -format xml -cmd neighbor -related | xtract  -pattern LinkSet -tab "|" -sep "@@" -element IdList/Id Link/Id > links.txt')

unlink('import', recursive = TRUE)
dir.create('import')

data_papers          <- data.table::fread("article_data.txt", sep = "|") %>%
                        dplyr::rename(id = 1, year = 2, year2 = 3, forename = 4, lastname = 5, initials = 6, title = 7, journal_title = 8, journal_abbr = 9, abstract = 10) 

nrows <- dim(data_papers)[1]

unlink("authors_pre.csv")

for (i in 1:nrows){
  cbind(data_papers$id[i], data_papers$year[i], data_papers$year2[i], data_papers$title[i], data_papers$journal_title[i], data_papers$journal_abbr[i], unlist(str_split(data_papers$forename[i], "@@")), unlist(str_split(data_papers$lastname[i], "@@")), unlist(str_split(data_papers$initials[i], "@@")), data_papers$abstract[i]) %>% 
    data.frame() %>%
    dplyr::rename(id = 1, year = 2, year2 = 3, title = 4, journal_title = 5, journal_abbr = 6, firstname = 7, lastname = 8, initials = 9, abstract = 10) %>%
    dplyr::mutate(name = paste(firstname, lastname)) %>%
  write_csv("authors_pre.csv", append = TRUE, col_names = i == 1)
}

data_papers_clean <- data.table::fread("authors_pre.csv")

author_nodes <- data_papers_clean[, .(firstname = first(firstname), lastname = first(lastname)), by=list(name)]
paper_nodes  <- data_papers_clean[, .(year = first(year), year2 = first(year2), title = first(title), journal_title = first(journal_title), journal_abbr = first(journal_abbr), abstract = first(abstract)), by = .(id)]

write_csv(author_nodes, "import/authors_nodes.csv", col_names = FALSE)
write_csv(paper_nodes,  "import/paper_nodes.csv", col_names = FALSE)
unlink("authors_pre.csv")

rm(author_nodes)
rm(paper_nodes)
rm(data_papers)
rm(data_papers_clean)


data_links          <- data.table::fread("links.txt", sep = "|") %>%
                        dplyr::rename(to = 1, from = 2)

nrows <- dim(data_links)[1]

unlink("author_paper_edges.csv")

for (i in 1:nrows){
  cbind(data_links$to[i], unlist(str_split(data_links$from[i], "@@"))) %>% 
    data.frame() %>%
    write_csv("import/author_paper_edges.csv", append = TRUE, col_names = FALSE)
}

rm(data_links)

system("sudo cp -r ~/import /var/lib/neo4j/")
