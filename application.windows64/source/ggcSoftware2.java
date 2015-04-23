import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import java.io.PrintWriter; 
import java.io.IOException; 
import java.nio.file.Path; 
import java.io.BufferedWriter; 
import java.io.FileInputStream; 
import java.io.InputStreamReader; 
import java.io.FileWriter; 
import java.io.IOException; 
import controlP5.*; 
import peasy.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ggcSoftware2 extends PApplet {













//Global Variables
final PFont ARIAL_BOLD_12 = createFont("Arial Bold", 12);
final PFont ARIAL_BOLD_18 = createFont("Arial Bold", 18);
final PFont ARIAL_BOLD_8 = createFont("Arial Bold", 8);
final PFont ARIAL_12 = createFont("Arial", 10);
int colorDarkBlue = 0xff02344d;
int colorRed = 0xffFC0000;
int colorDarkRed = 0xffcc0000;
int colorBackground = 0xffeeeee7;
int colorGreen = 0xff009100;
int colorPurple = 0xff74009E;
int colorOrange = 0xffFF6A00;
PImage fai_iconi;
PGraphics fai_icong;
String fai_filename;


int[] controlValue = {
  0, 0, 0, 0, 0, 0
};
int[] controlActive = {
  0, 0, 0, 0, 0
};
int[] command = {
  0, 0, 0, 0
}; //left,right,forward,backward
boolean flag = true;
boolean configureFlex = false;
ControlP5 MyController;
ControlP5 MyCheckbox;
CheckBox checkbox;
Button[] toggleButton;
Button plotButton;
Button saveButton;
Button restState;
Button activeState;
String stateMessage = "";
int timeoutClick = 10000;

//Serial Communication Variables
Serial port;
String portname = Serial.list()[0];
String newString = "";
int[] lastRead = {
  90, 90, 90, 90, 90, 45, 45, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1
};
int baudrate = 115200;
int Thumb = 20;
int Index = 20;
int Middle = 20;
int Ring = 20;
int Pinky = 20;
int GyroLeft = 60;
int GyroRight = 60;
boolean FThumb = false;
boolean FIndex = true;
boolean FMiddle = true;
boolean FRing = true;
boolean FPinky = true;
boolean BThumb = true;
boolean BIndex = true;
boolean BMiddle = true;
boolean BRing = true;
boolean BPinky = true;
boolean arduinoOnline = true;
boolean setupFlag = true;
boolean currentlyPlotting = false;
boolean stopSerial = false;
String[] testSerial = {
  "value", "100", "100", "100", "100", "100", "-1", "active", "1", "1", "1", "1", "1", "command", "0", "0", "0", "1"
};
String[] serialArray = {
  "value", "100", "100", "100", "100", "100", "-1", "active", "1", "1", "1", "1", "1", "command", "0", "0", "0", "1"
};
String[] savedThresholds = {
  "0", "0", "0", "0", "0"
};

//Data Plotting Variables
double startTime = 0;
double lastTime = 0;
double currentTime = 0;
boolean plotDataFlag = false;
int[] flex0Data = new int[100]; 
int[] flex1Data = new int[100]; 
int[] flex2Data = new int[100]; 
int[] flex3Data = new int[100]; 
int[] flex4Data = new int[100];
double[] gyroData = new double[100];
double[] time = new double[100];
String plotText = "Start Plot";
String outFileName = "";
boolean setActive = false;
boolean setRest = false;
int[] rawFlex = {
  0, 0, 0, 0, 0
};

//FileIO Variables  

public void setup()
{
  frameAndIcon("", "icon.png");
  //Initial Window Settings
  size(1200, 600);
  frameRate(25);
  background(colorBackground);
  smooth();
  strokeCap(ROUND);
  frame.setTitle("Gesture Glove Calibration");

  //Initial Setup
  setupPort();
  readSavedThresholds();
  initializeInteractiveObjects();
  prepareExitHandler();
}

public void draw()
{ 
  int start = millis();
  background(colorBackground);
  updateWindow(); //Update window elements

  if (plotDataFlag)
  {
    plotData();
  }

  if (arduinoOnline)
  {
    while (port.available () > 2)
    {
      serialEvent(port.readStringUntil('$'));   
      if (stopSerial) {
        stopSerial = false; 
        break;
      }
    }
    outputToArduino();
  } else
  {
    setupPort();
  }
  // println("LoopTime: " + (millis() - start));
}

private void prepareExitHandler () {

  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {

    public void run () {

      println("Shutdown and save threshold values");
      String text = "" + Thumb + "\n" + Index + "\n" + Middle + "\n" + Ring + "\n" + Pinky + "\n" +
                    GyroLeft + "\n" + GyroRight  + "\n" + 
                    (FThumb ? 1: 0) + "\n" + (FIndex ? 1: 0) + "\n" + (FMiddle ? 1: 0) + "\n" + (FRing ? 1: 0) + "\n" + (FPinky ? 1: 0) + "\n" + 
                    (BThumb ? 1: 0) + "\n" + (BIndex ? 1: 0) + "\n" + (BMiddle ? 1: 0) + "\n" + (BRing ? 1: 0 ) + "\n" + (BPinky ? 1: 0);
      // application exit code here
      File f = new File(dataPath(System.getenv("APPDATA") + "\\ggc\\flex2.thresh"));
      
      File parentDir = f.getParentFile();
      try{
        parentDir.mkdirs(); 
        f.createNewFile();
      }catch(Exception e){
        e.printStackTrace();
      }
      
      try {
      PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, false)));
      out.println(text);
      out.close();
      }catch (IOException e){
        e.printStackTrace();
      }
      
      
    }
  }
  ));
}


