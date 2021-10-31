import React from "react";
import styled, {ThemeProvider} from "styled-components";
import { GlobalStyleNetworkVis, theme } from '@styles'

const StyledSlider = styled.div`
  ${({ theme }) => theme.mixins.flexCenter};
  text-align: center;
  background-color: #000000;
  color: var(--light-slate);
  font-family: var(--font-mono);
  font-size: var(--fz-xxs);
  line-height: 1;
  margin: 0px 10px 0px 10px;
  
  position: fixed;
  bottom: 0;
  left: 0;
  z-index: 0;

  width: 100%;
  height: var(--nav-height);
  background-color: rgba(0, 0, 0, 0.5);
  filter: none !important;
  backdrop-filter: blur(10px);
  transition: var(--transition);
`;

const Footer = () => {

    return(
        <ThemeProvider theme={theme}>
            <GlobalStyleNetworkVis />
            <StyledSlider>
                ... Still ironing out a few kinks. Watch this space. <br/>
                made by keletso makofane using pubmed api // interested in supporting the constellations project? donate to help cover hosting costs for the site // venmo: @Keletso-Makofane
            </StyledSlider>
        </ThemeProvider>
    )
}

export default Footer;