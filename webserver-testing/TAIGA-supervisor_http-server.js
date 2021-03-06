var devTAIGA = "/dev/ttyUSB1";

var webserverPort = 8080;

var http = require("http");
var SerialPort = require("serialport")
var serialTAIGA = new SerialPort.SerialPort(devTAIGA, {
  baudrate: 921600, parser: SerialPort.parsers.readline("---\n", "binary")
}, false); // this is the openImmediately flag [default is true]

var stateVector = [];
var counter = 0;

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
    });
  }
});

http.createServer(function (request, response) {
  response.writeHead(200, {
    'Content-Type': 'text/plain'
  });
  response.write(counter+": "+stateVector.toString()+"\n")
  response.end();
}).listen(webserverPort);

// Keep a 1 ms counter that timestamps each webserver post
var interval = setInterval( function() {
  counter++;
  // following lines for debugging without serial port
  stateVector.length = 0;
  stateVector.push(1.2);
  stateVector.push(0.1);
  stateVector.push(0.7);
  stateVector.push(0.3);
}, 1);