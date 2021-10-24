import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { NeoGraphContainer } from "@components";
import { credentials } from '@components';

// Credentials
const NEO4J_URI =  credentials.NEO4J_URI;
const NEO4J_USER = credentials.NEO4J_USER;
const NEO4J_PASSWORD = credentials.NEO4J_PASSWORD;

// Encryption
const ENCRYPTION = true;

// Defaults
const DEF_NAME = 'Krieger N';
const DEF_START = '1980';
const DEF_STOP = '2021';


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
          defaultStop = {DEF_STOP}/>
  );
};

PubMedPage.propTypes = {
  location: PropTypes.object.isRequired,
};

export default PubMedPage;