public void setupPort()
{
  println(portname);
  try {
    port = new Serial(this, portname, baudrate);
    arduinoOnline = true;
  }
  catch(RuntimeException e) {
    arduinoOnline = false;
    println("Port is busy or offline");
  }

  if (arduinoOnline)
  {  
    //Send initial EEPROM values
    String commandOutput = "@@" + (FThumb ? 1 : 0) + (FIndex? 1 : 0) + (FMiddle? 1 : 0) + (FRing ? 1 : 0) + (FPinky ? 1 : 0) + (BThumb ? 1 : 0) + (BIndex? 1 : 0) + (BMiddle? 1 : 0) + (BRing? 1 : 0) + (BPinky? 1 : 0) + "$";
    port.write(commandOutput);

    String outputGyro = "##" + abs(GyroLeft) + abs(GyroRight) + "$";
    port.write(outputGyro);

    String outputFlex = "!!" + (100-Thumb) + (100-Index) + (100-Middle) + (100-Ring) + (100-Pinky) + "$";
    port.write(outputFlex);
  }
}

public static void sleep(int amt) // In milliseconds
{
  long a = System.currentTimeMillis();
  long b = System.currentTimeMillis();
  while ( (b - a) <= amt)
  {
    b = System.currentTimeMillis();
  }
}


public void frameAndIcon(String frameText, String iconFilename) {
  if ( fai_filename == null || !fai_filename.equals(iconFilename) ) {
    fai_iconi = loadImage(iconFilename);
    fai_icong = createGraphics(256, 256, JAVA2D);
    fai_filename = iconFilename;
  }
  frame.setTitle( frameText );
  fai_icong.beginDraw();
  fai_icong.image( fai_iconi, 0, 0 );
  fai_icong.endDraw();
  frame.setIconImage(fai_icong.image);
}

public void readSavedThresholds()
{
  String location = System.getenv("APPDATA") + "\\ggc\\flex2.thresh";
  println(location);
  
  String[] lines = new String[17]; //<>//
 try{
  FileInputStream fstream = new FileInputStream(location); //<>//
  BufferedReader br = new BufferedReader(new InputStreamReader(fstream));

  String line;

//Read File Line By Line
int i = 0;
while ((line = br.readLine()) != null)   {
  // Print the content on the console
  lines[i] = line; i++;
}

//Close the input stream
br.close();

    
    Thumb = Integer.parseInt(lines[0]);
    Index = Integer.parseInt(lines[1]);
    Middle = Integer.parseInt(lines[2]);
    Ring = Integer.parseInt(lines[3]);
    Pinky = Integer.parseInt(lines[4]);
    GyroLeft = Integer.parseInt(lines[5]);
    GyroRight = Integer.parseInt(lines[6]);
    FThumb = Integer.parseInt(lines[7]) == 1;
    FIndex = Integer.parseInt(lines[8]) == 1;
    FMiddle = Integer.parseInt(lines[9]) == 1;
    FRing = Integer.parseInt(lines[10]) == 1;
    FPinky = Integer.parseInt(lines[11]) == 1;
    BThumb = Integer.parseInt(lines[12]) == 1;
    BIndex = Integer.parseInt(lines[13]) == 1;
    BMiddle = Integer.parseInt(lines[14]) == 1;
    BRing = Integer.parseInt(lines[15]) == 1;
    BPinky = Integer.parseInt(lines[16]) == 1;

}catch(IOException e){}

} 
class Button  {    

  // Button location and size
  float x;   
  float y;   
  float w;   
  float h;   
  // Is the button on or off?
  boolean on; 
  int colorOn;
  int colorOff; 
  float weight = .5f;

  // Constructor initializes all variables
  Button(float tempX, float tempY, float tempW, float tempH, int CON, int COFF, boolean logic, float W)  {    
    x  = tempX;   
    y  = tempY;   
    w  = tempW;   
    h  = tempH;   
    on = logic;  // Button always starts as off
    colorOn = CON;
    colorOff = COFF;
    weight = W;
  }   
 
   Button(float tempX, float tempY, float tempW, float tempH, int CON, int COFF, boolean logic)  {    
    x  = tempX;   
    y  = tempY;   
    w  = tempW;   
    h  = tempH;   
    on = logic;  // Button always starts as off
    colorOn = CON;
    colorOff = COFF;
  }  

