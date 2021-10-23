import React, { useEffect, useRef } from "react";
import useResizeAware from "react-resize-aware";
import PropTypes from "prop-types";
import Neovis from "neovis.js/dist/neovis.js";


    const NeoGraph = (props) => {
        const {
            width,
            height,
            containerId,
            backgroundColor,
            neo4jUri,
            neo4jUser,
            neo4jPassword,
            searchname,
            collabweight,
            startYear,
            stopYear
        } = props;


        const visRef = useRef();

        useEffect(() => {
            const config = {
                container_id: visRef.current.id,
                server_url: neo4jUri,
                server_user: neo4jUser,
                server_password: neo4jPassword,
                encrypted: "ENCRYPTION_OFF",
                labels: {
                    "Author": {
                        caption: "name",
                        size: "pagerank_citations",
                        community: 'auth_community',
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
                        thickness: 'count',
                    }
                },
                 initial_cypher: "MATCH (a:Author {name: '" + searchname + "' }) CALL apoc.path.subgraphAll(a, {maxLevel: 2}) YIELD nodes, relationships WITH nodes, relationships MATCH (c)-[:WROTE]-(p:Paper)-[:WROTE]-(d) WHERE c IN nodes AND d IN nodes AND toInteger(" + startYear + ") <= toInteger(p.year) <= toInteger(" + stopYear + ") WITH c, d, collect(p.title) as titles, count(p) as collaborations WHERE collaborations >=" + collabweight + " CALL apoc.create.vRelationship(c, 'CO_AUTH', {titles:titles, count:collaborations}, d) YIELD rel as collab WHERE c.name < d.name RETURN c, d, collab;"
            };
            const vis = new Neovis(config);
            vis.render();
        }, [neo4jUri, neo4jUser, neo4jPassword, searchname, collabweight, startYear, stopYear]);

        return (
            <div
                id={containerId}
                ref={visRef}
                style={{
                    width: `${width}px`,
                    height: `${height}px`,
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

        const neoGraphProps = {...props, width: '100%', height: height};
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