void startPlot()
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
    currentTime = 0.0;
  }
}




void drawPlot()
{
  //Setup Axis for Flex
  strokeWeight(2);
  text("Finger Motion Plot", 850, 90);

  rotate(3.1415/2);
  text("Value",200,-835);
  rotate(-3.1415/2);
  
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
 
  rotate(3.1415/2);
  text("Degrees",430,-835);
  rotate(-3.1415/2);

  
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
   flex0Data[flex0Data.length - 1] = int(serialArray[1]);
   flex1Data[flex0Data.length - 1] = int(serialArray[2]);
   flex2Data[flex0Data.length - 1] = int(serialArray[3]);
   flex3Data[flex0Data.length - 1] = int(serialArray[4]);
   flex4Data[flex0Data.length - 1] = int(serialArray[5]);
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
    stroke(#009100);
    line(850 + i*3, 300 - 2*flex2Data[i], 850 + (i+1)*3, 300 - 2*flex2Data[i+1]);
    }
    
    if(toggleButton[3].on)
    {
    stroke(#74009E);
    line(850 + i*3, 300 - 2*flex3Data[i], 850 + (i+1)*3, 300 - 2*flex3Data[i+1]);
    }
    
    if(toggleButton[4].on)
    {
    stroke(#FF6A00);
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
