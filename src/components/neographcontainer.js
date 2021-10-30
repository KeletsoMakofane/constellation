import React from "react";
import { ResponsiveNeoGraph, Header, Footer } from '@components';
import neo4j from "neo4j-driver";

class NeoGraphContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {name: this.props.defaultName,
                  weight: '1',
                  start: this.props.defaultStart,
                  stop: this.props.defaultStop,
                  topic: this.props.defaultTopic,
                  queryName: this.props.defaultName,
                  queryWeight: '1',
                  queryStart: this.props.defaultStart,
                  queryStop: this.props.defaultStop,
                  queryTopic: this.props.defaultTopic,
                  suggestions: ""};

    this.handleChangeN = this.handleChangeN.bind(this);
    this.handleChangeW = this.handleChangeW.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleChangeStart = this.handleChangeStart.bind(this);
    this.handleChangeStop = this.handleChangeStop.bind(this);
    this.handleChangeTopic = this.handleChangeTopic.bind(this);
    this.updateName = this.updateName.bind(this);

  }


  handleChangeN(event) {
    this.setState({name: event.target.value}, this.updateName(event.target.value));
    console.log(this.state.suggestions);
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

  handleChangeTopic(event) {
      this.setState({topic: event.target.value});
  }

  handleSubmit(event){
      this.setState({queryName: this.state.name,
                           queryWeight: this.state.weight,
                           queryStart: this.state.start,
                           queryStop: this.state.stop,
                           queryTopic: this.state.topic});
      event.preventDefault();

      // console.log(this.state.name);
      // console.log(this.state.weight);
      // console.log(this.state.start);
      // console.log(this.state.stop);
      // console.log(this.state.topic);
  }



  updateName = (searchString) => {
      const urlWithProtocol = this.props.neovisProtocol + this.props.neo4jUri;
      const driver = neo4j.driver( urlWithProtocol , neo4j.auth.basic(this.props.neo4jUser, this.props.neo4jPassword), {encrypted: 'ENCRYPTION_ON', trust: "TRUST_SYSTEM_CA_SIGNED_CERTIFICATES"});
      const session = driver.session();

      session.run(`MATCH (a:Author) WHERE toLower(a.name) CONTAINS toLower("${searchString}") RETURN a.name AS name ORDER BY name LIMIT 5`)
          .then((result) => {this.setState({suggestions: result.records.map(item =>   `<option value= "${item.get('name')}" />` ).join("")})})
          .catch(error => { console.log(error) })
  }

  render() {




    return (
        <>
            <div className="App">
                <ResponsiveNeoGraph
                    containerId={this.props.containerId}
                    neo4jUri={this.props.neo4jUri}
                    neo4jUser={this.props.neo4jUser}
                    neo4jPassword={this.props.neo4jPassword}
                    neovisProtocol = {this.props.neovisProtocol}
                    searchname={this.state.queryName}
                    collabweight={this.state.queryWeight}
                    startYear = {this.state.queryStart}
                    stopYear = {this.state.queryStop}
                    topicChosen = {this.state.queryTopic}
                    encryptionStatus = {this.props.neovisEncryptionStatus}/>

            </div>

            <Header
                name = {this.state.name}
                weight = {this.state.weight}
                start = {this.state.start}
                stop = {this.state.stop}
                topic = {this.state.topic}
                nameChange = {this.handleChangeN}
                weightChange = {this.handleChangeW}
                startChange = {this.handleChangeStart}
                stopChange = {this.handleChangeStop}
                topicChange = {this.handleChangeTopic}
                submit = {this.handleSubmit}
                nameOptions = {this.suggestions}
            />

            <Footer/>
</>

    );
  }
}

export default NeoGraphContainer;