  public boolean click(int mx, int my) {
    // Check to see if a point is inside the rectangle
    if (mx > x && mx < x + w && my > y && my < y + h) {
      on = !on;
      return true;
    }
    else
      return false;
  }

  // Draw the rectangle
  public void display() {
    rectMode(CORNER);
    strokeWeight(weight);
    stroke(colorDarkBlue);
    // The color changes based on the state of the button
    if (on) {
      fill(colorOn);
    } else {
      fill(colorOff);
    }
    rect(x,y,w,h);
    fill(colorDarkBlue);
  }
  
} 
  // appendTextToFile(outFilename,serialArray[1] + "," + serialArray[2] + "," + serialArray[3]  + "," + serialArray[4]  + "," + serialArray[5]);

public void appendTextToFile(String filename, String text){
  File f = new File(dataPath(filename));
  if(!f.exists()){
    createFile(f);
  }
  try {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(text);
    out.close();
  }catch (IOException e){
      e.printStackTrace();
  }
}

/**
 * Creates a new file including all subfolders
 */
public void createFile(File f){
  File parentDir = f.getParentFile();
  try{
    parentDir.mkdirs(); 
    f.createNewFile();
  }catch(Exception e){
    e.printStackTrace();
  }
} 

public void updateWindow()
{
  toggleColors();
  refreshConstantElements();
  updateMovingElements();

  
  int[] thresholdArray = {
    100-Thumb, 100-Index, 100-Middle, 100-Ring, 100-Pinky, GyroLeft, GyroRight
  };
  
  
  if (testSerial.length >= 18)
  {
    serialArray = testSerial;
  }
  

  // Flex Sensors
  for (int i = 1; i < 7; i++)
  {
    if (i < 6)
    {
      textFont(ARIAL_BOLD_12);
      fill(colorDarkBlue);
      fill(colorRed);
      
        text(thresholdArray[i-1], i*50 + 35, 85);
        
      fill(colorDarkBlue);
      text(PApplet.parseInt(serialArray[i]), i*50 + 35, 115);
      if (PApplet.parseInt(serialArray[i]) > thresholdArray[i-1])
      {
        stroke(colorRed);
      }
      else
      {
        stroke(colorDarkBlue);
      }
      line(i*50 + 30, 200 + 2*(PApplet.parseInt(serialArray[i])-40), i*50 + 25 + 35, 200 + 2*(PApplet.parseInt(serialArray[i])-40));
      controlValue[i-1] = PApplet.parseInt(serialArray[i]);
    } else if (i == 6)
    {

      float theta = -PApplet.parseInt(serialArray[i])*3.1415f/180;
      float x0 = 175;
      float y0 = 500;
      float r = 80;
      float x1 = x0 - r*cos(theta);
      float y1 = y0 + r*sin(theta);
      float x2 = x0 + r*cos(theta);
      float y2 = y0 - r*sin(theta);

      stroke(colorDarkBlue);
      text("Value: " + serialArray[i], 140, 390);
      if(PApplet.parseInt(serialArray[i]) < -thresholdArray[i] || PApplet.parseInt(serialArray[i]) > thresholdArray[i-1])
      {
        stroke(colorDarkRed);
      }
      else
      {
        stroke(colorDarkBlue); 
      }
      line(x1, y1, x2, y2);

      fill(colorRed);
      stroke(colorRed);
      theta = PApplet.parseInt(GyroRight)*3.1415f/180;
      x2 = x0 + r*cos(theta);
      y2 = y0 - r*sin(theta);
      line(x0, y0, x2, y2);

      theta = PApplet.parseInt(-GyroLeft)*3.1415f/180;
      x1 = x0 - r*cos(theta);
      y1 = y0 + r*sin(theta);
      line(x0, y0, x1, y1);

      text(GyroLeft, 10, 400);
      text(-GyroRight, 325, 400);
    }
  }

  for (int i = 8; i < 13; i++)
  {
    controlActive[i-8] = Integer.parseInt(serialArray[i]);
  }


  for (int i = 14; i < 18; i++)
  {
    command[i-14] = Integer.parseInt(serialArray[i].substring(0, 1));
  }




  if (command[0] == 1)
  {
    stroke(colorRed);
    arrow(590, 390, 490, 390); //Left Arrow
    stroke(colorDarkBlue);
    arrow(610, 390, 710, 390); //Right Arrow
  } else if (command[1] == 1)
  {
    stroke(colorDarkBlue);
    arrow(590, 390, 490, 390); //Left Arrow
    stroke(colorRed);
    arrow(610, 390, 710, 390); //Right Arrow
    stroke(colorDarkBlue);
  } else 
  {
    stroke(colorDarkBlue);
    arrow(590, 390, 490, 390); //Left Arrow
    arrow(610, 390, 710, 390); //Right Arrow
  }

  if (command[2] == 1)
  {
    stroke(colorRed);
    arrow(600, 380, 600, 280); //Forward Arrow
    stroke(colorDarkBlue);
    arrow(600, 400, 600, 500); //Backward Arrow
  } else if (command[3] == 1)
  {
    stroke(colorRed);
    arrow(600, 400, 600, 500); //Backward Arrow
    stroke(colorDarkBlue);
    arrow(600, 380, 600, 280); //Forward Arrow
  } else 
  {
    stroke(colorDarkBlue);
    arrow(600, 400, 600, 500); //Backward Arrow
    arrow(600, 380, 600, 280); //Forward Arrow
  }


  // Warning Message
  boolean[] checkBack = {
    BThumb, BIndex, BMiddle, BRing, BPinky
  };
  boolean[] checkFor = {
    FThumb, FIndex, FMiddle, FRing, FPinky
  };
  boolean goodControls = true;
  
//  println(FThumb);
  for (int i = 0; i < 5; i++)
  {
    
    if (checkBack[i] == checkFor[i])
    {
      goodControls = false;
    }
    else
    {
      goodControls = true;
      break;
    }
  }
  
  String warning = "Warning";
  
  if(goodControls)
    warning = "";
  else
    warning = "Warning: Forward and backward control schemes are not compatible.";

  fill(colorRed);
  text(warning, 400, 180);
  fill(colorDarkBlue);
  
  //Create this as a function
  toggleButton[0].display();
  toggleButton[1].display();
  toggleButton[2].display();
  toggleButton[3].display();
  toggleButton[4].display();
  toggleButton[5].display();
  plotButton.display();
  
  drawPlot();
  
}

