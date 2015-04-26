var SERVER_HOST = '192.168.2.108'//'128.173.52.36';
var SERVER_PORT = 32392;
var CLIENT_PORT = 32392;

var ADD_STRING = 'I am a supervisory HMI and want to monitor the Pendulum.'
var REMOVE_STRING = 'Stop Streaming'

var dgram = require('dgram');
var server = dgram.createSocket('udp4');

var stdin = process.stdin;

server.on('listening', function () {
	var address = server.address();
	console.log('UDP Server listening on ' + address.address + ":" + address.port);
});

server.on('message', function (message, remote) {
	console.log(remote.address + ':' + remote.port +' - ' + message);
});

server.bind(CLIENT_PORT);

stdin.setRawMode(true);

stdin.on('readable', function () {
  var key = String(process.stdin.read());
  if(key == 'a'){
  	var message = new Buffer(ADD_STRING);
  	server.send(message, 0, message.length, SERVER_PORT, SERVER_HOST, function(err, bytes) {
		if (err) throw err;
	});
  }
  if(key == 'r'){
  	var message = new Buffer(REMOVE_STRING);
  	server.send(message, 0, message.length, SERVER_PORT, SERVER_HOST, function(err, bytes) {
		if (err) throw err;
	});
  }
  if(key == 'x'){
  	process.exit();
  }

  console.log(key);
});