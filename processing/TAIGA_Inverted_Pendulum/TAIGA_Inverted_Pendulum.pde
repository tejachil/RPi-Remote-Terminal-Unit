import hypermedia.net.*;

String SERVER_HOST = "128.173.52.36";
int SERVER_PORT = 32392;
int CLIENT_PORT = 32392;

String ADD_STRING = "I am a supervisory HMI and want to monitor the Pendulum.";
String REMOVE_STRING = "Stop Streaming";

boolean addFlag = false;

UDP udp;  // define the UDP object

int timestamp;
float [] stateVector = {0, 0, 0, 0};

float alpha = 0.0;
float theta = 0.0;

String stateVectorString = "[0,0,0,0]";

float setPoint = -30;
String spString = "";

void setup(){
  String[] ip = loadStrings("http://icanhazip.com/");
  if(ip[0].equals(SERVER_HOST))  SERVER_HOST = "192.168.1.2";
  
  udp = new UDP( this, CLIENT_PORT);  // create datagram connection on port 33335   
  //udp.log( true );            // <-- print out the connection activity
  udp.listen( true );           // and wait for incoming message
  
  size(500, 500);
  background(0);
  smooth();
  frameRate(25);
}

void draw(){
  fill(120,120,120);
  rect(0, 0, width, height);
  
    
  translate(width/2, height/2);
  noFill();
  arc(0, 0, 300, 300, 0, PI);
  
  pushMatrix();
  arc(0, 0, 170, 170, PI/4, 3*PI/4);
  line(60, 60, 130, 130);
  line(-60, 60, -130, 130);
  line(0, 50, 0, 165);
  fill(255);
  textAlign(CENTER);
  textSize(18);
  text("TAIGA Rotary Inverted Pendulum Experiment", 0, 20-height/2);
  textSize(16);
  text("Press 'a' to add yourself to server and 'r' to remove.", 0, 50-height/2);
  text("Press 'x' to exit.", 0, 70-height/2);
  text(stateVectorString, 0, 100-height/2);
  text("45", 140, 145);
  text("-45", -145, 145);
  text('0', -1, 185);
  popMatrix();

  stroke(255,0,0);
  strokeWeight(2);
  line(0,0, 160*cos(radians(90-setPoint)), 160*sin(radians(setPoint+90)));
  fill(150,20,20);
  text("Set-Point = " + spString, 0, 140-height/2);
  fill(255);
  text("Drag read line and release to update setpoint", 0, 480-height/2);

  translate(150*sin(stateVector[0]), 150*cos(stateVector[0]));
   
  // Rotate and draw the pendulum
  pushMatrix();
  drawPendulum();
  popMatrix();
}

void drawPendulum(){
  rotate(-stateVector[1]-HALF_PI);
  // draw line
  stroke(0,0,255);
  strokeWeight(10);
  line(0, 0, 160, 0);
 
  // draw circle
  //fill(0, 0, 255);
  //stroke(255, 255, 0);
  strokeWeight(4);
  stroke(255);
  //ellipse(160, 0, 25, 25);
}


void keyPressed() {
  if(key == 'a' && addFlag == false){
    addFlag = true;
    udp.send(ADD_STRING, SERVER_HOST, SERVER_PORT);
  }
  if(key == 'r'){
    addFlag = false;
    udp.send(REMOVE_STRING, SERVER_HOST, SERVER_PORT);
  }
  if(key == 'x'){
    udp.send(REMOVE_STRING, SERVER_HOST, SERVER_PORT);
    exit();
  }
  if(key == '0'){
    udp.send("SP" + fromCharCode(34), SERVER_HOST, SERVER_PORT);
  }
}

void mouseDragged(){
  int x = mouseX-250;
  int y = mouseY-250; 
  
  if(y>0){
    setPoint = degrees(atan(1.0*x/y));
  }
}

void mouseReleased() {
  int spInt = (int)setPoint;
  spString = str(spInt);
  byte spCode = 0;
  spCode = (byte)(spInt);
  if(spInt < 0){
    spCode = (byte)(-spInt);
    spCode |= 0x80;
  }
  udp.send("SP" + fromCharCode((int)(0xFF & spCode)), SERVER_HOST, SERVER_PORT);
  //println("Sent the following SP command: " + (int)setPoint);
}


void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  String message = new String( data );
  timestamp =  Integer.parseInt(message.substring(0,message.indexOf(':')));
  message = message.substring(message.indexOf(':')+1, message.length());
  String [] statesStringArray;
  statesStringArray = split(message,',');
  stateVector = float(statesStringArray);
  stateVectorString = message;  
}

public static String fromCharCode(int... codePoints){
  return new String(codePoints, 0, codePoints.length);
}
