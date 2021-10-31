import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { NeoGraphContainer, ComingSoon } from "@components";
import { Credentials } from '@components';
import {Helmet} from "react-helmet";

// Credentials
const NEO4J_URI =  Credentials.NEO4J_URI;
const NEO4J_USER = Credentials.NEO4J_USER;
const NEO4J_PASSWORD = Credentials.NEO4J_PASSWORD;
const NEOVIS_PROTOCOL = Credentials.NEOVIS_PROTOCOL;
const NEOVIS_ENCRYPTION = Credentials.NEOVIS_ENCRYPTION;


// Defaults
const DEF_NAME = 'Keletso Makofane';
const DEF_START = '2015';
const DEF_STOP = '2021';
const DEF_TOPIC = 'all'

const PubMedPage = ({ location }) => {

useEffect (() => {document.body.style.backgroundColor = "black"})

  return (
      <NeoGraphContainer
          containerId={"id0"}
          neo4jUri={NEO4J_URI}
          neo4jUser={NEO4J_USER}
          neo4jPassword={NEO4J_PASSWORD}
          neovisEncryptionStatus = {NEOVIS_ENCRYPTION}
          neovisProtocol = {NEOVIS_PROTOCOL}
          defaultName = {DEF_NAME}
          defaultStart = {DEF_START}
          defaultStop = {DEF_STOP}
          defaultTopic = {DEF_TOPIC}/>
  );
};

PubMedPage.propTypes = {
  location: PropTypes.object.isRequired,
};

export default PubMedPage;

