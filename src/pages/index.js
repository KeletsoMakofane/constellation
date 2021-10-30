import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { NeoGraphContainer, ComingSoon } from "@components";
import { credentials } from '@components';
import {Helmet} from "react-helmet";

// Credentials
const NEO4J_URI =  credentials.NEO4J_URI;
const NEO4J_USER = credentials.NEO4J_USER;
const NEO4J_PASSWORD = credentials.NEO4J_PASSWORD;

// Encryption
const ENCRYPTION = false;

// Defaults
const DEF_NAME = 'Nancy Krieger';
const DEF_START = '1980';
const DEF_STOP = '2021';
const DEF_TOPIC = 'race'

const PubMedPage = ({ location }) => {

useEffect (() => {document.body.style.backgroundColor = "black"})

  return (
      <NeoGraphContainer
          containerId={"id0"}
          neo4jUri={NEO4J_URI}
          neo4jUser={NEO4J_USER}
          neo4jPassword={NEO4J_PASSWORD}
          encryptionStatus = {ENCRYPTION}
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

