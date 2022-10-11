
var ws = require('ws')

var server = new ws.Server({port:3000})

server.on('connection', server => {
    server.on('message', message => {
        let data = JSON.parse(message);
        console.log(data);
    });

    server.on('close', (code, reason) => {
        console.log(code, reason);
    });

    //for (var i = 0; i < 10000; i++) {
    server.send(JSON.stringify({"test": "Hello world"}));
    //}

});