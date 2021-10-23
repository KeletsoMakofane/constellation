import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import styled from 'styled-components';
import { ThemeProvider } from 'styled-components';
import { theme } from '@styles';
import {NeoGraphContainer} from "@components";

const NEO4J_URI =  "neo4j://graph.keletsomakofane.com";
const NEO4J_USER = "neo4j";
const NEO4J_PASSWORD = "gybsuv-merqaj-8Vuvsi";

const StyledMainContainer = styled.main`
  counter-reset: section;
`;



const PubMedPage = ({ location }) => {

useEffect (() => {document.body.style.backgroundColor = "black"})

  return (
      <>
        <ThemeProvider theme={theme}>

          <StyledMainContainer>
            <NeoGraphContainer containerId={"id0"} neo4jUri={NEO4J_URI} neo4jUser={NEO4J_USER} neo4jPassword={NEO4J_PASSWORD}/>

          </StyledMainContainer>

          </ThemeProvider>
      </>
  );
};

PubMedPage.propTypes = {
  location: PropTypes.object.isRequired,
};

export default PubMedPage;

