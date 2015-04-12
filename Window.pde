public void updateWindow()
{

  fill(colorDBL);
  textFont(ArialBold12);
  text("Finger Inputs", 10, 20);
  noFill(); 
  strokeWeight(3); 
  stroke(colorDBL);
  rect(5, 25, 350, 310);
  rect(5, 362, 350, 235);
  rect(375, 25, 450, 140);
  rect(375, 205, 450, 390);
  
  String connectionStatus = "Status: ";
  if(!arduinoOnline)
  {
    connectionStatus += "Offline";
  }
  else
  {
    connectionStatus += "Online";
  }
  
  textFont(ArialBold18);
  fill(colorDBL);
  text(connectionStatus, 875,30);
  textFont(ArialBold12);
  
  String[] valueArray = {
    "value", "Thumb", "Index", "Middle", "Ring", "Pinky", "Gyro"
  };
  int[] thresholdArray = {
    100-Thumb, 100-Index, 100-Middle, 100-Ring, 100-Pinky, GyroLeft, GyroRight
  };
  
  
  if (testSerial.length >= 18)//&& !(testSerial[0].substring(0,1) == "#" || testSerial[0].substring(0,1) == "!"))
  {
    serialArray = testSerial;
  }
  
  strokeWeight(5);
  fill(colorDBL); 
  text("Value:", 10, 115); 
  fill(colorR);
  text("Threshold:", 10, 85);
  // Flex Sensors
  for (int i = 1; i < 7; i++)
  {
    if (i < 6)
    {
      fill(colorDBL);
      text(valueArray[i], i*50 + 35, 60); 
      fill(colorR);
      text(thresholdArray[i-1], i*50 + 35, 85);
      fill(colorDBL);
      text(int(serialArray[i]), i*50 + 35, 115);
      if (int(serialArray[i]) > thresholdArray[i-1])
      {
        stroke(colorR);
      }
      else
      {
        stroke(colorDBL);
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

      fill(colorDBL);
      text("Tilt Input", 10, 360);
      stroke(colorDBL);
      text("Value: " + serialArray[i], 140, 390);
      if(int(serialArray[i]) < -thresholdArray[i] || int(serialArray[i]) > thresholdArray[i-1])
      {
        stroke(colorDR);
      }
      else
      {
        stroke(colorDBL); 
      }
      line(x1, y1, x2, y2);

      fill(colorR);
      stroke(colorR);
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

  //Setup Control Scheme
  fill(colorDBL);
  text("Control Scheme", 375, 20);
  text("Forward", 390, 75);
  text("Backward", 390, 132);
  text("Thumb", 450, 40);
  text("Index", 525, 40);
  text("Middle", 590, 40);
  text("Ring", 665, 40);
  text("Pinky", 735, 40);


  if (command[0] == 1)
  {
    stroke(colorR);
    arrow(590, 390, 490, 390); //Left Arrow
    stroke(colorDBL);
    arrow(610, 390, 710, 390); //Right Arrow
  } else if (command[1] == 1)
  {
    stroke(colorDBL);
    arrow(590, 390, 490, 390); //Left Arrow
    stroke(colorR);
    arrow(610, 390, 710, 390); //Right Arrow
    stroke(colorDBL);
  } else 
  {
    stroke(colorDBL);
    arrow(590, 390, 490, 390); //Left Arrow
    arrow(610, 390, 710, 390); //Right Arrow
  }

  if (command[2] == 1)
  {
    stroke(colorR);
    arrow(600, 380, 600, 280); //Forward Arrow
    stroke(colorDBL);
    arrow(600, 400, 600, 500); //Backward Arrow
  } else if (command[3] == 1)
  {
    stroke(colorR);
    arrow(600, 400, 600, 500); //Backward Arrow
    stroke(colorDBL);
    arrow(600, 380, 600, 280); //Forward Arrow
  } else 
  {
    stroke(colorDBL);
    arrow(600, 400, 600, 500); //Backward Arrow
    arrow(600, 380, 600, 280); //Forward Arrow
  }

  text("Outputs", 375, 200);
  textFont(ArialBold18);
  stroke(colorDBL);
  text("Backward", 560, 535);
  text("Forward", 565, 250);  
  text("Left", 430, 395);
  text("Right", 735, 395);
  textFont(ArialBold12);


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

  fill(colorR);
  text(warning, 400, 185);
  fill(colorDBL);
  
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


