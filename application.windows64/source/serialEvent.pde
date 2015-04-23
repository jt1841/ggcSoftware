void serialEvent(String eventString)
{
 // println("Serial" + millis() +": " + eventString);
  if (eventString != null && eventString.trim().length() > 2)
  {
    if (eventString.trim().substring(0) == "!")
    {
      stopSerial = true;
      port.clear();
    } 
    else
    {
      String check = eventString.trim().substring(0, 2); //first 2 characters
      String value = eventString.trim().substring(2, eventString.trim().length() - 1); //last characters - EOL symbol $
      //println("Check: " + check);
      //println("Value: " + value);
      if (check.substring(0, 1).equals("F")) //its a flex value
      {
        switch (check.charAt(1))
        {
        case '0': 
          testSerial[1] = value;
          break;
        case '1': 
          testSerial[2] = value;
          break;
        case '2': 
          testSerial[3] = value;
          break;
        case '3': 
          testSerial[4] = value;
          break;
        case '4': 
          testSerial[5] = value;
          break;
        }
      } else if (check.substring(0, 1).equals("G")) //Gyro value
      {
        testSerial[6] = value;
      } else if (check.substring(0, 1).equals("A")) //Active Value
      {
        switch (check.charAt(1))
        {
        case '0': 
          testSerial[8] = value;
          break;
        case '1': 
          testSerial[9] = value;
          break;
        case '2': 
          testSerial[10] = value;
          break;
        case '3': 
          testSerial[11] = value;
          break;
        case '4': 
          testSerial[12] = value;
          break;
        }
      } else if (check.substring(0, 1).equals("C")) //Command Value
      {
        switch (check.charAt(1))
        {
        case 'L': 
          testSerial[14] = value;
          break;
        case 'R': 
          testSerial[15] = value;
          break;
        case 'F': 
          testSerial[16] = value;
          break;
        case 'B': 
          testSerial[17] = value;
          break;
        }
      }
    }
  }
}

//"value", "100", "100", "100", "100", "100", "-1", "active", "1", "1", "1", "1", "1", "command", "0", "0", "0", "1"
