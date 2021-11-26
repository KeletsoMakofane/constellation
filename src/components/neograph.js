import React, { useEffect, useRef } from "react";
import useResizeAware from "react-resize-aware";
import PropTypes from "prop-types";
import Neovis from "neovis.js/dist/neovis.js";
import { CypherQuery, CypherLabels, CypherRelationships } from "@components";



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
            dataView
        } = props;


        const urlWithProtocol = neovisProtocol + neo4jUri
        const visRef = useRef();

        useEffect(() => {

            const enc = encryptionStatus ? "ENCRYPTION_ON" : "ENCRYPTION_OFF"

            const config = {
                container_id:   visRef.current.id,
                server_url:      urlWithProtocol,
                server_user:     neo4jUser,
                server_password: neo4jPassword,
                encrypted:       enc,
                trust:           "TRUST_SYSTEM_CA_SIGNED_CERTIFICATES",
                labels:          CypherLabels(dataView),
                relationships:   CypherRelationships(dataView),
                initial_cypher:  CypherQuery(searchname,collabweight,startYear,stopYear,topicChosen,dataView)
            };
            const vis = new Neovis(config);
            vis.render();
            console.log(CypherLabels(dataView));
            console.log(CypherRelationships(dataView));
            console.log(CypherQuery(searchname,collabweight,startYear,stopYear,topicChosen,dataView))

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