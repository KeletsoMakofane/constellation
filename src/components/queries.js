import {TopicRestriction} from "@components";


const CypherQuery = (searchname, collabweight, startYear, stopYear, topicChosen, view) => {


            switch (view) {
                case "collaboration_net":
                    return  (   `MATCH (:Author {name: '${searchname}'})-[:WROTE]-(p)
                                MATCH (a:Author)-[:WROTE]-(p:Paper)-[:WROTE]-(b:Author)
                                WHERE toInteger(${startYear}) <= p.year <= toInteger(${stopYear}) AND ${TopicRestriction(topicChosen)}
                                WITH a, b, collect(p.title) as titles, count(p.title) as collaborations
                                WHERE collaborations >= ${collabweight} and a.name < b.name 
                                CALL apoc.create.vRelationship(a, 'CO_AUTH', {Collaborations: toInteger(collaborations), Titles:titles}, b) YIELD rel
                                RETURN a, b, rel;`)

                case "funding_net":
                    return  (       `MATCH (:Investigator {name: '${searchname}'})-[:LED]-(:Project)-[:SUPPORTED]-(p)
                                    WHERE toInteger(${startYear}) <= p.year <= toInteger(${stopYear}) AND ${TopicRestriction(topicChosen)} 
                                    MATCH (investigators :Investigator)-[:LED]-(projects :Project)-[:SUPPORTED]-(p)
                                    WITH distinct investigators.name as nodes, count(p) as weight, sum(projects.total_cost) as funding
                                    WITH nodes, weight, funding
                                    WHERE weight >= ${collabweight}
                                    WITH apoc.create.vNode(['vInvestigator'], {name: nodes, weight: weight, Funding: funding}) as prenewNodes
                                    WITH apoc.map.groupBy(collect(prenewNodes),'name') as newNodes
                                    MATCH (:Investigator {name: '${searchname}'})-[:LED]-(:Project)-[:SUPPORTED]-(paper)
                                    MATCH (a :Investigator)-[:LED]-(:Project)-[:SUPPORTED]-(paper)-[:SUPPORTED]-(:Project)-[:LED]-(b:Investigator)
                                    WHERE a.name > b.name AND a.name IN keys(newNodes) AND b.name IN keys(newNodes)
                                    WITH a, b, count(paper) as weight, newNodes
                                    WHERE weight >= ${collabweight}
                                    RETURN newNodes[a.name], newNodes[b.name], apoc.create.vRelationship(newNodes[a.name], 'CO_PI', {weight: toInteger(weight)}, newNodes[b.name]);`)

                case "org_net":
                    return  (       `MATCH (:Organization {name: '${searchname}'})-[:HOSTED]-(:Project)-[:SUPPORTED]-(p)
                                    WHERE toInteger(${startYear}) <= p.year <= toInteger(${stopYear}) AND ${TopicRestriction(topicChosen)} 
                                    MATCH (organizations :Organization)-[:HOSTED]-(projects :Project)-[:SUPPORTED]-(p)
                                    WITH distinct organizations.name as nodes, count(p) as weight, sum(projects.total_cost) as funding, organizations.city as city
                                    WITH nodes, weight, funding, city
                                    WHERE weight >= ${collabweight}
                                    WITH apoc.create.vNode(['vOrganization'], {name: nodes, city: city, weight: weight, avgfunding: funding}) as prenewNodes
                                    WITH apoc.map.groupBy(collect(prenewNodes),'name') as newNodes
                                    MATCH (:Organization {name: '${searchname}'})-[:HOSTED]-(:Project)-[:SUPPORTED]-(paper)
                                    MATCH (a :Organization)-[:HOSTED]-(:Project)-[:SUPPORTED]-(paper)-[:SUPPORTED]-(:Project)-[:HOSTED]-(b:Organization)
                                    WHERE a.name > b.name AND a.name IN keys(newNodes) AND b.name IN keys(newNodes)
                                    WITH a, b, count(paper) as weight, newNodes
                                    WHERE weight >= ${collabweight}
                                    RETURN newNodes[a.name], newNodes[b.name], apoc.create.vRelationship(newNodes[a.name], 'CO_HOST', {weight: toInteger(weight)}, newNodes[b.name]);`)

                                case "org_net_large":
                    return  (       `MATCH (org:Organization)-[:HOSTED]-(proj:Project)
                                        WHERE toInteger(${startYear}) <= proj.year <= toInteger(${stopYear})
                                        WITH distinct org.name as Organization, sum(proj.indirect_cost) as Funding ORDER BY Funding DESC LIMIT 100
                                        WITH apoc.create.vNode(['vOrganization'], {Name: Organization, Funding: Funding}) as prenewNodes    
                                        WITH apoc.map.groupBy(collect(prenewNodes),'Name') as newNodes
                                        MATCH (a :Organization)-[:HOSTED]-(:Project)-[:SUPPORTED]-(paper)-[:SUPPORTED]-(:Project)-[:HOSTED]-(b:Organization)
                                        WHERE a.name > b.name AND a.name IN keys(newNodes) AND b.name IN keys(newNodes)
                                        WITH a, b, count(paper) as weight, newNodes
                                        WHERE weight >= ${collabweight}
                                        RETURN newNodes[a.name], newNodes[b.name], apoc.create.vRelationship(newNodes[a.name], 'CO_HOST', {weight: toInteger(weight)}, newNodes[b.name]);`)
            }
}

