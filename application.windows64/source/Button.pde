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
  float weight = .5;

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

  boolean click(int mx, int my) {
    // Check to see if a point is inside the rectangle
    if (mx > x && mx < x + w && my > y && my < y + h) {
      on = !on;
      return true;
    }
    else
      return false;
  }

  // Draw the rectangle
  void display() {
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
