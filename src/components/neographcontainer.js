import React from "react";
import { ResponsiveNeoGraph } from '@components';
import styled from 'styled-components';
import { ThemeProvider } from 'styled-components';
import { GlobalStyleNetworkVis, theme } from '@styles';


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

class NeoGraphContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {name: 'Krieger N',
                  weight: '1',
                  start: '1980',
                  stop: '2021',
                  queryName: 'Krieger N',
                  queryWeight: '1',
                  queryStart: '1980',
                  queryStop: '2021'};

    this.handleChangeN = this.handleChangeN.bind(this);
    this.handleChangeW = this.handleChangeW.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleChangeStart = this.handleChangeStart.bind(this);
    this.handleChangeStop = this.handleChangeStop.bind(this);

  }

  handleChangeN(event) {
    this.setState({name: event.target.value});
  }

  handleChangeW(event) {
    this.setState({weight: event.target.value});
  }

  handleChangeStart(event) {
    this.setState({start: event.target.value});
  }

  handleChangeStop(event) {
    this.setState({stop: event.target.value});
  }

  handleSubmit(event){
      this.setState({queryName: this.state.name,
                           queryWeight: this.state.weight,
                           queryStart: this.state.start,
                           queryStop: this.state.stop});
      event.preventDefault();
  }


  render() {
      const containerId = this.props.containerId
      const neo4jUri = this.props.neo4jUri
      const neo4jUser = this.props.neo4jUser
      const neo4jPassword = this.props.neo4jPassword

    return (
        <>
            <div className="App">
                <ResponsiveNeoGraph
                    containerId={containerId}
                    neo4jUri={neo4jUri}
                    neo4jUser={neo4jUser}
                    neo4jPassword={neo4jPassword}
                    searchname={this.state.queryName}
                    collabweight={this.state.queryWeight}
                    startYear = {this.state.queryStart}
                    stopYear = {this.state.queryStop}/>
            </div>

            <ThemeProvider theme={theme}>
                <GlobalStyleNetworkVis />

                <StyledForm>
                    <form>
                        the constellations project (led by <a href = 'https://twitter.com/klts0' color = 'blue'><u>@klts0</u></a>)<br/> <br/>
                        Researcher:  &nbsp; <input type="text" value={this.state.name} onChange={this.handleChangeN} />
                        &emsp; &emsp;


                        Show:  &nbsp; <select  name="weight" id = "weight" value = {this.state.weight} onChange={this.handleChangeW}>
                                                    <option value="1" selected>1+ Papers</option>
                                                    <option value="2">2+ Papers</option>
                                                    <option value="3">3+ Papers</option>
                                                    <option value="4">4+ Papers</option>
                                                    <option value="5">5+ Papers</option>
                                                    <option value="10">10+ Papers</option>
                                                    <option value="20">20+ Papers</option>
                                            </select>

                        &emsp; &emsp;

                        From:  &nbsp;<input type="number" size = "4" value = {this.state.start} onChange = {this.handleChangeStart}/>
                        &emsp; &emsp;

                        To:    &nbsp;<input type="number" size = "4" value = {this.state.stop} onChange = {this.handleChangeStop}/>
                        &emsp; &emsp;

                        On:  &nbsp; <select  name="on" id = "on">
                                                    <option value="1" selected>Race/Racism</option>
                                                    <option value="2">COVID-19 (coming soon)</option>
                                                    <option value="3">Both (coming soon)</option>
                                            </select>
                        &emsp; &emsp; &emsp;

                        <button onClick = {this.handleSubmit}>Lets Go!</button>


                    </form>
                </StyledForm>
            </ThemeProvider>

            <StyledSlider>
                this takes a moment to load. take a deep breath and count to 10. go fullscreen. float over and drag nodes, edges, and background. scroll to zoom. not great on small screens.<br/>
                made by keletso makofane using pubmed api // interested in supporting the constellations project? donate to help cover hosting costs for the site // venmo: @Keletso-Makofane
            </StyledSlider>
</>

    );
  }
}

export default NeoGraphContainer;