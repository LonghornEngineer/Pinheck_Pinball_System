'MAX11613.spin
'Version: 1.0
'Parker Dillmann
'The Longhorn Engineer (c) 2015 
'www.longhornengineer.com

'MAX11613 Driver


MAX11613 = %01101000                                    'Device address for the MAX11613. See page 13 of datasheet. Notice the padded 0 bit on the LSB.
       
VAR

  byte SCL_
  byte COG_ID

  word ADC_Store[4]
  word ADC_Stream[4]
  
  long ADC_Stack[35]
  
OBJ

  I2C   : "Basic_I2C_Driver_1"

PUB INIT (SCL) | Setup, Config
  'Initialize the I2C bus. If the MAX11613 fails to respond return true (-1).


  SCL_ := SCL

  Setup := %1000_0000

  Config := %0000_0001

  I2C.Initialize(SCL_)
  
  if I2C.WriteByte( SCL_, MAX11613, i2c#NoAddr, Setup)                   
    return true

  I2C.WriteByte( SCL_, MAX11613, i2c#NoAddr, Config)   

  return false
  
PUB Get_Value (ch) | Config
  'Get the value for the ADC channel (ch) selected. 

  if (COG_ID == 0)
    Config := %0110_0001 + (ch << 1) 
    return (Get_Conv(Config))

  else
    return ADC_Store[ch]
    
    
PUB Get_Average (ch) | Config
  'Get the average value for the ADC channel (ch) selected. MAX11613 samples the channel 8 times and returns the average.  


  Config := %0010_0001 + (ch << 1) 
                                                                                                                                                                                                                                                                                                                                                              
  return Get_Conv (Config)

PUB Start_Stream
  'Start the streaming mode of the MAX11613. This starts a cog to keep pulling values from the ADC in a constant stream.
  'Much faster then the single conversion but ties up a COG and the I2C bus.

  COG_ID := COGNEW(Stream, @ADC_Stack)

  return COG_ID

PUB Stop_Stream
  'Stop the streaming mode. 

  COGSTOP(COG_ID)

  COG_ID := 0
   
  return

PRI Get_Conv (Config)
  'Write config for a single channel read then get it. 

  I2C.WriteByte( SCL_, MAX11613, i2c#NoAddr, Config)

  return Get_Read

PRI Get_Read | ADC_Value, ADC_Value_Temp
  'Reads data from I2C bus.

  ADC_Value := I2C.ReadWord( SCL_, MAX11613, i2c#NoAddr)

  if ADC_Value == true
    return true
                                                                                                                                                                                                                                                                                                                                                              
  return Swap_Bytes(ADC_Value)

PRI Stream
  'Streaming mode main loop for new cog. The MAX11613 must receive a new write to begin new conversions.

  repeat

    I2C.WriteByte( SCL_, MAX11613, i2c#NoAddr, %00011111)

    I2C.ReadPage( SCL_, MAX11613, i2c#NoAddr, @ADC_Stream,8)

    ADC_Store[0] := Swap_Bytes(ADC_Stream[0])

    ADC_Store[1] := Swap_Bytes(ADC_Stream[1])

    ADC_Store[2] := Swap_Bytes(ADC_Stream[2])

    ADC_Store[3] := Swap_Bytes(ADC_Stream[3])

PRI Swap_Bytes (switch) | temp
  'Reorder the word by swapping the lower and upper Byte. 

  temp := (switch << 8) & %00001111_11111111

  return temp | (switch >> 8)