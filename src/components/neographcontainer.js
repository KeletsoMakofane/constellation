import React from "react";
import { ResponsiveNeoGraph, Header, Footer, updateName } from '@components';

class NeoGraphContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {name: this.props.defaultName,
                  weight: '1',
                  start: this.props.defaultStart,
                  stop: this.props.defaultStop,
                  queryName: this.props.defaultName,
                  queryWeight: '1',
                  queryStart: this.props.defaultStart,
                  queryStop: this.props.defaultStop};

    this.handleChangeN = this.handleChangeN.bind(this);
    this.handleChangeW = this.handleChangeW.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleChangeStart = this.handleChangeStart.bind(this);
    this.handleChangeStop = this.handleChangeStop.bind(this);

  }

  handleChangeN(event) {
    this.setState({name: event.target.value});
    updateName(this.props.neo4jUri, this.props.neo4jUser, this.props.neo4jPassword, this.state.name)
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


    return (
        <>
            <div className="App">
                <ResponsiveNeoGraph
                    containerId={this.props.containerId}
                    neo4jUri={this.props.neo4jUri}
                    neo4jUser={this.props.neo4jUser}
                    neo4jPassword={this.props.neo4jPassword}
                    searchname={this.state.queryName}
                    collabweight={this.state.queryWeight}
                    startYear = {this.state.queryStart}
                    stopYear = {this.state.queryStop}
                    encryptionStatus = {this.props.encryptionStatus}/>

            </div>

            <Header
                name = {this.state.name}
                weight = {this.state.weight}
                start = {this.state.start}
                stop = {this.state.stop}
                nameChange = {this.handleChangeN}
                weightChange = {this.handleChangeW}
                startChange = {this.handleChangeStart}
                stopChange = {this.handleChangeStop}
                submit = {this.handleSubmit}
            />

            <Footer/>
</>

    );
  }
}

export default NeoGraphContainer;