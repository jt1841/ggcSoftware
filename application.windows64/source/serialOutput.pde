void outputToArduino()
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
