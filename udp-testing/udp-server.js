var SERVER_PORT = 33333;
var clientAddress = "192.168.1.1";
var clientPort = 30303;

var counter = 0;

var dgram = require('dgram');
var server = dgram.createSocket('udp4');


server.on('listening', function () {
	var address = server.address();
	console.log('UDP Server listening on ' + address.address + ":" + address.port);
});

server.on('message', function (message, remote) {
	console.log(remote.address + ':' + remote.port +' - ' + message);
	clientAddress = remote.address;
	clientPort = remote.port;
});

server.bind(SERVER_PORT);

var interval = setInterval( function() {
	counter++;

	var message = new Buffer(counter.toString());
	server.send(message, 0, message.length, clientPort, clientAddress, function(err, bytes) {
		if (err) throw err;
	});


}, 5);