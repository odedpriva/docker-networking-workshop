const http = require('http');

const PORT=8000;

function handleRequest(request, response){
  console.log(request.url);
  http.get('http://server:8000' + request.url, (res) => {
    if (res.statusCode !== 200) {
      response.end('response != 200 ' + res.statusCode);
    }
    res.setEncoding('utf8');
    let rawData = '';
    res.on('data', (chunk) => rawData += chunk);
    res.on('end', () => {
      try {
        // let parsedData = JSON.parse(rawData);
        response.end(rawData);
      } catch (e) {
        console.log(e.message);
      }
    });
  });
}

let server = http.createServer(handleRequest);

server.listen(PORT, function(){
  console.log('Server listening on: http://localhost:%s', PORT);
});