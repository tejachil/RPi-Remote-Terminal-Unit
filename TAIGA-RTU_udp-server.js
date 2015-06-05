var SERVER_PORT = 32392; var DEV_TAIGA = "/dev/ttyUSB1";

var clients = [];

var counter = 0;

var dgram = require('dgram'); var server = dgram.createSocket('udp4');

var stateVector = [];

var triggerAsserted = false;

var ADD_STRING = 'I am a supervisory HMI and want to monitor the Pendulum.'
var REMOVE_STRING = 'Stop Streaming'
var SETPOINT_HEADER = 'SP'

// Setup Serial Port 
var SerialPort = require("serialport") 
var serialTAIGA = new SerialPort.SerialPort(DEV_TAIGA, {
  baudrate: 921600, parser: SerialPort.parsers.readline("--\n", "binary")
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
		stateVector.push(((data.charCodeAt(16)<< 24) | ((data.charCodeAt(17)&0xFF) << 16) | ((data.charCodeAt(18)&0xFF) << 8) | ((data.charCodeAt(19)&0xFF)))/10000);
		
		if(data.charAt(20) != 'P' && !triggerAsserted){
			console.log("Trigger Asserted by " + data.charAt(20));
			console.log(stateVector);
			triggerAsserted = true;
		}
		
		var message = new Buffer(counter.toString() + ':' + stateVector.toString() + ';' + data.charAt(20));
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
	var client = [remote.address, remote.port]
	if(message.toString().indexOf(ADD_STRING) > -1){		
		console.log('Adding '+ remote.address + ':' + remote.port);
		clients.push(client);
	}
	else if(message.toString().indexOf(REMOVE_STRING) > -1){
		console.log('Removing ' + remote.address + ':' + remote.port);
		clients.splice(clients.indexOf(client), 1);
	}
	else if(message.toString().indexOf(SETPOINT_HEADER) > -1){
		console.log('New set-point command relayed to PLC')
		serialTAIGA.write(message.toString());
	}
});

server.bind(SERVER_PORT);

var interval = setInterval( function() {
	counter++;
}, 1);
