void controlEvent(ControlEvent theEvent) { //<>//
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

void mousePressed() {
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
