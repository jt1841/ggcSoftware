void controlEvent(ControlEvent theEvent) {
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
