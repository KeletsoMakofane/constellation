library(neo4jshell)

neo4j_local <- list(address = "neo4j+s://graph.constellationsproject.app", uid = "neo4j", pwd = "academy-recycle-system-valery-newton-357")
cypher_path <- "/opt/homebrew/bin/cypher-shell"


make_projection <- "CALL gds.graph.create(
          'test_projection',
          ['*'],
          {
            WROTE:{orientation: 'UNDIRECTED'},
            SUPPORTED:{orientation: 'UNDIRECTED'},
            HOSTED:{orientation: 'UNDIRECTED'},
            LED:{orientation: 'UNDIRECTED'}
          }
        ) YIELD nodeCount, relationshipCount, createMillis"

neo4j_query(con = neo4j_local, qry = make_projection , shell_path = cypher_path)

get_embedding <- "
CALL gds.fastRP.write(
        'test_projection',
        {
          embeddingDimension: 120,
          iterationWeights: [0, 1.0, 1.0],
          normalizationStrength: 0.0,
          randomSeed: 7474,
          writeProperty: 'embedding'
        }
      )
"

neo4j_query(con = neo4j_local, qry = get_embedding , shell_path = cypher_path)

                      