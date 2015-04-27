import hypermedia.net.*;

String SERVER_HOST = "128.173.52.36";
int SERVER_PORT = 32392;
int CLIENT_PORT = 32392;

String ADD_STRING = "I am a supervisory HMI and want to monitor the Pendulum.";
String REMOVE_STRING = "Stop Streaming";

UDP udp;  // define the UDP object

int timestamp;
float [] stateVector = {0, 0, 0, 0};

float alpha = 0.0;
float theta = 0.0;

void setup(){
  udp = new UDP( this, CLIENT_PORT);  // create datagram connection on port 33335   
  //udp.log( true );            // <-- print out the connection activity
  udp.listen( true );           // and wait for incoming message
  
  size(500, 500);
  background(0);
  smooth();
  frameRate(25);
}

void draw(){
  fill(0, 120);
  rect(0, 0, width, height);
  
  translate(width/2, height/2);
  noFill();
  arc(0, 0, 300, 300, 0, PI);


  translate(150*sin(stateVector[0]), 150*cos(stateVector[0]));
   
  // Rotate and draw the pendulum
  rotate(-stateVector[1]-HALF_PI);
  drawPendulum();

}

void drawPendulum()
{
  // draw line
  stroke(255);
  strokeWeight(3);
  line(0, 0, 160, 0);
 
  // draw circle
  fill(255, 0, 0);
  stroke(255, 255, 0);
  strokeWeight(2);
  ellipse(160, 0, 25, 25);
}

void drawBase(){
  pushMatrix();
  translate(width/2,height/2+150,0);
  rotateX(-PI/6);
  rotateY(PI/3);
  fill(0);
  stroke(255);
  box(100,10,100);
  translate(0,-90,0);
  box(100,10,100);
  translate(0,90,0);
  translate(-45,-45,-45);
  box(10,80,10);
  translate(90,0,90);
  box(10,80,10);
  translate(-90,0,0);
  box(10,80,10);
  translate(90,0,-90);
  box(10,80,10);
  popMatrix(); 
  translate(width/2,height/2+50,0);
  rotateX(-PI/6);
  rotateY(PI/3);
  box(20,10,200);
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
