import processing.serial.*;
import java.io.PrintWriter;
import java.io.IOException;
import java.nio.file.Path;
import java.io.BufferedWriter;
import java.io.FileWriter;
import controlP5.*;
import peasy.*;

//Window Size
int xWindow = 1200;
int yWindow = 600;
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
ControlP5 MyController;
ControlP5 MyCheckbox;
CheckBox checkbox;
Button[] toggleButton;
Button plotButton;
Button saveButton;
PFont ArialBold12 = createFont("Ubuntu Bold", 12);
PFont ArialBold18 = createFont("Ubuntu Bold", 18);
PFont Ubuntu8 = createFont("Ubuntu Bold",8);
int colorBlack = 0;
int colorDBL = #02344d;
int colorR = #FC0000;
int colorDR = #cc0000;
int colorBackground = #eeeee7;
int colorGreen = #009100;
int colorPurple = #74009E;
int colorOrange = #FF6A00;

//Serial Communication Variables
Serial port;
String portname = Serial.list()[0];
String newString = "";
int[] lastRead = {
  90, 90, 90, 90, 90, 45, 45, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1
};
int baudrate = 9600;
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
boolean arduinoOnline = false;
boolean setupFlag = true;
boolean currentlyPlotting = false;
String[] testSerial = {
  "value", "100", "100", "100", "100", "100", "-1", "active", "1", "1", "1", "1", "1", "command", "0", "0", "0", "1"
};
String[] serialArray = {
  "value", "100", "100", "100", "100", "100", "-1", "active", "1", "1", "1", "1", "1", "command", "0", "0", "0", "1"
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

//FileIO Variables

void setup()
{
  //Initial Window Settings
  size(xWindow, yWindow);
  frameRate(25);
  background(colorBackground);
  strokeWeight(5);
  stroke(5);
  smooth();
  strokeCap(ROUND);


  setupPort();
  initializeInteractiveObjects();

}

void draw()
{ 
  background(colorBackground); 
  toggleColors();
  updateWindow();
  drawPlot();
  //plotDataFlag = false;
  toggleButton[0].display();
  toggleButton[1].display();
  toggleButton[2].display();
  toggleButton[3].display();
  toggleButton[4].display();
  toggleButton[5].display();
  plotButton.display();
  textAlign(CENTER);
  text(plotText,1035+80,62);
  
  
  textAlign(LEFT);
  
  if(plotDataFlag)
  {
    plotData();
  }
  
  
  portname = Serial.list()[0];
  println(portname);
  if (portname.length() > 11)
  {
    arduinoOnline = portname.substring(0, 11).equals("/dev/ttyACM");
  } 
  else
  {
    arduinoOnline = false;
    setupFlag = true;
  }


  if (setupFlag)
  {
    setupPort();
  }

  if (!arduinoOnline)
  {
    setupFlag = true;
  }


  if (arduinoOnline)
  {
    while (port.available () > 0)
    {
      serialEvent(port.readString());
    }

    outputToArduino();
  }
}


void setupPort()
{

  if (arduinoOnline && setupFlag)
  {  
    sleep(1000);
    setupFlag = false;
    port = new Serial(this, portname, baudrate);
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

public void toggleColors()
{
  if(!arduinoOnline)
  {
    colorR = #7e7e7e;
    colorDR = #3f3f3f;
    colorDBL = #696969;
    MyController
    .setColorForeground(colorR)
        .setColorActive(colorDR);
    MyCheckbox
      .setColorForeground(color(colorDBL))
        .setColorActive(color(colorR));
    plotButton.colorOn = #696969;
    for(int i = 0; i < 6; i++)
    {
      toggleButton[i].colorOn = #696969;
    }
  }
  else
  {
    colorDBL = #02344d;
    colorR = #FC0000;
    colorDR = #cc0000;
    MyController
    .setColorForeground(colorR)
        .setColorActive(colorDR);
    MyCheckbox
      .setColorForeground(color(colorDBL))
        .setColorActive(color(colorR));
    toggleButton[0].colorOn = colorDBL;
    toggleButton[1].colorOn = colorR;
    toggleButton[2].colorOn = colorGreen;
    toggleButton[3].colorOn = colorPurple;
    toggleButton[4].colorOn = colorOrange;
    toggleButton[5].colorOn = colorR;
    
  }
  
}

void mousePressed() {
  // When the mouse is pressed, we must check every single button
    toggleButton[0].click(mouseX,mouseY); 
    toggleButton[1].click(mouseX,mouseY);
    toggleButton[2].click(mouseX,mouseY);
    toggleButton[3].click(mouseX,mouseY);
    toggleButton[4].click(mouseX,mouseY);
    toggleButton[5].click(mouseX,mouseY);
    plotButton.click(mouseX,mouseY);
    saveButton.click(mouseX,mouseY);
    startPlot();
}



