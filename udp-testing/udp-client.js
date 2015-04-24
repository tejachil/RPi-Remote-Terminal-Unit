var SERVER_HOST = '128.173.52.36';
var SERVER_PORT = 32392;
var CLIENT_PORT = 32392;

var dgram = require('dgram');
var server = dgram.createSocket('udp4');

server.on('listening', function () {
	var address = server.address();
	console.log('UDP Server listening on ' + address.address + ":" + address.port);
	var messageText = "I want TAIGA data"
	var message = new Buffer(messageText);
	server.send(message, 0, message.length, SERVER_PORT, SERVER_HOST, function(err, bytes) {
		if (err) throw err;
	});
});

server.on('message', function (message, remote) {
	console.log(remote.address + ':' + remote.port +' - ' + message);
});

server.bind(CLIENT_PORT);