const CypherAutoCNames = (view) => {
                switch (view) {
                    case "collaboration_net":
                        return (`CALL db.index.fulltext.queryNodes("NameFulltextIndex", $searchName) YIELD node, score RETURN node.name as name LIMIT 5`);

                    case "funding_net":
                        return (`CALL db.index.fulltext.queryNodes("InvestigatorNametextIndex", $searchName) YIELD node, score RETURN node.name as name LIMIT 5`);

                    case "org_net":
                        return (`CALL db.index.fulltext.queryNodes("OrganizationNametextIndex", $searchName) YIELD node, score RETURN node.name as name LIMIT 5`);

                        case "org_net_large":
                        return (`CALL db.index.fulltext.queryNodes("OrganizationNametextIndex", $searchName) YIELD node, score RETURN node.name as name LIMIT 5`);


                }

}

const CypherLabels = (view) => {

    switch (view) {
        case "collaboration_net":
            return ({
                    "Author": {
                        caption: "name",
                        size: "auth_pagerank",
                        community: 'community',
                        title_properties: ["name"],
                        shape: "diamond",
                        font: {
                            color: "blue",
                            size: 11,
                            background: "black"
                        }
                    }
                })

        case "funding_net":
            return ({
                    "vInvestigator": {
                        caption: "name",
                        size: "Funding",
                        community: 'community',
                        title_properties: ["name", "Funding"],
                        shape: "diamond",
                        font: {
                            color: "blue",
                            size: 11,
                            background: "black"
                        }
                    }
                })

        case "org_net":
            return ({
                    "vOrganization": {
                        caption: "name",
                        size: "avgfunding",
                        community: "city",
                        title_properties: ["name", "city", "avgfunding"],
                        shape: "diamond",
                        font: {
                            color: "blue",
                            size: 11,
                            background: "black"
                        }
                    }
                })


        case "org_net_large":
            return ({
                    "vOrganization": {
                        caption: "Name",
                        size: "Funding",
                        title_properties: ["Name", "Funding"],
                        shape: "diamond",
                        font: {
                            color: "blue",
                            size: 11,
                            background: "black"
                        }
                    }
                })
    }
}

const CypherRelationships = (view) => {

    switch (view) {
        case "collaboration_net":
            return ({
                    "CO_AUTH": {
                        caption: false,
                        thickness: 'Collaborations',
                    }
                })

        case "funding_net":
            return ({
                    "CO_PI": {
                        caption: false,
                        thickness: 'weight',
                    }
                })

        case "org_net":
            return ({
                    "CO_HOST": {
                        caption: false,
                        thickness: 'weight',
                    }
                })

        case "org_net_large":
            return ({
                    "CO_HOST": {
                        caption: false,
                        thickness: 'weight',
                    }
                })
    }
}

export {CypherQuery, CypherAutoCNames, CypherLabels, CypherRelationships};