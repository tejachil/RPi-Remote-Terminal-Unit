import hypermedia.net.*;

String SERVER_HOST = "128.173.52.36";
int SERVER_PORT = 32392;
int CLIENT_PORT = 32392;

String ADD_STRING = "I am a supervisory HMI and want to monitor the Pendulum.";
String REMOVE_STRING = "Stop Streaming";
String CLEAR_FLAGS_STRING = "Clear all flags for reset.";
int GUARD_THETA_OP = 35;

boolean addFlag = false;

boolean offlineClassification = false;

UDP udp;  // define the UDP object

int timestamp;
float [] stateVector = {
  0, 0, 0, 0
};

float alpha = 0.0;
float theta = 0.0;

String stateVectorString = "[0,0,0,0]";

float setPoint = 0;
String spString = "";
String assertionFlag;
int limitLinesAngle = 90;

void setup() {
  String[] ip = loadStrings("http://icanhazip.com/");
  if (ip[0].equals(SERVER_HOST))  SERVER_HOST = "192.168.1.2";

  udp = new UDP( this, CLIENT_PORT);  // create datagram connection on port 33335   
  //udp.log( true );            // <-- print out the connection activity
  udp.listen( true );           // and wait for incoming message

    size(500, 500);
  background(0);
  smooth();
  frameRate(25);
}

void draw() {
  fill(120, 120, 120);
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

  text("Assertion Trigger State: " + assertionFlag, 0, 120-height/2);

  // Limit Lines
  stroke(200, 0, 0);
  strokeWeight(2);
  line(0, 0, 160*cos(radians(90-limitLinesAngle)), 160*sin(radians(limitLinesAngle+90)));
  line(0, 0, 160*cos(radians(90+limitLinesAngle)), 160*sin(radians(limitLinesAngle+90)));

  fill(200, 50, 50);
  if(offlineClassification)
    text("UNSAFE", 0, 150-height/2);

  // Set-Point Line
  stroke(0, 255, 0);
  strokeWeight(2);
  line(75*cos(radians(90-setPoint)), 75*sin(radians(setPoint+90)), 160*cos(radians(90-setPoint)), 160*sin(radians(setPoint+90)));
  fill(50, 200, 50);
  text("Set-Point = " + spString, 0, 200-height/2);
  fill(255);
  text("Drag green line and release to update setpoint", 0, 480-height/2);

  stroke(0);
  strokeWeight(4);
  line(0, 0, 150*sin(stateVector[0]), 150*cos(stateVector[0]));

  translate(150*sin(stateVector[0]), 150*cos(stateVector[0]));

  // Rotate and draw the pendulum
  pushMatrix();
  drawPendulum();
  popMatrix();
}

void drawPendulum() {
  rotate(-stateVector[1]-HALF_PI);
  // draw line
  stroke(0, 0, 255);
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
  if (key == 'a' && addFlag == false) {
    addFlag = true;
    udp.send(ADD_STRING, SERVER_HOST, SERVER_PORT);
  }
  if (key == 'r') {
    addFlag = false;
    udp.send(REMOVE_STRING, SERVER_HOST, SERVER_PORT);
  }
  if (key == 'x') {
    udp.send(REMOVE_STRING, SERVER_HOST, SERVER_PORT);
    exit();
  }
  if (key == '0') {
    udp.send("SP" + fromCharCode(34), SERVER_HOST, SERVER_PORT);
  }

}

void mouseDragged() {
  int x = mouseX-250;
  int y = mouseY-250; 

  if (y>0) {
    setPoint = degrees(atan(1.0*x/y));
  }
}

void mouseReleased() {
  int spInt = (int)setPoint;
  spString = str(spInt);
  byte spCode = 0;
  spCode = (byte)(spInt);
  byte [] sendBuff = {
    'S', 'P', ' '
  };
  if (spInt < 0) {
    spCode = (byte)(-spInt);
    spCode |= 0x80;
  }
  sendBuff[2] = spCode;

  udp.send(sendBuff, SERVER_HOST, SERVER_PORT);
}


void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  String message = new String( data );
  timestamp =  Integer.parseInt(message.substring(0, message.indexOf(':')));
  assertionFlag = message.substring(message.indexOf(';')+1, message.length());
  message = message.substring(message.indexOf(':')+1, message.indexOf(';'));
  String [] statesStringArray;
  statesStringArray = split(message, ',');
  stateVector = float(statesStringArray);
  stateVectorString = message;

  if(assertionFlag.equals("S") || assertionFlag.equals("W") || assertionFlag.equals("T") || assertionFlag.equals("G")){
    limitLinesAngle = GUARD_THETA_OP;
  }
  else limitLinesAngle = 90;
  
  offlineClassification = classifierAlgorithm();
}

public static String fromCharCode(int... codePoints) {
  return new String(codePoints, 0, codePoints.length);
}

public boolean classifierAlgorithm(){
  final float [][] H1= {
    {-2.787277607155044,3.1879217756709948,-1.5791951615800552,1.0961654476296883},
    {-0.044675648209836688,2.0305005948708592,-2.083588705941577,1.657454494577925},
    {2.0546104380250574,-2.1558751720327245,0.89696008899332513,2.8182628898215829},
    {0.25040063570810406,0.27391506650121789,-12.084781701018301,7.9300329456225409},
    {-0.83078219732224268,-0.66755885243429691,-0.58268189399600323,0.25552979769224915}
  };

  final float [] B1 = {3.2012907134520265,-0.42460186372608583,2.1651294814480067,3.3263951023017708,-1.3648819496731714};
  // Second Hidden Layer Calculation
  final float [] H2 = {11.58092258308573,-4.3982970255217744,-0.87874405966423919,12.958800887594947,5.1588060906122486};
  final float B2 = -8.2856337975078347;
  // Limits on Inputs xmax and xmin define the limit of actual data which is scaled between -1 and 1 specified by matlab
  final float [] xmin = {-0.17453292519943295,-0.26179938779914941,-3.0543261909900763,-1.7453292519943295};
  final float [] xmax = {0.52359877559829882,0.26179938779914941,2.5307274153917776,1.7453292519943295};
  final float ymax = 1;
  final float ymin = -1;
  /****** Classifier Constants End *****/

  final float out_max = 1, out_min = 0;

  float [] y = new float[4];
  float [] z = new float[5];
  float [] z_1 = new float[5];
  float p;
  float p_1;
  float result;

  float [] x = stateVector;

  int i = 0;
  // Solving for a given input
  for (i = 0; i < 4; ++i){
    y[i] = ((ymax - ymin)*(x[i]-xmin[i])/(xmax[i] - xmin[i]) + ymin);
  }

  for (i = 0; i <5; ++i){
    z[i] = H1[i][0]*y[0] + H1[i][1]*y[1] + H1[i][2]*y[2] + H1[i][3]*y[3] + B1[i];
    z_1[i] = 2/(1 + exp(-2*z[i])) - 1;
  }

  p = H2[0]*z_1[0] + H2[1]*z_1[1] + H2[2]*z_1[2] + H2[3]*z_1[3] + H2[4]*z_1[4] + B2;
  p_1 = 2/(1+exp(-2*p)) - 1;

  result = ((out_max - out_min)*(p_1-ymin)/(ymax - ymin) + out_min);


  if(result < 0.8){
    //println(result + "triggered");
    return true;
  }
  //println(result);
  return false; 
  
}

