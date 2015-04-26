import hypermedia.net.*;

String SERVER_HOST = "192.168.2.108";//'128.173.52.36';
int SERVER_PORT = 32392;
int CLIENT_PORT = 32392;

String ADD_STRING = "I am a supervisory HMI and want to monitor the Pendulum.";
String REMOVE_STRING = "Stop Streaming";

UDP udp;  // define the UDP object

int timestamp;
float [] stateVector;

void setup(){
  udp = new UDP( this, CLIENT_PORT);  // create datagram connection on port 33335   
  //udp.log( true );            // <-- print out the connection activity
  udp.listen( true );           // and wait for incoming message
  
  size(360, 360);
  background(0);
  smooth();
  frameRate(25);
}

void draw(){
  
}

void keyPressed() {
  if(key == 'a'){
    udp.send(ADD_STRING, SERVER_HOST, SERVER_PORT);
  }
  if(key == 'r'){
    udp.send(REMOVE_STRING, SERVER_HOST, SERVER_PORT);
  }
  if(key == 'x'){
    exit();
  }
}

void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  String message = new String( data );
  timestamp =  Integer.parseInt(message.substring(0,message.indexOf(':')));
  message = message.substring(message.indexOf(':')+1, message.length());
  String [] statesStringArray;
  statesStringArray = split(message,',');
  stateVector = float(statesStringArray);
}
