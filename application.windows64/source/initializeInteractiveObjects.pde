void initializeInteractiveObjects()
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
