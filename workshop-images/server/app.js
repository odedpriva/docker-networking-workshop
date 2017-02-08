'use strict';

const http = require('http')
    , os = require('os');

const PORT=8000;

function handleRequest(request, response){

  let host = os.hostname();
  let resObj = JSON.stringify({hostName: host });
  response.writeHead(200, {'Content-Type': 'application/json'});
  response.end(resObj);

}
 
let server = http.createServer(handleRequest);

server.listen(PORT, function(){
  console.log('Server listening on: http://localhost:%s', PORT);
});