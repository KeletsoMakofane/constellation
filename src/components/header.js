import styled, {ThemeProvider} from "styled-components";
import React, {useState} from "react";
import { GlobalStyleNetworkVis, theme } from '@styles'
import Autocomplete from 'react-autocomplete';
import neo4j from "neo4j-driver";
import { useAsync } from 'react-async-hook';
import  Credentials   from './credentials';
import {CypherAutoCNames} from "@components";


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
  height: 10%;
  background-color: rgba(0, 0, 0, 0.5);
  filter: none !important;
  backdrop-filter: blur(10px);
  transition: var(--transition);
`;




const Header = (props) => {
    const {name, weight, start, stop, topic, nameChange, weightChange, startChange, stopChange, topicChange, submit, onSelect, dataView} = props;
    const [suggestions, setSuggestions] = useState([]);
    let displayList;

        const getNames = async (searchString) => {
            const urlWithProtocol = Credentials.NEODRIVER_PROTOCOL + Credentials.NEO4J_URI;
            const driver = neo4j.driver( urlWithProtocol , neo4j.auth.basic(Credentials.NEO4J_USER, Credentials.NEO4J_PASSWORD), {encrypted: 'ENCRYPTION_ON', trust: "TRUST_SYSTEM_CA_SIGNED_CERTIFICATES"});
            const session = driver.session();
            const pulled = await session.run(CypherAutoCNames(dataView), {searchName: searchString});



            const result = pulled && pulled.records.map(item => {const node = Object.create({});
                                                                         node.name = item.get("name");
                                                                            return node});

            return result

            }


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
                    <p></p>
                    <p>THE CONSTELLATIONS PROJECT</p>
                    <p></p>

                        Researcher:  &emsp;     <Autocomplete
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


                        Min Collaborations Shown:  &emsp; <input type="number" style = {{width: '70px'}} value = {weight} onChange = {weightChange}/>
                        &emsp; &emsp;

                        Date Range:  &emsp;<input type="number" style = {{width: '70px'}} value = {start} onChange = {startChange}/>
                        &emsp;

                            <input type="number" style = {{width: '70px'}} value = {stop} onChange = {stopChange}/>
                        &emsp; &emsp;

                        Pubmed Search:  &emsp; <select  name="on" id = "on" value = {topic} onChange = {topicChange}>
                                                    <option value="all" >All</option>
                                                    <option value="racism" >Racism</option>
                                                    <option value="covid">COVID</option>
                                                    <option value="racism_covid">Racism and COVID</option>
                                            </select>
                        &emsp; &emsp; &emsp;

                        <button onClick = {submit}>Lets Go!</button>



                    </form>
                </StyledForm>
            </ThemeProvider>
    )
}

export default Header;