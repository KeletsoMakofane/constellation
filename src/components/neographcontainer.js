import React, {useState} from "react";
import { ResponsiveNeoGraph, Header, Footer } from '@components';
import neo4j from "neo4j-driver";




const NeoGraphContainer = (props) => {
    const {defaultName, defaultStart, defaultStop, defaultTopic, containerId, neo4jUri, neo4jUser, neo4jPassword, neovisProtocol, neovisEncryptionStatus } = props
    const [name, setName] = useState(defaultName);
    const [weight, setWeight] = useState('1');
    const [start, setStart] = useState(defaultStart);
    const [stop, setStop] = useState(defaultStop);
    const [topic, setTopic] = useState(defaultTopic);
    const [queryName, setQueryName] = useState(defaultName);
    const [queryWeight, setQueryWeight] = useState('1');
    const [queryStart, setQueryStart] = useState(defaultStart);
    const [queryStop, setQueryStop] = useState(defaultStop);
    const [queryTopic, setQueryTopic] = useState(defaultTopic);


    const handleChangeN = (e) => {
        setName(e.target.value);
    }

    const handleChangeW = (e) => {
        setWeight(e.target.value);
    }

    const handleChangeStart = (e) => {
        setStart(e.target.value);
    }

    const handleChangeStop = (e) => {
        setStop(e.target.value);
    }

    const handleChangeTopic = (e) => {
        setTopic(e.target.value);
    }

    const handleSubmit = (e) => {
        setQueryName(name);
        setQueryStart(start);
        setQueryStop(stop);
        setQueryTopic(topic);
        setQueryWeight(weight);
        e.preventDefault();
    }


  return(
              <>
            <div className="App">
                <ResponsiveNeoGraph
                    containerId = {containerId}
                    neo4jUri = {neo4jUri}
                    neo4jUser = {neo4jUser}
                    neo4jPassword = {neo4jPassword}
                    neovisProtocol = {neovisProtocol}
                    searchname = {queryName}
                    collabweight = {queryWeight}
                    startYear = {queryStart}
                    stopYear = {queryStop}
                    topicChosen = {queryTopic}
                    encryptionStatus = {neovisEncryptionStatus}/>

            </div>

            <Header
                name = {name}
                weight = {weight}
                start = {start}
                stop = {stop}
                topic = {topic}
                nameChange = {handleChangeN}
                weightChange = {handleChangeW}
                startChange = {handleChangeStart}
                stopChange = {handleChangeStop}
                topicChange = {handleChangeTopic}
                submit = {handleSubmit}
                onSelect = {setName}

            />

            <Footer/>
</>

  )


}
//
// class NeoGraphContainer extends React.Component {
//   constructor(props) {
//     super(props);
//     this.state = {name: this.props.defaultName,
//                   weight: '1',
//                   start: this.props.defaultStart,
//                   stop: this.props.defaultStop,
//                   topic: this.props.defaultTopic,
//                   queryName: this.props.defaultName,
//                   queryWeight: '1',
//                   queryStart: this.props.defaultStart,
//                   queryStop: this.props.defaultStop,
//                   queryTopic: this.props.defaultTopic,
//                   suggestions: ""};
//
//     this.handleChangeN = this.handleChangeN.bind(this);
//     this.handleChangeW = this.handleChangeW.bind(this);
//     this.handleSubmit = this.handleSubmit.bind(this);
//     this.handleChangeStart = this.handleChangeStart.bind(this);
//     this.handleChangeStop = this.handleChangeStop.bind(this);
//     this.handleChangeTopic = this.handleChangeTopic.bind(this);
//     this.updateName = this.updateName.bind(this);
//     this.transformRecords = this.transformRecords.bind(this);
//
//   }
//
//
//   handleChangeN(event) {
//     this.setState({name: event.target.value}, this.updateName(event.target.value));
//     console.log(this.state.suggestions);
//   }
//
//
//   handleChangeW(event) {
//     this.setState({weight: event.target.value});
//   }
//
//   handleChangeStart(event) {
//     this.setState({start: event.target.value});
//   }
//
//   handleChangeStop(event) {
//     this.setState({stop: event.target.value});
//   }
//
//   handleChangeTopic(event) {
//       this.setState({topic: event.target.value});
//   }
//
//   handleSubmit(event){
//       this.setState({queryName: this.state.name,
//                            queryWeight: this.state.weight,
//                            queryStart: this.state.start,
//                            queryStop: this.state.stop,
//                            queryTopic: this.state.topic});
//       event.preventDefault();
//
//       // console.log(this.state.name);
//       // console.log(this.state.weight);
//       // console.log(this.state.start);
//       // console.log(this.state.stop);
//       // console.log(this.state.topic);
//   }
//
//   transformRecords = (result) => {
//       result.records.map(item => {item.get("name")})
//   }
//
//
//   updateName = (searchString) => {
//       const urlWithProtocol = this.props.neovisProtocol + this.props.neo4jUri;
//       const driver = neo4j.driver( urlWithProtocol , neo4j.auth.basic(this.props.neo4jUser, this.props.neo4jPassword), {encrypted: 'ENCRYPTION_ON', trust: "TRUST_SYSTEM_CA_SIGNED_CERTIFICATES"});
//       const session = driver.session();
//
//       session.run(`MATCH (a:Author) WHERE toLower(a.name) CONTAINS toLower("${searchString}") RETURN a.name AS name ORDER BY name LIMIT 5`)
//           .then((result) => {
//               const nameArray = result.records.map(item => {
//                                              const node = Object.create({});
//                                              node.name = item.get("name");
//                                              return node
//                                          });
//
//               if (nameArray) { this.setState({suggestions: nameArray}) }
//
//           })
//           .catch(error => { console.log(error) })
//   }
//
//   render() {
//
//
//
//
//     return (
//         <>
//             <div className="App">
//                 <ResponsiveNeoGraph
//                     containerId={this.props.containerId}
//                     neo4jUri={this.props.neo4jUri}
//                     neo4jUser={this.props.neo4jUser}
//                     neo4jPassword={this.props.neo4jPassword}
//                     neovisProtocol = {this.props.neovisProtocol}
//                     searchname={this.state.queryName}
//                     collabweight={this.state.queryWeight}
//                     startYear = {this.state.queryStart}
//                     stopYear = {this.state.queryStop}
//                     topicChosen = {this.state.queryTopic}
//                     encryptionStatus = {this.props.neovisEncryptionStatus}/>
//
//             </div>
//
//             <Header
//                 name = {this.state.name}
//                 weight = {this.state.weight}
//                 start = {this.state.start}
//                 stop = {this.state.stop}
//                 topic = {this.state.topic}
//                 nameChange = {this.handleChangeN}
//                 weightChange = {this.handleChangeW}
//                 startChange = {this.handleChangeStart}
//                 stopChange = {this.handleChangeStop}
//                 topicChange = {this.handleChangeTopic}
//                 submit = {this.handleSubmit}
//                 nameOptions = {this.state.suggestions}
//             />
//
//             <Footer/>
// </>
//
//     );
//   }
// }

export default NeoGraphContainer;