public void arrow(int x1, int y1, int x2, int y2) {
  line(x1, y1, x2, y2);
  pushMatrix();
  translate(x2, y2);
  float a = atan2(x1-x2, y2-y1);
  rotate(a);
  line(0, 0, -10, -10);
  line(0, 0, 10, -10);
  popMatrix();
} 

public static Integer tryParse(String text) {
  try {
    return new Integer(text);
  } 
  catch (NumberFormatException e) {
    return null;
  }
}

public void toggleColors()
{
  if(!arduinoOnline)
  {
    colorRed = 0xff7e7e7e;
    colorDarkRed = 0xff3f3f3f;
    colorDarkBlue = 0xff696969;
    MyController
    .setColorForeground(colorRed)
        .setColorActive(colorDarkRed);
    MyCheckbox
      .setColorForeground(color(colorDarkBlue))
        .setColorActive(color(colorRed));
    plotButton.colorOn = 0xff696969;
    for(int i = 0; i < 6; i++)
    {
      toggleButton[i].colorOn = 0xff696969;
    }
  }
  else
  {
    colorDarkBlue = 0xff02344d;
    colorRed = 0xffFC0000;
    colorDarkRed = 0xffcc0000;
    MyController
    .setColorForeground(colorRed)
        .setColorActive(colorDarkRed);
    MyCheckbox
      .setColorForeground(color(colorDarkBlue))
        .setColorActive(color(colorRed));
    toggleButton[0].colorOn = colorDarkBlue;
    toggleButton[1].colorOn = colorRed;
    toggleButton[2].colorOn = colorGreen;
    toggleButton[3].colorOn = colorPurple;
    toggleButton[4].colorOn = colorOrange;
    toggleButton[5].colorOn = colorRed;
    
  }
  
}

public void refreshConstantElements()
{
    
    //Configure rest state
    restState.display();    
    textAlign(CENTER);
    textSize(10);
    textLeading(12);
    text("Set Rest\n State",restState.x + restState.w/2, restState.y + restState.h/2);
    if(millis() - timeoutClick > 3000)
    {
      stateMessage = "";
    }
    
    fill(colorRed);
    text(stateMessage,40,260);
    
    //Configure active state
    activeState.display();
    textAlign(CENTER);
    textSize(10);
    textLeading(10);
    text("Set Active\n State",activeState.x + activeState.w/2, activeState.y + activeState.h/2);
    
    
    
    
    textAlign(CENTER);
    textFont(ARIAL_12);
   
  
    strokeWeight(3);
    stroke(colorDarkBlue);
    textFont(ARIAL_BOLD_12);
    
    textAlign(CENTER);
    textFont(ARIAL_12);
    

    strokeWeight(3);
    stroke(colorDarkBlue);
    line(95,25,95,5);
    line(5,23,5,5);
    line(5,5,95,5);
    

    textFont(ARIAL_BOLD_12);
    text("Flex Inputs", 50, 20);
    
  textAlign(LEFT);
  stroke(colorDarkBlue);
  fill(colorDarkBlue);
  
  //Draw Boarders
  noFill(); 
  strokeWeight(3); 
  stroke(colorDarkBlue);
  rect(5, 25, 350, 310);
  rect(5, 362, 350, 235);
  rect(375, 25, 450, 140);
  rect(375, 205, 450, 390);
  
  //Finger Inputs Sections
  fill(colorDarkBlue);
  textFont(ARIAL_BOLD_12);
  strokeWeight(5);
  fill(colorDarkBlue);
  
  {
  text("Value:", 10, 115); 
  fill(colorRed);
  text("Threshold:", 10, 85);
  String[] nameArray = {"Thumb", "Index", "Middle", "Ring", "Pinky", "Gyro"};
  textFont(ARIAL_BOLD_12);
  fill(colorDarkBlue);
  
  for (int i = 0; i < 5; i++)
  {
  text(nameArray[i], i*50 + 85, 60); 
  }
  
  }
  //Gyro Input Section
  fill(colorDarkBlue);
  text("Gyro Input", 13, 357);
  
  //Control Scheme Section
  fill(colorDarkBlue);
  text("Control Scheme", 380, 20);
  text("Forward", 390, 75);
  text("Backward", 390, 132);
  text("Thumb", 450, 40);
  text("Index", 525, 40);
  text("Middle", 590, 40);
  text("Ring", 665, 40);
  text("Pinky", 735, 40);
  
  //Outputs Section
  text("Outputs", 380, 200);
  textFont(ARIAL_BOLD_18);
  stroke(colorDarkBlue);
  text("Backward", 560, 535);
  text("Forward", 565, 250);  
  text("Left", 430, 395);
  text("Right", 735, 395);
  textFont(ARIAL_BOLD_12);
  
  //Add Different Tabs
  stroke(colorDarkBlue);
  strokeWeight(3);
  noFill();
  rect(5,344,80,18);
  rect(375,5,110,20);
  rect(375,185,55,20);
  
  
}

