library(tidyverse)
library(neo4jshell)


cat("downloading updates\n")
system('esearch -db pubmed -query " " -datetype EDAT -days 1 | efetch -format xml | xtract -pattern PubmedArticle -tab "|" -def "N/A"  -sep  "@@@" -element MedlineCitation/PMID  PubDate/Year PubDate/MedlineDate  ForeName LastName Initials ArticleTitle Title MedlineTA > article_data.txt')
system('esearch -db pubmed -query " " -datetype EDAT -days 1 | elink -format xml -cmd neighbor -related | xtract  -pattern LinkSet -tab "|" -sep "@@@" -element IdList/Id Link/Id > links.txt')
cat("finished downloading\n")

unlink('import', recursive = TRUE)
dir.create('import')

data_papers          <- data.table::fread("article_data.txt", sep = "|") %>%
                        dplyr::rename(id = 1, year = 2, year2 = 3, forename = 4, lastname = 5, initials = 6, title = 7, journal_title = 8, journal_abbr = 9) 

nrows <- dim(data_papers)[1]

unlink("authors_pre.csv")

for (i in 1:nrows){
  cbind(data_papers$id[i], data_papers$year[i], data_papers$year2[i], data_papers$title[i], data_papers$journal_title[i], data_papers$journal_abbr[i], unlist(str_split(data_papers$forename[i], "@@@")), unlist(str_split(data_papers$lastname[i], "@@@")), unlist(str_split(data_papers$initials[i], "@@@"))) %>% 
    data.frame() %>%
    dplyr::rename(id = 1, year = 2, year2 = 3, title = 4, journal_title = 5, journal_abbr = 6, firstname = 7, lastname = 8, initials = 9) %>%
    dplyr::mutate(name = paste(firstname, lastname),
                  id = paste0("pap_", id)) %>%
  write_csv("authors_pre.csv", append = TRUE, col_names = i == 1)
}

data_papers_clean <- data.table::fread("authors_pre.csv")

author_nodes        <- data_papers_clean[, .(firstname = first(firstname), lastname = first(lastname)), by=list(name)]
paper_nodes         <- data_papers_clean[, .(year = first(year), year2 = first(year2), title = first(title), journal_title = first(journal_title), journal_abbr = first(journal_abbr)), by = .(id)]
author_paper_edges  <- data_papers_clean %>% select(name, id)

write_csv(author_nodes,        "import/author_nodes.csv",       col_names = FALSE)
write_csv(paper_nodes,         "import/paper_nodes.csv",        col_names = FALSE)
write_csv(author_paper_edges,  "import/author_paper_edges.csv", col_names = FALSE)
unlink("authors_pre.csv")


rm(author_nodes)
rm(paper_nodes)
rm(data_papers)
rm(data_papers_clean)


data_links          <- data.table::fread("links.txt", sep = "|") %>%
                        dplyr::rename(to = 1, from = 2)

nrows <- dim(data_links)[1]

unlink("citation_edges.csv")

for (i in 1:nrows){
  cbind(data_links$to[i], unlist(str_split(data_links$from[i], "@@"))) %>% 
    data.frame() %>%
    dplyr::rename(to = 1, from = 2) %>%
    dplyr::mutate(to = paste0("pap_", to), from = paste0("pap_", from)) %>%
    write_csv("import/citation_edges.csv", append = TRUE, col_names = FALSE)
}

rm(data_links)

system("sudo rm -r /var/lib/neo4j/import")
system("sudo cp -r ~/import /var/lib/neo4j/")


neo4j_local <- list(address = "neo4j+s://graph.constellationsproject.app", uid = "neo4j", pwd = "academy-recycle-system-valery-newton-357")
cypher_path <- "cypher-shell"


