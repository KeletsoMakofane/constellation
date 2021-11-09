import React, {useState} from "react";
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
  height: 8%;
  background-color: rgba(0, 0, 0, 0.1);
  filter: none !important;
  backdrop-filter: blur(10px);
  transition: var(--transition);
`;
const StyledPopup = styled.div`
  ${({ theme }) => theme.mixins.flexCenter};
  text-align: center;
  background-color: #000000;
  color: var(--light-slate);
  font-family: var(--font-mono);
  font-size: var(--fz-xxs);
  line-height: 1;
  margin: 0px 10px 0px 10px;
  outline: 0.5px solid var(--light-slate);
    vertical-align: text-top;
  
  float: left;
  position: fixed;
  bottom: 35%;
  left: 15%;
  right: 15%
  z-index: 0;

  width: 70%;
  height: 30%;
  background-color: rgba(0, 0, 0, 0, 0);
  filter: none !important;
  backdrop-filter: blur(10px);
  transition: var(--transition);
`;
const StyledMessageBox = styled.div`
  ${({ theme }) => theme.mixins.flexCenter};
  text-align: center;
  background-color: #000000;
  color: var(--light-slate);
  font-family: var(--font-mono);
  font-size: var(--fz-xxs);
  line-height: 1.5;
  margin: 10px 15px 10px 15px;
  vertical-align: text-top;
  
top: 0;
  width: 100%;
  float: left
  height: 100%;
`;

const Footer = () => {
        const [popupStatus, setPopupStatus] = useState(false);

        const handleClick = (e) => {
         e.preventDefault();
         setPopupStatus(!popupStatus)
            console.log(popupStatus)
        }

        const popupWindow =     <StyledPopup>
                                    <StyledMessageBox>
                                        ABOUT<br/><br/>
                                        The Constellations Project aims to show the constellations of researchers, collaborations, and funding that produce public health scholarship. The initial focus is scholarship on racism and health. Let us know about your experience using this tool at kmakofane(at)g[dot]harvard(dot)edu. Spread the word - tweet about it (tag @klts0 pls)!
                                    </StyledMessageBox>

                                    <StyledMessageBox>
                                        METHODS<br/><br/>
                                        Based on Pubmed articles published after 1 January 2003. Articles were returned by the search query (racism[Title/Abstract]) OR (race[Title/Abstract]) OR (covid[Title/Abstract]).
                                    </StyledMessageBox>

                                    <StyledMessageBox>
                                        CREW<br/><br/>
                                        Led by Keletso Makofane with Brittney Butler, Tori Cowger, Justin Feldman, Jourdyn Lawrence, and Marie Plaisime. Supported by the Harvard FXB Center for Health and Human Rights. Courtesy of the U.S. National Library of Medicine.
                                    </StyledMessageBox>

                                </StyledPopup>

let currColor = popupStatus ? 'red' : undefined;

if (popupStatus) currColor = 'red';

    return(
        <ThemeProvider theme={theme}>
            <GlobalStyleNetworkVis />
            {popupStatus && popupWindow}
            <StyledSlider>
                <a href="#" onClick={handleClick} style={{color: currColor}}> <u>{popupStatus ? "Back To" : "About"} The Constellations Project</u></a>
            </StyledSlider>
        </ThemeProvider>
    )
}

export default Footer;