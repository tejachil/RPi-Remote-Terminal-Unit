var SERVER_PORT = 32392; var DEV_TAIGA = "/dev/ttyUSB1";

var clients = [];

var counter = 0;

var dgram = require('dgram'); var server = dgram.createSocket('udp4');

var stateVector = [];

// Setup Serial Port 
var SerialPort = require("serialport") 
var serialTAIGA = new SerialPort.SerialPort(DEV_TAIGA, {
  baudrate: 921600, parser: SerialPort.parsers.readline("---\n", 
"binary")
}, false); // this is the openImmediately flag [default is true]

serialTAIGA.open(function (error) {
  if ( error ) {
    console.log(error);
  } 
  else {
    console.log('Sucessfully opened Serial Port');
    serialTAIGA.on('data', function(data) {
		stateVector.length = 0;
		stateVector.push(((data.charCodeAt(0)<< 24) | ((data.charCodeAt(1)&0xFF) << 16) | ((data.charCodeAt(2)&0xFF) << 8) | ((data.charCodeAt(3)&0xFF)))/10000);
		stateVector.push(((data.charCodeAt(4)<< 24) | ((data.charCodeAt(5)&0xFF) << 16) | ((data.charCodeAt(6)&0xFF) << 8) | ((data.charCodeAt(7)&0xFF)))/10000);
		stateVector.push(((data.charCodeAt(8)<< 24) | ((data.charCodeAt(9)&0xFF) << 16) | ((data.charCodeAt(10)&0xFF) << 8) | ((data.charCodeAt(11)&0xFF)))/1000);
		stateVector.push(((data.charCodeAt(12)<< 24) | ((data.charCodeAt(13)&0xFF) << 16) | ((data.charCodeAt(14)&0xFF) << 8) | ((data.charCodeAt(15)&0xFF)))/1000);
		console.log(stateVector);
		
		var message = new Buffer(counter.toString() + ':' + stateVector.toString());

		for(var i = 0; i < clients.length; i++){
			server.send(message, 0, message.length, clients[i][1], clients[i][0], function(err, bytes) {
				if (err) throw err;
			});
		}
    });
  }
});


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
	
	// following lines for debugging without serial port
	stateVector.length = 0;
	stateVector.push(1.2);
	stateVector.push(0.1);
	stateVector.push(0.7);
 	stateVector.push(0.3);
	var message = new Buffer(counter.toString() + ':' + stateVector.toString());
		for(var i = 0; i < clients.length; i++){
			server.send(message, 0, message.length, clients[i][1], clients[i][0], function(err, bytes) {
				if (err) throw err;
			});
		}
}, 1);
