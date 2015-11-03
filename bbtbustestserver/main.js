var http = require('http');
var busCoordinater = require('./busCoordinater');

busCoordinater.start();

http.createServer(function(request, response) {
    response.writeHead(200, {
        "Content-Type": "application/json",
    });
    response.write(busCoordinater.busesData());
    response.end();
}).listen(6767)