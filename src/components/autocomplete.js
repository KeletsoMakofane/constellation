import { credentials } from '@components';
const neo4j = require('neo4j-driver')


const makeHtmlUpdate = (result) => {
    // const names = result.records.map(item =>   `<option value= "${item.get('name')}" />` ).join("")
    // document.getElementById("suggestions").innerHTML = names;
    // console.log(names);
  }


const updateName = (searchString) => {
// console.log("updateName Called")
//     console.log(searchString)
//
//     const urlWithProtocol = credentials.NEODRIVER_PROTOCOL + credentials.NEO4J_URI;
//     const driver = neo4j.driver( urlWithProtocol , neo4j.auth.basic(credentials.NEO4J_USER, credentials.NEO4J_PASSWORD), {encrypted: 'ENCRYPTION_ON', trust: "TRUST_SYSTEM_CA_SIGNED_CERTIFICATES"})
//     const session = driver.session()
//
//     session.run(`MATCH (a:Author) WHERE toLower(a.name) CONTAINS toLower("${searchString}") RETURN a.name AS name ORDER BY name LIMIT 5`)
//         .then(makeHtmlUpdate)
//         .catch(error => { console.log(error) })
//         .then(() => session.close())

}

export default updateName;







