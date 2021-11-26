import React, {useState} from "react";
import { ResponsiveNeoGraph, Header, Footer } from '@components';
import { trackCustomEvent } from "gatsby-plugin-google-analytics"


const NeoGraphContainer = (props) => {
    const {defaultName, defaultStart, defaultStop, defaultTopic, defaultWeight, containerId, neo4jUri, neo4jUser, neo4jPassword, neovisProtocol, neovisEncryptionStatus, dataView } = props
    const [name, setName] = useState(defaultName);
    const [weight, setWeight] = useState(defaultWeight);
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

        trackCustomEvent({
          category: "Submit Button",
          action: "Search",
          label: queryName,
          value: 88,
        })
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
                    encryptionStatus = {neovisEncryptionStatus}
                    dataView = {dataView}/>

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
                dataView = {dataView}
            />

            <Footer/>
</>

  )


}


export default NeoGraphContainer;