public void updateMovingElements()
{
  //Connection State Text
  String connectionStatus = "Status: ";
  connectionStatus += (arduinoOnline) ?  "Online" : "Offline";
  textFont(ARIAL_BOLD_18);
  text(connectionStatus, 850,30);
  
  
  
  
}
public void initializeInteractiveObjects()
{
  MyCheckbox = new ControlP5(this); //Checkboxes for control scheme setup
  MyController = new ControlP5(this); //Sliders for flex and gyro threshold values
  toggleButton = new Button[6];
  plotButton = new Button(1080,50,70,20,colorBackground,colorBackground,false,2);
  restState = new Button(14,138,60,30,colorBackground,colorBackground,false,2);
  activeState =  new Button(14,178,60,30,colorBackground,colorBackground,false,2);



  //Setup Control Sliders
  MyController.addSlider("Thumb", 0, 100, Thumb, 50+35, 120, 20, 200)
    .setColorForeground(colorRed)
      .setLabelVisible(false)
        .setColorActive(colorDarkRed);

  MyController.addSlider("Index", 0, 100, Index, 100+35, 120, 20, 200)
    .setColorForeground(colorRed)
      .setLabelVisible(false)
        .setColorActive(colorDarkRed);

  MyController.addSlider("Middle", 0, 100, Middle, 150+35, 120, 20, 200)
    .setColorForeground(colorRed)
      .setLabelVisible(false)
        .setColorActive(colorDarkRed);

  MyController.addSlider("Ring", 0, 100, Ring, 200+35, 120, 20, 200)
    .setColorForeground(colorRed)
      .setLabelVisible(false)
        .setColorActive(colorDarkRed);

  MyController.addSlider("Pinky", 0, 100, Pinky, 250+35, 120, 20, 200)
    .setColorForeground(colorRed)
      .setLabelVisible(false)
        .setColorActive(colorDarkRed);

  MyController.addSlider("GyroRight", 0, 90, 45, 330, 410, 20, 180)
    .setColorForeground(colorRed)
      .setLabelVisible(false)
        .setColorActive(colorDarkRed);

  MyController.addSlider("GyroLeft", 0, 90, 45, 10, 410, 20, 180)
    .setColorForeground(colorRed)
      .setLabelVisible(false)
        .setColorActive(colorDarkRed);

  checkbox = MyCheckbox.addCheckBox("checkBox")
    .setPosition(450, 50)
      .setColorForeground(color(colorDarkBlue))
        .setColorActive(color(colorRed))
            .setSize(40, 40)
            .setColorLabel(colorBackground)
              .setItemsPerRow(5)
                .setSpacingColumn(30)
                  .setSpacingRow(20)
                    .addItem("FThumb", 0)
                      .addItem("FIndex", 50)
                        .addItem("FMiddle", 100)
                          .addItem("FRing", 150)
                            .addItem("FPinky", 200)
                              .addItem("BThumb", 0)
                                .addItem("BIndex", 50)
                                  .addItem("BMiddle", 100)
                                    .addItem("BRing", 150)
                                      .addItem("BPinky", 200)
                                        ; 
      int spacing = 60; int w = 20; int h = 10;                       
      toggleButton[0] = new Button(850,320,w,h,colorDarkBlue,colorBackground,true);
      toggleButton[1] = new Button(850 + 1*spacing,320,w,h,colorRed,colorBackground,true);
      toggleButton[2] = new Button(850 + 2*spacing,320,w,h,colorGreen,colorBackground,true);
      toggleButton[3] = new Button(850 + 3*spacing,320,w,h,colorPurple,colorBackground,true);
      toggleButton[4] = new Button(850 + 4*spacing,320,w,h,colorOrange,colorBackground,true);
      toggleButton[5] = new Button(850,580,w,h,colorRed,colorBackground,true);

      

}
public void startPlot()
{
  if(plotButton.on)
  {
   textFont(ARIAL_BOLD_8);
   plotDataFlag = true;
   plotText = "Save Plot";
   startTime = millis();
  }
  else
  {
    plotDataFlag = false;
    plotText = "Start Plot";
    currentlyPlotting = false;
    currentTime = 0.0f;
  }
}




