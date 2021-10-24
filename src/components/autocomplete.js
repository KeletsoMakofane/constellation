const neo4j = require('neo4j-driver')


const makeHtmlUpdate = (result) => {
    const names = result.records.map(item =>   `<option value= "${item.get('name')}" />` ).join("")
    document.getElementById("suggestions").innerHTML = names;
    console.log(names);
  }

const updateName = (url, username, password, searchString) => {

  const driver = neo4j.driver(
  url ,
  neo4j.auth.basic(username, password))

  const session = driver.session()

  session
  .run(`MATCH (a:Author) WHERE a.name STARTS WITH "${searchString}" RETURN a.name AS name ORDER BY name LIMIT 5`)
  .then(makeHtmlUpdate)
  .catch(error => {
    console.log(error)
  })
  .then(() => session.close())

}

export default updateName;







