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
      text(int(serialArray[i]), i*50 + 35, 115);
      if (int(serialArray[i]) > thresholdArray[i-1])
      {
        stroke(colorRed);
      }
      else
      {
        stroke(colorDarkBlue);
      }
      line(i*50 + 30, 200 + 2*(int(serialArray[i])-40), i*50 + 25 + 35, 200 + 2*(int(serialArray[i])-40));
      controlValue[i-1] = int(serialArray[i]);
    } else if (i == 6)
    {

      float theta = -int(serialArray[i])*3.1415/180;
      float x0 = 175;
      float y0 = 500;
      float r = 80;
      float x1 = x0 - r*cos(theta);
      float y1 = y0 + r*sin(theta);
      float x2 = x0 + r*cos(theta);
      float y2 = y0 - r*sin(theta);

      stroke(colorDarkBlue);
      text("Value: " + serialArray[i], 140, 390);
      if(int(serialArray[i]) < -thresholdArray[i] || int(serialArray[i]) > thresholdArray[i-1])
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
      theta = int(GyroRight)*3.1415/180;
      x2 = x0 + r*cos(theta);
      y2 = y0 - r*sin(theta);
      line(x0, y0, x2, y2);

      theta = int(-GyroLeft)*3.1415/180;
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

void arrow(int x1, int y1, int x2, int y2) {
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
    colorRed = #7e7e7e;
    colorDarkRed = #3f3f3f;
    colorDarkBlue = #696969;
    MyController
    .setColorForeground(colorRed)
        .setColorActive(colorDarkRed);
    MyCheckbox
      .setColorForeground(color(colorDarkBlue))
        .setColorActive(color(colorRed));
    plotButton.colorOn = #696969;
    for(int i = 0; i < 6; i++)
    {
      toggleButton[i].colorOn = #696969;
    }
  }
  else
  {
    colorDarkBlue = #02344d;
    colorRed = #FC0000;
    colorDarkRed = #cc0000;
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
