import React, { useEffect, useRef } from "react";
import useResizeAware from "react-resize-aware";
import PropTypes from "prop-types";
import Neovis from "neovis.js/dist/neovis.js";
import { TopicRestriction } from "@components";


    const NeoGraph = (props) => {
        const {
            containerId,
            backgroundColor,
            neo4jUri,
            neo4jUser,
            neo4jPassword,
            searchname,
            collabweight,
            startYear,
            stopYear,
            topicChosen,
            encryptionStatus,
            neovisProtocol,
        } = props;


        const urlWithProtocol = neovisProtocol + neo4jUri
        const visRef = useRef();

        useEffect(() => {

            const enc = encryptionStatus ? "ENCRYPTION_ON" : "ENCRYPTION_OFF"

            const config = {
                container_id: visRef.current.id,
                server_url: urlWithProtocol,
                server_user: neo4jUser,
                server_password: neo4jPassword,
                encrypted: enc,
                trust: "TRUST_SYSTEM_CA_SIGNED_CERTIFICATES",
                labels: {
                    "vInvestigator": {
                        caption: "name",
                        size: "total_funding",
                        title_properties: ["name", "latest_org", "total_funding", "grants"],
                        shape: "diamond",
                        community: "orgid",
                        font: {
                            color: "blue",
                            size: 10,
                            background: "black"
                        }
                    }
                },
                relationships: {
                    "CO_SUPPORT": {
                        caption: false,
                        thickness: 'weight',
                    }
                },
                 initial_cypher: `
MATCH (:Investigator {name: "${searchname}"})-[:LED]-(:Project)-[:SUPPORTED]-(paper: Paper)
                            WHERE toInteger(${startYear}) <= paper.year <= toInteger(${stopYear})
                    MATCH (paper: Paper)-[:SUPPORTED]-(:Project)-[:LED]-(investigators: Investigator)
                    MATCH (investigators)-[:LED]-(projects:Project)-[:SUPPORTED]-(allpapers :Paper)
                    MATCH (investigators)-[:LED]-(projects:Project)-[:HOSTED]-(organizations: Organization)
                    
                    
                    WITH investigators, projects, allpapers, organizations
                                            ORDER BY projects.year DESC
                        WITH distinct investigators.name as names,
                                count(allpapers) as npub,
                                sum(distinct projects.total_cost) as total_funding,
                                collect(distinct projects.year + ". " + projects.title + ": " + projects.total_cost) as grants,
                                collect(distinct organizations.name) as orgs, 
                                collect(distinct id(organizations)) as orgid

                    
                        WITH apoc.create.vNode(["vInvestigator"], {name: names, npub: npub, total_funding: total_funding, grants: grants, orgs: orgs, latest_org: orgs[0], orgid: orgid[0]}) as prenewNodes
                        WITH apoc.map.groupBy(collect(prenewNodes),'name') as newNodes
                    
                    MATCH (:Investigator {name: "${searchname}"})-[:LED]-(:Project)-[:SUPPORTED]-(paper: Paper)
                    MATCH (paper)-[:SUPPORTED]-(:Project)-[:LED]-(investigators: Investigator)
                    MATCH (investigators)-[:LED]-(projects:Project)-[:SUPPORTED]-(allpapers :Paper)
                    MATCH (a:Investigator)-[:LED]-(:Project)-[:SUPPORTED]-(allpapers)-[:SUPPORTED]-(:Project)-[:LED]-(b:Investigator)
                        WHERE a.name > b.name AND a.name IN keys(newNodes) AND b.name IN keys(newNodes)
                    
                    WITH a, b, count(allpapers) as weight, newNodes
                    RETURN newNodes[a.name], newNodes[b.name], apoc.create.vRelationship(newNodes[a.name], "CO_SUPPORT", {weight: weight}, newNodes[b.name]);
                    

`
            };
            const vis = new Neovis(config);
            vis.render();
            // console.log(vis);
            // console.log(`MATCH (a:Author {name: '${searchname}' }) CALL apoc.path.subgraphAll(a, {maxLevel: 2}) YIELD nodes, relationships WITH nodes, relationships MATCH (c)-[:WROTE]-(p:Paper)-[:WROTE]-(d) WHERE c IN nodes AND d IN nodes AND toInteger(${startYear}) <= toInteger(p.year) <= toInteger(${stopYear}) AND ${TopicRestriction(topicChosen)} WITH c, d, collect(p.title) as titles, count(p) as collaborations WHERE collaborations >= ${collabweight} CALL apoc.create.vRelationship(c, 'CO_AUTH', {titles:titles, count:collaborations}, d) YIELD rel as collab WHERE c.name < d.name RETURN c, d, collab;`)
        }, [neo4jUri, neo4jUser, neo4jPassword, searchname, collabweight, startYear, stopYear, topicChosen, encryptionStatus, urlWithProtocol]);

        return (
            <div
                id={containerId}
                ref={visRef}
                style={{
                    // width: `100%`,
                    height: `100vh`,
                    backgroundColor: `${backgroundColor}`,
                }}
            />
        );
    };

    NeoGraph.defaultProps = {
        width: 1200,
        height: 600,
        backgroundColor: "black",
    };

    NeoGraph.propTypes = {
        width: PropTypes.number.isRequired,
        height: PropTypes.number.isRequired,
        containerId: PropTypes.string.isRequired,
        neo4jUri: PropTypes.string.isRequired,
        neo4jUser: PropTypes.string.isRequired,
        neo4jPassword: PropTypes.string.isRequired,
        backgroundColor: PropTypes.string,
    };

    const ResponsiveNeoGraph = (props) => {
        const [resizeListener, sizes] = useResizeAware();
        let height = sizes.width / 1.9

        const neoGraphProps = {...props, width: sizes.width, height: height};
        return (
            <div style={{position: "relative"}}>
                {resizeListener}
                <NeoGraph {...neoGraphProps} />
            </div>
        );
    };

    ResponsiveNeoGraph.defaultProps = {
        backgroundColor: "black",
    };

    ResponsiveNeoGraph.propTypes = {
        containerId: PropTypes.string.isRequired,
        neo4jUri: PropTypes.string.isRequired,
        neo4jUser: PropTypes.string.isRequired,
        neo4jPassword: PropTypes.string.isRequired,
        backgroundColor: PropTypes.string,
    };

export {NeoGraph, ResponsiveNeoGraph};