indexes <- '
            CREATE CONSTRAINT UniquePaperIdConstraint IF NOT EXISTS
            ON (p:Paper)
            ASSERT p.id IS UNIQUE;
            
            CREATE CONSTRAINT UniqueAuthorIdConstraint IF NOT EXISTS
            ON (a:Author)
            ASSERT a.name IS UNIQUE;
            
            CREATE CONSTRAINT UniqueInvestigatorIdConstraint IF NOT EXISTS
            ON (a:Investigator)
            ASSERT a.id IS UNIQUE;
            
            CREATE CONSTRAINT UniqueProjectIdConstraint IF NOT EXISTS
            ON (a:Project)
            ASSERT a.id IS UNIQUE;
            
            CREATE CONSTRAINT UniqueOrganizationIdConstraint IF NOT EXISTS
            ON (a:Organization)
            ASSERT a.id IS UNIQUE;
            
            CREATE INDEX year_index IF NOT EXISTS
            FOR (p:Paper)
            ON (p.year);
            
            CREATE INDEX project_key_index IF NOT EXISTS
            FOR (p:Paper)
            ON (p.project_key);
            
            CREATE INDEX direct_cost_index IF NOT EXISTS
            FOR (p:Project)
            ON (p.direct_cost);
            
            CREATE INDEX indirect_cost_index IF NOT EXISTS
            FOR (p:Project)
            ON (p.indirect_cost);
            
            CREATE INDEX total_cost_index IF NOT EXISTS
            FOR (p:Project)
            ON (p.total_cost);
            
            CREATE INDEX total_cost_subproject_index IF NOT EXISTS
            FOR (p:Project)
            ON (p.total_cost_subproject);
            
            CREATE INDEX journal_title__index IF NOT EXISTS
            FOR (p:Project)
            ON (p.journal_title);
            
            CREATE INDEX organization_name_index IF NOT EXISTS
            FOR (o:Organization)
            ON (o.name);
            
            CREATE INDEX investigator_name_index IF NOT EXISTS
            FOR (i:Investigator)
            ON (i.name);
            
            CREATE INDEX racism_index IF NOT EXISTS
            FOR (p:Paper)
            ON (p.racism);
            
            CREATE INDEX covid_index IF NOT EXISTS
            FOR (p:Paper)
            ON (p.covid);
            
            CREATE INDEX racism_covid_index IF NOT EXISTS
            FOR (p:Paper)
            ON (p.racism_covid);
            
            CREATE INDEX references_key_index IF NOT EXISTS
            FOR (p:Paper)
            ON (p.references)
            
            
            CREATE FULLTEXT INDEX NameFulltextIndex IF NOT EXISTS
            FOR (n:Author) ON EACH [n.name];
            
            CREATE FULLTEXT INDEX InvestigatorNametextIndex IF NOT EXISTS
            FOR (n:Investigator) ON EACH [n.name];

            CREATE FULLTEXT INDEX OrganizationNametextIndex IF NOT EXISTS
            FOR (n:Organization) ON EACH [n.name];
            
            
            CREATE  INDEX Title IF NOT EXISTS
            FOR (n:Paper) ON  (n.title);
'



nodes_papers        <- "
      using periodic commit 1000 
      LOAD CSV FROM 'file:///paper_nodes.csv' as row 
      MERGE (m:Paper {id: row[0]}) 
      ON CREATE SET 
      m.title = row[3], 
      m.journal_id = row[5], 
      m.journal_title = row[4], 
      m.year = toInteger(row[1]);
"


nodes_authors       <- "
      using periodic commit 1000 
      LOAD CSV FROM 'file:///author_nodes.csv' as row 
      MERGE (a:Author {name: row[0]});
"



edges_author_paper          <- "
      using periodic commit 1000 
      LOAD CSV FROM 'file:///author_paper_edges.csv' as row 
      MATCH (author:Author) WHERE author.name = row[0] 
      MATCH (paper:Paper) WHERE paper.id = row[1]  
      MERGE (author)-[:WROTE]->(paper);
"


edges_citation              <- "
    using periodic commit 1000 
    LOAD CSV FROM 'file:///citation_edges.csv' as row 
    MATCH (from:Paper {id: row[1]}) 
    MATCH (to:Paper {id: row[0]}) 
    MERGE (from)-[:CITED]->(to);
"

system('sudo rm -r /var/lib/neo4j/import')
system('sudo cp -r ~/auto_update_pubmed/import /var/lib/neo4j/')

cat("starting cypher\n")

try({neo4j_query(con = neo4j_local, qry = indexes , shell_path = cypher_path)})

cat("done: indexes\n")

try({neo4j_query(con = neo4j_local, qry = nodes_papers , shell_path = cypher_path)})

cat("done: papers\n")

try({neo4j_query(con = neo4j_local, qry = nodes_authors , shell_path = cypher_path)})

cat("done: authors\n")

try({neo4j_query(con = neo4j_local, qry = edges_author_paper , shell_path = cypher_path)})

cat("done: author-paper-edges\n")

try({neo4j_query(con = neo4j_local, qry = edges_citation , shell_path = cypher_path)})

cat("done: paper-paper-edges\n")

cat("finished cypher")