public void drawPlot()
{
  //Setup Axis for Flex
  strokeWeight(2);
  text("Finger Motion Plot", 850, 90);

  rotate(3.1415f/2);
  text("Value",200,-835);
  rotate(-3.1415f/2);
  
  textSize(8);
  text(Double.toString(currentTime/1000),1160,300);
  textSize(12);
  
  line(850,300,1150,300); //x axis
  line(850,300,850,100);  //y axis
  textFont(ARIAL_BOLD_8);
  int spacing = 60;
  text("Thumb",875,329);
  text("Index",875 + spacing,329);
  text("Middle",875 + spacing*2,329);
  text("Ring",875 + spacing*3,329);
  text("Pinky",875 + spacing*4,329);
  
  //Setup Axis for Gyro
  textFont(ARIAL_BOLD_12);
  strokeWeight(2);
  text("Tilt Plot", 850, 350);
 
  rotate(3.1415f/2);
  text("Degrees",430,-835);
  rotate(-3.1415f/2);

  
  textSize(8);
  text(Double.toString(currentTime/1000),1160,460);
  textSize(12);
  
  line(850,460,1150,460); //x axis
  line(850,560,850,360);  //y axis
  textFont(ARIAL_BOLD_8);
  text("Tilt",875,590);
  
  textAlign(CENTER);
  text(plotText,1035+80,62);
  textAlign(LEFT);
}

