import styled, {ThemeProvider} from "styled-components";
import React from "react";
import { GlobalStyleNetworkVis, theme } from '@styles'

const StyledSlider = styled.div`
  ${({ theme }) => theme.mixins.flexCenter};
  text-align: center;
  background-color: #000000;
  color: var(--light-slate);
  font-family: var(--font-mono);
  font-size: 100;
  line-height: 1;
  margin: 0px 10px 0px 10px;
  
  position: fixed;
  bottom: 50%;
  left: 0;
  z-index: 0;

  width: 100%;
  height: var(--nav-height);
  background-color: rgba(0, 0, 0, 0.5);
  filter: none !important;
  backdrop-filter: blur(10px);
  transition: var(--transition);
`;

const ComingSoon = () => {

    return(
        <ThemeProvider theme={theme}>
            <GlobalStyleNetworkVis />
            <StyledSlider>
                COMING SOON <br/>
                We are working on some cool features to include in the Constellations Project <br/>
                <br/>
                keletso [dot] makofane [at] gmail [dot] com
            </StyledSlider>
        </ThemeProvider>
    )
}

export default ComingSoon;