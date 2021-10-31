import styled, {ThemeProvider} from "styled-components";
import React, {useState} from "react";
import { GlobalStyleNetworkVis, theme } from '@styles'
import Autocomplete from 'react-autocomplete';
import neo4j from "neo4j-driver";
import { useAsync } from 'react-async-hook';
import  Credentials   from './credentials';

const StyledForm = styled.div`
  ${({ theme }) => theme.mixins.flexCenter};
  text-align: center;
  background-color: #000000;
  color: var(--light-slate);
  font-family: var(--font-mono);
  font-size: var(--fz-xxs);
  line-height: 1;
  margin: 0px 10px 0px 10px;
  
  position: fixed;
  top: 0;
  left: 0;
  z-index: 0;

  width: 100%;
  height: var(--nav-height);
  background-color: rgba(0, 0, 0, 0.5);
  filter: none !important;
  backdrop-filter: blur(10px);
  transition: var(--transition);
`;

    const getNames = async (searchString) => {
            const urlWithProtocol = Credentials.NEODRIVER_PROTOCOL + Credentials.NEO4J_URI;
            const driver = neo4j.driver( urlWithProtocol , neo4j.auth.basic(Credentials.NEO4J_USER, Credentials.NEO4J_PASSWORD), {encrypted: 'ENCRYPTION_ON', trust: "TRUST_SYSTEM_CA_SIGNED_CERTIFICATES"});
            const session = driver.session();
            const pulled = await session.run(`MATCH (a:Author) WHERE toLower(a.name) CONTAINS toLower('${searchString}') RETURN a.name AS name ORDER BY name LIMIT 5`);



            const result = pulled && pulled.records.map(item => {const node = Object.create({});
                                                                         node.name = item.get("name");
                                                                            return node});
            console.log(result)
            return result

            }


const Header = (props) => {
    const {name, weight, start, stop, topic, nameChange, weightChange, startChange, stopChange, topicChange, submit, onSelect} = props;
    const [suggestions, setSuggestions] = useState([]);
    let displayList;

    const pulledNames = useAsync(getNames, [name])

    if (pulledNames.result){
          displayList = pulledNames.result
    } else {
          displayList = []
    };



    return(
        <ThemeProvider theme={theme}>

            <GlobalStyleNetworkVis />

            <StyledForm>
                <form>
                        Researcher:  &nbsp;     <Autocomplete
                                                     getItemValue = {(item) => item.name}
                                                     items={displayList}

                                                     renderItem={(item, isHighlighted) =>
                                                             <div style={{ background: isHighlighted ? 'light grey' : 'white', color: 'black' }}>
                                                                  {item.name}
                                                             </div>
                                                                }

                                                     value={name}
                                                     onChange={nameChange}
                                                     onSelect={onSelect}
                                                 />
                        &emsp; &emsp;

                        Show:  &nbsp; <select  name="weight" id = "weight" value = {weight} onChange={weightChange}>
                                                    <option value="1" selected>1+ Papers</option>
                                                    <option value="2">2+ Papers</option>
                                                    <option value="3">3+ Papers</option>
                                                    <option value="4">4+ Papers</option>
                                                    <option value="5">5+ Papers</option>
                                                    <option value="10">10+ Papers</option>
                                                    <option value="20">20+ Papers</option>
                        </select>
                        &emsp; &emsp;

                        From:  &nbsp;<input type="number" size = "4" value = {start} onChange = {startChange}/>
                        &emsp; &emsp;

                        To:    &nbsp;<input type="number" size = "4" value = {stop} onChange = {stopChange}/>
                        &emsp; &emsp;

                        On:  &nbsp; <select  name="on" id = "on" value = {topic} onChange = {topicChange}>
                                                    <option value="race" selected>Race</option>
                                                    <option value="racism" >Racism (coming soon)</option>
                                                    <option value="covid">COVID (coming soon)</option>
                                                    <option value="race_covid">Race and COVID (coming soon)</option>
                                                    <option value="racism_covid">Racism and COVID (coming soon)</option>
                                                    <option value="all">Race or Racism or COVID</option>
                                            </select>
                        &emsp; &emsp; &emsp;

                        <button onClick = {submit}>Lets Go!</button>



                    </form>
                </StyledForm>
            </ThemeProvider>
    )
}

export default Header;