public void plotData()
{
  
  currentTime = millis() - startTime;
 // println(currentTime);
  
  if(!currentlyPlotting)
  { //initalize file
    outFileName = "testData" + month() + "." + day() + "." + year() + "." + hour() + minute() + second() + ".csv";
    appendTextToFile(outFileName, "time,flex0,flex1,flex2,flex3,flex4,gyro");
    currentlyPlotting = true;
  }
  
    text("File will be saved to: " + outFileName, 850,70);
    String fileOutput = "" + currentTime/1000;
    
    for (int i = 0; i < 6; i++)
    {
     
     fileOutput += "," + serialArray[i+1];
    }
    
    appendTextToFile(outFileName, fileOutput);
  
  textSize(8);
  text(Double.toString(currentTime/1000),1160,300);
  textSize(12);
  
  for(int i = 0; i < flex0Data.length - 1; i++)
  {
   flex0Data[i] = flex0Data[i + 1]; 
   flex1Data[i] = flex1Data[i + 1]; 
   flex2Data[i] = flex2Data[i + 1]; 
   flex3Data[i] = flex3Data[i + 1]; 
   flex4Data[i] = flex4Data[i + 1];
   gyroData[i] = gyroData[i+1]; 
   time[i] = time[i + 1];
  }
   flex0Data[flex0Data.length - 1] = PApplet.parseInt(serialArray[1]);
   flex1Data[flex0Data.length - 1] = PApplet.parseInt(serialArray[2]);
   flex2Data[flex0Data.length - 1] = PApplet.parseInt(serialArray[3]);
   flex3Data[flex0Data.length - 1] = PApplet.parseInt(serialArray[4]);
   flex4Data[flex0Data.length - 1] = PApplet.parseInt(serialArray[5]);
   gyroData[flex0Data.length - 1] = Double.parseDouble(serialArray[6]);
   time[time.length - 1] = currentTime;
  
  strokeWeight(1);
  for(int i = 0; i < flex0Data.length - 1; i++)
  { 
    if(toggleButton[0].on)
    {
    stroke(colorDarkBlue);
    line(850 + i*3, 300 - 2*flex0Data[i], 850 + (i+1)*3, 300 - 2*flex0Data[i+1]);
    }
    
    if(toggleButton[1].on)
    {
    stroke(colorRed);
    line(850 + i*3, 300 - 2*flex1Data[i], 850 + (i+1)*3, 300 - 2*flex1Data[i+1]);
    }
    
    if(toggleButton[2].on)
    {
    stroke(0xff009100);
    line(850 + i*3, 300 - 2*flex2Data[i], 850 + (i+1)*3, 300 - 2*flex2Data[i+1]);
    }
    
    if(toggleButton[3].on)
    {
    stroke(0xff74009E);
    line(850 + i*3, 300 - 2*flex3Data[i], 850 + (i+1)*3, 300 - 2*flex3Data[i+1]);
    }
    
    if(toggleButton[4].on)
    {
    stroke(0xffFF6A00);
    line(850 + i*3, 300 - 2*flex4Data[i], 850 + (i+1)*3, 300 - 2*flex4Data[i+1]);
    }
    
    if(toggleButton[5].on)
    {
    stroke(colorRed);
    line(850 + i*3, 460 - ((int) gyroData[i]), 850 + (i+1)*3, 460 - ( (int) gyroData[i+1]));
    }
    
  }
  
    // Plot Threshold Lines
    if(toggleButton[0].on)
    {
    stroke(colorDarkBlue);
    line(850, 300 - 2*(100-Thumb), 1150, 300 - 2*(100-Thumb));
    }
    if(toggleButton[1].on)
    {
    stroke(colorRed);
    line(850, 300 - 2*(100-Index), 1150, 300 - 2*(100-Index));
    }
    if(toggleButton[2].on)
    {
    stroke(colorGreen);
    line(850, 300 - 2*(100-Middle), 1150, 300 - 2*(100-Middle));
    }
    if(toggleButton[3].on)
    {
    stroke(colorPurple);
    line(850, 300 - 2*(100-Ring), 1150, 300 - 2*(100-Ring));
    }
    if(toggleButton[4].on)
    {
    stroke(colorOrange);
    line(850, 300 - 2*(100-Pinky), 1150, 300 - 2*(100-Pinky));
    }
    if(toggleButton[5].on)
    {
    stroke(colorRed);
    line(850, 460 + GyroRight, 1150, 460 + GyroRight);
    line(850, 460 - GyroLeft, 1150, 460 - GyroLeft);
    }
   
}
public void serialEvent(String eventString)
{
 // println("Serial" + millis() +": " + eventString);
  if (eventString != null && eventString.trim().length() > 2)
  {
    if (eventString.trim().substring(0) == "!")
    {
      stopSerial = true;
      port.clear();
    } 
    else
    {
      String check = eventString.trim().substring(0, 2); //first 2 characters
      String value = eventString.trim().substring(2, eventString.trim().length() - 1); //last characters - EOL symbol $
      //println("Check: " + check);
      //println("Value: " + value);
      if (check.substring(0, 1).equals("F")) //its a flex value
      {
        switch (check.charAt(1))
        {
        case '0': 
          testSerial[1] = value;
          break;
        case '1': 
          testSerial[2] = value;
          break;
        case '2': 
          testSerial[3] = value;
          break;
        case '3': 
          testSerial[4] = value;
          break;
        case '4': 
          testSerial[5] = value;
          break;
        }
      } else if (check.substring(0, 1).equals("G")) //Gyro value
      {
        testSerial[6] = value;
      } else if (check.substring(0, 1).equals("A")) //Active Value
      {
        switch (check.charAt(1))
        {
        case '0': 
          testSerial[8] = value;
          break;
        case '1': 
          testSerial[9] = value;
          break;
        case '2': 
          testSerial[10] = value;
          break;
        case '3': 
          testSerial[11] = value;
          break;
        case '4': 
          testSerial[12] = value;
          break;
        }
      } else if (check.substring(0, 1).equals("C")) //Command Value
      {
        switch (check.charAt(1))
        {
        case 'L': 
          testSerial[14] = value;
          break;
        case 'R': 
          testSerial[15] = value;
          break;
        case 'F': 
          testSerial[16] = value;
          break;
        case 'B': 
          testSerial[17] = value;
          break;
        }
      }
    }
  }
}

