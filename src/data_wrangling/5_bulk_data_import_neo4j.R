library(neo4jshell)

neo4j_local <- list(address = "neo4j+s://graph.constellationsproject.app", uid = "neo4j", pwd = "academy-recycle-system-valery-newton-357")
cypher_path <- "/opt/homebrew/bin/cypher-shell"


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
            
            
            CREATE FULLTEXT INDEX NameFulltextIndex IF NOT EXISTS
            FOR (n:Author) ON EACH [n.name];
            
            CREATE FULLTEXT INDEX InvestigatorNametextIndex IF NOT EXISTS
            FOR (n:Investigator) ON EACH [n.name];
            
            CREATE FULLTEXT INDEX AbstractSearch IF NOT EXISTS
            FOR (n:Paper) ON EACH [n.abstract];
            
            CREATE  INDEX Title IF NOT EXISTS
            FOR (n:Paper) ON  (n.title);
'



nodes_papers_1        <- "
      using periodic commit 1000 
      LOAD CSV FROM 'file:///paper_nodes_1.csv' as row 
      MERGE (m:Paper {id: row[0]}) 
      ON CREATE SET 
      m.title = row[1], 
      m.abstract = row[2], 
      m.journal_id = row[3], 
      m.journal_title = row[4], 
      m.year = toInteger(row[5]), 
      m.mesh_desc_major = row[6], 
      m.mesh_desc_nonmajor = row[7], 
      m.mesh_qual_major = row[8], 
      m.mesh_qual_nonmajor = row[9];
"

nodes_papers_2        <- "
      using periodic commit 1000 
      LOAD CSV FROM 'file:///paper_nodes_2.csv' as row 
      MERGE (m:Paper {id: row[0]}) 
      ON CREATE SET 
      m.title = row[1], 
      m.abstract = row[2], 
      m.journal_id = row[3], 
      m.journal_title = row[4], 
      m.year = toInteger(row[5]), 
      m.mesh_desc_major = row[6], 
      m.mesh_desc_nonmajor = row[7], 
      m.mesh_qual_major = row[8], 
      m.mesh_qual_nonmajor = row[9];
"

nodes_papers_3        <- "
      using periodic commit 1000 
      LOAD CSV FROM 'file:///paper_nodes_3.csv' as row 
      MERGE (m:Paper {id: row[0]}) 
      ON CREATE SET 
      m.title = row[1], 
      m.abstract = row[2], 
      m.journal_id = row[3], 
      m.journal_title = row[4], 
      m.year = toInteger(row[5]), 
      m.mesh_desc_major = row[6], 
      m.mesh_desc_nonmajor = row[7], 
      m.mesh_qual_major = row[8], 
      m.mesh_qual_nonmajor = row[9];
"

nodes_papers_4        <- "
      using periodic commit 1000 
      LOAD CSV FROM 'file:///paper_nodes_4.csv' as row 
      MERGE (m:Paper {id: row[0]}) 
      ON CREATE SET 
      m.title = row[1], 
      m.abstract = row[2], 
      m.journal_id = row[3], 
      m.journal_title = row[4], 
      m.year = toInteger(row[5]), 
      m.mesh_desc_major = row[6], 
      m.mesh_desc_nonmajor = row[7], 
      m.mesh_qual_major = row[8], 
      m.mesh_qual_nonmajor = row[9];
"


nodes_authors       <- "
      using periodic commit 1000 
      LOAD CSV FROM 'file:///authors.csv' as row 
      MERGE (a:Author {name: row[0]});
"

nodes_projects      <- "
      using periodic commit 1000 LOAD CSV FROM 'file:///project_nodes.csv' as row 
      MERGE (m:Project {id : row[0]})
      ON CREATE SET
      m.title = row[1], 
      m.year = toInteger(row[2]), 
      m.indirect_cost = toInteger(row[3]), 
      m.direct_cost = toInteger(row[4]), 
      m.total_cost = toInteger(row[5]), 
      m.total_cost_subproject = toInteger(row[6])
"

nodes_organizations <- "
      using periodic commit 1000 
      LOAD CSV FROM 'file:///organization_nodes.csv' as row 
      MERGE (m:Organization {id: row[0]})
      ON CREATE SET
      m.name = row[1], 
      m.city = row[2];
"


nodes_investigators <- "
      using periodic commit 1000 
      LOAD CSV FROM 'file:///investigator_nodes.csv' as row 
      MERGE (m:Investigator {id: row[0]}) 
      ON CREATE SET 
      m.name = row[1];
"


