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
                },
                relationships: {
                    "CO_AUTH": {
                        caption: false,
                        thickness: 'Collaborations',
                    }
                },
                 initial_cypher: `MATCH (a:Author)-[:WROTE]-(p:Paper)-[:WROTE]-(b:Author) WHERE (:Author {name: '${searchname}'})-[:WROTE]-(p) AND toInteger(${startYear}) <= p.year <= toInteger(${stopYear}) AND ${TopicRestriction(topicChosen)} WITH a, b, collect(p.title) as titles, count(p.title) as collaborations CALL apoc.create.vRelationship(a, 'CO_AUTH', {Collaborations: toInteger(collaborations), Titles:titles}, b) YIELD rel  WHERE collaborations >= ${collabweight} and a.name < b.name RETURN a, b, rel;`
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