//"value", "100", "100", "100", "100", "100", "-1", "active", "1", "1", "1", "1", "1", "command", "0", "0", "0", "1"
public void outputToArduino()
{
  // Flex outputs //////////////////////////////////////////////
  if ( lastRead[0] != Thumb 
    || lastRead[1] != Index 
    || lastRead[2] != Middle 
    || lastRead[3] != Ring 
    || lastRead[4] != Pinky)
  {
    int ThumbWrite = 100 - Thumb;
    int IndexWrite = 100 - Index;
    int MiddleWrite = 100 - Middle;
    int RingWrite = 100 - Ring;
    int PinkyWrite = 100 - Pinky;

    if ( ThumbWrite < 10)
      ThumbWrite = 10;
    if (ThumbWrite > 99)
      ThumbWrite = 99;

    if (IndexWrite < 10)
      IndexWrite = 10;
    if (IndexWrite > 99)
      IndexWrite = 99;

    if (MiddleWrite < 10)
      MiddleWrite = 10;
    if (MiddleWrite > 99)
      MiddleWrite = 99;

    if (RingWrite < 10)
      RingWrite = 10;
    if (RingWrite > 99)
      RingWrite = 99;

    if (PinkyWrite < 10)
      PinkyWrite = 10;
    if (PinkyWrite > 99)
      PinkyWrite = 99;

    String outputFlex = "!!" + (ThumbWrite) + (IndexWrite) + (MiddleWrite) + (RingWrite) + (PinkyWrite) + "$";
    println(outputFlex);
    port.write(outputFlex);
      
  } 
  if (lastRead[5] != GyroLeft || lastRead[6] != GyroRight)
  {


    // Gyro Outputs ////////////////////////////////////////
    String outputGyro = "##" + abs(GyroLeft) + abs(GyroRight) + "$";
    // println(outputGyro);
    port.write(outputGyro);
  } 
  if (  lastRead[7] != (FThumb ? 1 : 0)
    || lastRead[8] != (FIndex? 1 : 0)
    || lastRead[9] != (FMiddle? 1 : 0)
    || lastRead[10] != (FRing? 1 : 0)
    || lastRead[11] != (FPinky? 1 : 0)
    || lastRead[12] != (BThumb? 1 : 0)
    || lastRead[13] != (BIndex? 1 : 0)
    || lastRead[14] != (BMiddle? 1 : 0)
    || lastRead[15] != (BRing? 1 : 0)
    || lastRead[16] != (BPinky? 1 : 0) )
  {
    String commandOutput = "@@" + (FThumb ? 1 : 0) + (FIndex? 1 : 0) + (FMiddle? 1 : 0) + (FRing ? 1 : 0) + (FPinky ? 1 : 0) + (BThumb ? 1 : 0) + (BIndex? 1 : 0) + (BMiddle? 1 : 0) + (BRing? 1 : 0) + (BPinky? 1 : 0) + "$";
    port.write(commandOutput);
    println("State: " + commandOutput);
  }
  
  if (setActive)
  {
    setActive = false;
    port.write("SETACTIVE");
    println("SETACTIVE!");
  }
  
  if (setRest)
  {
    setRest = false;
    port.write("SETREST");
  }

  lastRead[0] = Thumb;
  lastRead[1] = Index;
  lastRead[2] = Middle;
  lastRead[3] = Ring;
  lastRead[4] = Pinky;
  lastRead[5] = GyroLeft;
  lastRead[6] = GyroRight;
  lastRead[7] = ((FThumb) ? 1 : 0);
  lastRead[8] = ((FIndex) ? 1 : 0);
  lastRead[9] = ((FMiddle) ? 1 : 0);
  lastRead[10] = ((FRing) ? 1 : 0);
  lastRead[11] = ((FPinky) ? 1 : 0);
  lastRead[12] = ((BThumb) ? 1 : 0);
  lastRead[13] = ((BIndex) ? 1 : 0);
  lastRead[14] = ((BMiddle) ? 1 : 0);
  lastRead[15] = ((BRing) ? 1 : 0);
  lastRead[16] = ((BPinky) ? 1 : 0);
}
public void controlEvent(ControlEvent theEvent) { //<>//
  if (theEvent.isFrom(checkbox)) {
    // checkbox uses arrayValue to store the state of 
    // individual checkbox-items. usage:
    int col = 0;
    for (int i=0; i<checkbox.getArrayValue ().length; i++) {
      int n = (int)checkbox.getArrayValue()[i];

      switch (i)
      {
      case 0: 
        FThumb = (n == 1);
        break;
      case 1: 
        FIndex = (n == 1);
        break;
      case 2: 
        FMiddle = (n == 1);
        break;
      case 3: 
        FRing = (n == 1);
        break;
      case 4: 
        FPinky = (n == 1);
        break;
      case 5: 
        BThumb = (n == 1);
        break;
      case 6: 
        BIndex = (n == 1);
        break;
      case 7: 
        BMiddle = (n == 1);
        break;
      case 8: 
        BRing = (n == 1);
        break;
      case 9: 
        BPinky = (n == 1);
        break;
      }  
      print(n);
      if (n==1) {
      }
    }
    println();
  }
}

public void mousePressed() {
  // When the mouse is pressed, we must check every single button
    toggleButton[0].click(mouseX,mouseY); 
    toggleButton[1].click(mouseX,mouseY);
    toggleButton[2].click(mouseX,mouseY);
    toggleButton[3].click(mouseX,mouseY);
    toggleButton[4].click(mouseX,mouseY);
    toggleButton[5].click(mouseX,mouseY);
    boolean clickedPlot = plotButton.click(mouseX,mouseY);
    println("Mouse: " + mouseX + "," + mouseY);
    if (clickedPlot)
      startPlot();
    if(mouseX > 5 && mouseX < 95 && mouseY > 5 && mouseY < 25)
      configureFlex = false;
    
    if(mouseX > 97 && mouseX < 200 && mouseY > 5 && mouseY < 25)
      configureFlex = true;
      

    if(activeState.click(mouseX,mouseY))
    {
        stateMessage = "Active\nstate set";
        setActive = true;
        timeoutClick = millis();
    }
    
    if(restState.click(mouseX,mouseY))
    {
        stateMessage = "Rest\nstate set";
        timeoutClick = millis();
        setRest = true;
    }
      
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ggcSoftware2" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
