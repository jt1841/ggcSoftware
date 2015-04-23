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

//Global Variables
final PFont ARIAL_BOLD_12 = createFont("Arial Bold", 12);
final PFont ARIAL_BOLD_18 = createFont("Arial Bold", 18);
final PFont ARIAL_BOLD_8 = createFont("Arial Bold", 8);
final PFont ARIAL_12 = createFont("Arial", 10);
int colorDarkBlue = #02344d;
int colorRed = #FC0000;
int colorDarkRed = #cc0000;
int colorBackground = #eeeee7;
int colorGreen = #009100;
int colorPurple = #74009E;
int colorOrange = #FF6A00;
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

void setup()
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

void draw()
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


void setupPort()
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


void frameAndIcon(String frameText, String iconFilename) {
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

void readSavedThresholds()
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