edges_author_paper          <- "
      using periodic commit 1000 
      LOAD CSV FROM 'file:///author_paper_edges.csv' as row 
      MATCH (author:Author) WHERE author.name = row[4] 
      MATCH (paper:Paper) WHERE paper.id = row[3]  
      MERGE (author)-[:WROTE]->(paper);
"

edges_investigator_project  <- "
      using periodic commit 1000 
      LOAD CSV FROM 'file:///investigator_project_edges.csv' as row 
      MATCH (i:Investigator) WHERE i.id = row[0] 
      MATCH (p:Project) WHERE p.id = row[1] 
      MERGE (i)-[:LED]->(p);
"

edges_organization_project  <- "
      using periodic commit 1000 
      LOAD CSV FROM 'file:///organization_project_edges.csv' as row 
      MATCH (o:Organization) WHERE o.id = row[0] 
      MATCH (p:Project) WHERE p.id = row[1] 
      MERGE (o)-[:HOSTED]->(p);
"


edges_project_paper_edges   <- "
    LOAD CSV FROM 'file:///project_paper_edges.csv' as row 
    MATCH (p:Paper) WHERE p.id = 'pap_' + row[0]
    MATCH (q:Project) WHERE q.id = row[1] + '_' + p.year + '_0' 
    MERGE (q)-[:SUPPORTED]->(p);
"

edges_project_subproject    <- "
    using periodic commit 1000 
    LOAD CSV FROM 'file:///project_subproject_edges.csv' as row 
    MATCH (o:Project) WHERE o.id = row[1] 
    MATCH (p:Project ) WHERE p.id = row[0] 
    MERGE (o)-[:BEGAT]->(p);
"

edges_citation              <- "
    using periodic commit 1000 
    LOAD CSV FROM 'file:///citation_edges.csv' as row 
    MATCH (from:Paper {id: row[1]}) 
    MATCH (to:Paper {id: row[0]}) 
    MERGE (from)-[:CITED]->(to);
"


racism_index <- "
    using periodic commit 1000 
    LOAD CSV FROM 'file:///racism_ids.csv' as row 
    MATCH (p:Paper {id: row[0]})
    SET p.racism = true;
"

covid_index <- "
    using periodic commit 1000 
    LOAD CSV FROM 'file:///covid_ids.csv' as row 
    MATCH (p:Paper {id: row[0]})
    SET p.covid = true;
"

racism_covid_index <- "
    using periodic commit 1000 
    LOAD CSV FROM 'file:///racism_covid_ids.csv' as row 
    MATCH (p:Paper {id: row[0]})
    SET p.racism_covid = true;
"


try({neo4j_query(con = neo4j_local, qry = indexes , shell_path = cypher_path)})

try({neo4j_query(con = neo4j_local, qry = nodes_papers_1         , shell_path = cypher_path)})
try({neo4j_query(con = neo4j_local, qry = nodes_papers_2         , shell_path = cypher_path)})
try({neo4j_query(con = neo4j_local, qry = nodes_papers_3         , shell_path = cypher_path)})
try({neo4j_query(con = neo4j_local, qry = nodes_papers_4         , shell_path = cypher_path)})
try({neo4j_query(con = neo4j_local, qry = nodes_authors          , shell_path = cypher_path)})
try({neo4j_query(con = neo4j_local, qry = nodes_projects         , shell_path = cypher_path)})

try({neo4j_query(con = neo4j_local, qry = nodes_organizations    , shell_path = cypher_path)})
try({neo4j_query(con = neo4j_local, qry = nodes_investigators    , shell_path = cypher_path)})

try({neo4j_query(con = neo4j_local, qry = edges_author_paper         , shell_path = cypher_path)})
try({neo4j_query(con = neo4j_local, qry = edges_investigator_project , shell_path = cypher_path)})
try({neo4j_query(con = neo4j_local, qry = edges_organization_project , shell_path = cypher_path)})
try({neo4j_query(con = neo4j_local, qry = edges_project_paper_edges  , shell_path = cypher_path)})
try({neo4j_query(con = neo4j_local, qry = edges_project_subproject   , shell_path = cypher_path)})
try({neo4j_query(con = neo4j_local, qry = edges_citation             , shell_path = cypher_path)})

try({neo4j_query(con = neo4j_local, qry = racism_index               , shell_path = cypher_path)})
try({neo4j_query(con = neo4j_local, qry = covid_index                , shell_path = cypher_path)})
try({neo4j_query(con = neo4j_local, qry = racism_covid_index         , shell_path = cypher_path)})


