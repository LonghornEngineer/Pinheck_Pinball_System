CON
        _clkmode  = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq  = 6_000_000

        PWR_ON    = 0
        
        RST_PIC32 = 8
        TX_PIC32  = 9
        RX_PIC32  = 10
        
        RST_PROP  = 11
        TX_PROP   = 12
        RX_PROP   = 13

        CLK_165   = 16
        LAT_165  = 17
        DAT_165  = 18

        CLK_595   = 19
        LAT_595   = 20
        DAT_595   = 21

VAR
  byte str_test[32]
  byte opcode[32]
  byte ostr[32]

  byte derp[32]

  byte inputs[13]

  byte PICcode[128]
  byte PRPcode[128]

  byte shiftin

  byte ERROR

  byte temp_char

  byte debug

  word temp_word

  word output

  byte optoOP
   
OBJ

  PST : "Parallax Serial Terminal"
  PIC : "Parallax Serial Terminal"
  PRP : "Parallax Serial Terminal"

  ADC : "MAX11613"
  
  loader : "PropellerLoader"
  
                       
PUB MAIN | i,j

  DIRA[RST_PIC32]~

  DIRA[CLK_165]~~
  DIRA[LAT_165]~~
  DIRA[DAT_165]~

  DIRA[CLK_595]~~
  DIRA[LAT_595]~~
  DIRA[DAT_595]~~

  OUTA[LAT_595]~
  OUTA[CLK_595]~
  OUTA[DAT_595]~ 

  OUTA[PWR_ON] := FALSE 
  DIRA[PWR_ON]~~
  
  
  ADC.Init(28)

  PST.Start(115200)

  PST.Str(STRING("STARTING PinHeck Test Jig."))
  PST.Newline

  PST.Str(STRING("Ready."))
  PST.Newline
  PST.Str(STRING("Enter y to PWR board."))
  PST.NewLine

  repeat                                    
    PST.StrIn(@str_test)
    Parse(@str_test, @opcode, 0,5)
    
    if StrCount(STRING("y"),@opcode)
      QUIT
    else
      PST.Str(STRING("WRONG CMD"))
      PST.Newline

  PST.Str(STRING("Turn on PWR. Please wait..."))
  PST.Newline  

  OUTA[PWR_ON] := TRUE

  repeat i from 1 to 5
    waitcnt(clkfreq + cnt)
    PST.Dec(i)
    PST.Str(STRING("..."))
    PST.Newline  

  PST.Str(STRING("PWR on..."))
  PST.NewLine
  
  PST.Str(STRING("LOADING PROP CODE ONTO PINHECK.."))
  PST.NewLine

  loader.Connect(RST_PROP, RX_PROP, TX_PROP, 1, loader#ProgramRun, @loadme)

  PST.Str(STRING("PINHECK PROP LOADED."))
  PST.NewLine

  PST.Str(STRING("STARTING PIC32 COM."))
  PST.Newline
  
  if(PIC.StartRxTx(TX_PIC32, RX_PIC32, 0, 115200))
    PST.Str(STRING("PIC32 COM Success."))
    PST.Newline
  else
    PST.Str(STRING("PIC32 COM FAIL."))
    PST.Newline
  
  PST.Str(STRING("STARTING PROP COM."))
  PST.Newline

  if(PRP.StartRxTx(TX_PROP, RX_PROP, %0000, 9600))
    PST.Str(STRING("PROP COM Success."))
    PST.Newline
  else
    PST.Str(STRING("PROP COM FAIL."))
    PST.Newline

  waitcnt(clkfreq*2+cnt)

  'READY?!

  PST.Str(STRING("Program PIC32 with the PICKIT3 and then enter y."))
  PST.NewLine

  repeat                                    
    PST.StrIn(@str_test)
    Parse(@str_test, @opcode, 0,5)
    
    if StrCount(STRING("y"),@opcode)
      QUIT
    else
      PST.Str(STRING("WRONG CMD"))
      PST.Newline

  repeat i from 1 to 5
    waitcnt(clkfreq + cnt)
    PST.Dec(i)
    PST.Str(STRING("..."))
    PST.Newline
    
  PST.Str(STRING("Starting Test..."))
  PST.Newline
  PST.Newline 

  PST.Str(STRING("Watch Doge LED ON? Enter y if yes. Enter n if no."))
  PST.NewLine

  repeat                                    
    PST.StrIn(@str_test)
    Parse(@str_test, @opcode, 0,5)
    
    if StrCount(STRING("y"),@opcode)
      QUIT
    elseif StrCount(STRING("n"),@opcode)
      PST.NewLine
      PST.Str(STRING("WATCHDOGE OR PIC32 CODE NOT RUNNING"))
      PST.NewLine
      TURNOFF
    elseif StrCount(STRING("d"),@opcode)
      PST.NewLine
      PST.Str(STRING("Debug Active"))
      PST.NewLine
      debug := 1
      QUIT
    
    else
      PST.Str(STRING("WRONG CMD"))
      PST.Newline

  PST.Str(STRING("PROP ACT LED BLINKING? Enter y if yes. Enter n if no."))
  PST.NewLine

  repeat                                    
    PST.StrIn(@str_test)
    Parse(@str_test, @opcode, 0,5)
    
    if StrCount(STRING("y"),@opcode)
      QUIT
    elseif StrCount(STRING("n"),@opcode)
      PST.NewLine
      PST.Str(STRING("PROP CODE NOT RUNNING"))
      PST.NewLine
      TURNOFF

    else
      PST.Str(STRING("WRONG CMD"))
      PST.Newline
  
  'Test Solenoids
  
  PST.NewLine
  PST.STR(STRING("SOLENOID TESTING..."))
  PST.NewLine

  PIC.RxFlush
  
  repeat i from 0 to 23
    PIC.Str(STRING("[a"))

    if (solPins[i] < 10)
      PIC.Dec(0)
      PIC.Dec(solPins[i])
    else
      PIC.Dec(solPins[i])
    PIC.Dec(1)
    PIC.Str(STRING("]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)

    GetIO

    if (debug == 1)
      PST.NewLine    
      PST.BIN(inputs[5],8)
      PST.NewLine
      PST.BIN(inputs[4],8)
      PST.NewLine
      PST.BIN(inputs[3],8)
      PST.NewLine
    
    if(solignore[i] == 1)
      PST.STR(STRING("SOLENOID SKIP: "))
      PST.Dec(i)
      PST.NewLine    
    elseif (inputs[5] <> solcheck0[i])
      PST.STR(STRING("ERROR SOLENOID: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    elseif (inputs[4] <> solcheck1[i]) 
      PST.STR(STRING("ERROR SOLENOID: "))
      ERROR++ 
      PST.DEC(i)
      PST.NewLine
    elseif (inputs[3] <> solcheck2[i]) 
      PST.STR(STRING("ERROR SOLENOID: "))
      ERROR++ 
      PST.DEC(i)
      PST.NewLine
    else
      PST.STR(STRING("SOLENOID PASS: "))
      PST.DEC(i)
      PST.NewLine

    PIC.Str(STRING("[a"))

    if (solPins[i] < 10)
      PIC.Dec(0)
      PIC.Dec(solPins[i])
    else
      PIC.Dec(solPins[i])
    PIC.Dec(0)
    PIC.Str(STRING("]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)
    
  'Test GI
  
  PST.NewLine
  PST.STR(STRING("GI TESTING..."))
  PST.NewLine

  PIC.RxFlush

  repeat i from 0 to 15
   
    PIC.Str(STRING("[b"))
    PIC.Char(giPins[i*2])
    PIC.Char(giPins[(i*2)+1])
    PIC.Str(STRING("Z]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)  
   
    GetIO

    if (debug == 1)
      PST.NewLine    
      PST.BIN(inputs[1],8)
      PST.NewLine
      PST.BIN(inputs[2],8)
      PST.NewLine
   
    if(giignore[i] == 1)
      PST.STR(STRING("GI SKIP: "))
      PST.Dec(i)
      PST.NewLine    
    elseif (inputs[1] <> gicheck0[i])
      PST.STR(STRING("ERROR GI: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    elseif (inputs[2] <> gicheck1[i]) 
      PST.STR(STRING("ERROR GI: "))
      ERROR++ 
      PST.DEC(i)
      PST.NewLine
    else
      PST.STR(STRING("GI PASS: "))
      PST.DEC(i)
      PST.NewLine

  'Test Light Matrix Row

  PST.NewLine
  PST.STR(STRING("LIGHT MATRIX ROW TESTING..."))
  PST.NewLine

  PIC.RxFlush
  repeat i from 0 to 7
   
    PIC.Str(STRING("[c"))
    PIC.Char(lrPins[i])
    PIC.Char(%0000_0000)
    PIC.Str(STRING("Z]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)
   
    GetIO

    if (debug == 1)
      PST.NewLine    
      PST.BIN(inputs[7],8)
      PST.NewLine

    if (inputs[7] <> lrcheck0[i])
      PST.STR(STRING("ERROR LIGHT ROW: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("LIGHT ROW PASS: "))
      PST.DEC(i)
      PST.NewLine    
      
  'Test Light Matrix Column

  PST.NewLine
  PST.STR(STRING("LIGHT MATRIX COLUMN TESTING..."))
  PST.NewLine

  PIC.RxFlush

  repeat i from 0 to 7
   
    PIC.Str(STRING("[c"))
    PIC.Char(%0000_0000)
    PIC.Char(lcPins[i])
    PIC.Str(STRING("Z]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)

    GetIO

    if (debug == 1)
      PST.NewLine    
      PST.BIN(inputs[8],8)
      PST.NewLine
    
    if (inputs[8] <> lccheck0[i])
      PST.STR(STRING("ERROR LIGHT COLUMN: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("LIGHT COLUMN PASS: "))
      PST.DEC(i)
      PST.NewLine

  'Test Switch Row

  PST.NewLine
  PST.STR(STRING("SWITCH MATRIX ROW TESTING..."))
  PST.NewLine

  PIC.RxFlush

  repeat i from 0 to 7
    PIC.RxFlush

    output := sroutput[i]
  
    PushIO 
  
    waitcnt((clkfreq>>4) + cnt)
   
    PIC.Str(STRING("[nZZZ]"))
    PIC.CharIn
    PIC.CharIn
    temp_char := PIC.CharIn

    if (debug == 1)
      PST.NewLine    
      PST.BIN(temp_char,8)
      PST.NewLine
     
    if(temp_char <> srcheck0[i])
      PST.STR(STRING("ERROR SWITCH ROW: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("SWITCH ROW PASS: "))
      PST.DEC(i)
      PST.NewLine

  'Test Switch Column

  PST.NewLine
  PST.STR(STRING("SWITCH MATRIX COLUMN TESTING..."))
  PST.NewLine

  PIC.RxFlush

  repeat i from 0 to 7
   
    PIC.Str(STRING("[d"))
    PIC.Char(scPins[i])
    PIC.Str(STRING("ZZ]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)

    GetIO

    if (debug == 1)
      PST.NewLine    
      PST.BIN(inputs[6],8)
      PST.NewLine

    
    if (inputs[6] <> sccheck0[i])
      PST.STR(STRING("ERROR SWITCH COLUMN: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("SWITCH COLUMN PASS: "))
      PST.DEC(i)
      PST.NewLine


  'Test On Board RGB

  PST.NewLine
  PST.STR(STRING("RGB ON BOARD TESTING..."))
  PST.NewLine

  'PIC.RxFlush

  repeat i from 0 to 2
   
    PIC.Str(STRING("[e"))
    PIC.Char(rgbobR[i])
    PIC.Char(rgbobG[i])
    PIC.Char(rgbobB[i])  
    PIC.Str(STRING("]"))
    PIC.StrIn(@PICcode)

    waitcnt((clkfreq>>4) + cnt)

    GetIO

    if (debug == 1)
      PST.NewLine    
      PST.BIN(inputs[11] & %00000011,8)
      PST.NewLine
      PST.BIN(inputs[10] & %11110000,8)
      PST.NewLine

    if ((inputs[11] & %00000011) <> rgbcheck0[i])
      PST.STR(STRING("ERROR RGB ONBOARD: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine
    elseif ((inputs[10] & %11110000) <> rgbcheck1[i])
      PST.STR(STRING("ERROR RGB ONBOARD: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine
    else
      PST.STR(STRING("RGB ONBOARD PASS: "))
      PST.DEC(i)
      PST.NewLine

  'Test EXT RGB

  PST.NewLine
  PST.STR(STRING("EXT RGB TESTING..."))
  PST.NewLine

  PIC.RxFlush

  repeat i from 0 to 1
    PIC.Str(STRING("[g"))
   
    if (ergbPins[i] < 10)
      PIC.Dec(0)
      PIC.Dec(ergbPins[i])
    else
      PIC.Dec(ergbPins[i])
    PIC.Str(STRING("Z]"))
    PIC.StrIn(@PICcode)
   
    waitcnt((clkfreq>>4) + cnt)
   
    GetIO
   
    if (debug == 1)
      PST.NewLine    
      PST.BIN(inputs[10],8)
      PST.NewLine
   
    if ((inputs[10] & %00000011) <> ergbcheck0[i])
      PST.STR(STRING("ERROR EXT RGB: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("EXT RGB PASS: "))
      PST.DEC(i)
      PST.NewLine
   
    PIC.Str(STRING("[g00Z]"))
    PIC.StrIn(@PICcode)
   
    waitcnt((clkfreq>>4) + cnt)

  'Test Servos

  PST.NewLine
  PST.STR(STRING("SERVO TESTING..."))
  PST.NewLine

  PIC.RxFlush

  repeat i from 0 to 4
    PIC.Str(STRING("[a"))

    if (servoPins[i] < 10)
      PIC.Dec(0)
      PIC.Dec(servoPins[i])
    else
      PIC.Dec(servoPins[i])
    PIC.Dec(0)
    PIC.Str(STRING("]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)

    GetIO

    if (debug == 1)
      PST.NewLine    
      PST.BIN(inputs[9],8)
      PST.NewLine

    if ((inputs[9] & %00011111) <> servocheck0[i])
      PST.STR(STRING("ERROR SERVO: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("SERVO PASS: "))
      PST.DEC(i)
      PST.NewLine

    PIC.Str(STRING("[a"))

    if (servoPins[i] < 10)
      PIC.Dec(0)
      PIC.Dec(servoPins[i])
    else
      PIC.Dec(servoPins[i])
    PIC.Dec(1)
    PIC.Str(STRING("]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)

  'Test Cabinet I/O

  PST.NewLine
  PST.STR(STRING("CABINET I/O TESTING..."))
  PST.NewLine

  repeat i from 0 to 7
    PIC.RxFlush

    output := caboutput[i]

    PushIO 
  
    waitcnt((clkfreq>>4) + cnt)            
   
    PIC.Str(STRING("[mZZZ]"))
    PIC.CharIn
    PIC.CharIn
    temp_char := PIC.CharIn
    temp_word := temp_char
    temp_word := temp_word << 8
    temp_char :=  PIC.CharIn
    temp_word := temp_word + temp_char

    if (debug == 1)
      PST.NewLine    
      PST.BIN(temp_word, 16)
      PST.NewLine
    
    if((temp_word & %00000000_11111111) <> cabcheck0[i])
      PST.STR(STRING("ERROR CABINET I/O: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("CABINET I/O PASS: "))
      PST.DEC(i)
      PST.NewLine      

  'Test OPTO I/O

  PST.NewLine
  PST.STR(STRING("OPTO I/O TESTING..."))
  PST.NewLine

    repeat i from 0 to 6
      PIC.RxFlush
     
      output := %11111111_11111111
      optoOP := optooutput[i]
     
      PushIO 
     
      waitcnt((clkfreq>>4) + cnt)            
     
      PIC.Str(STRING("[mZZZ]"))
      PIC.CharIn
      PIC.CharIn
      temp_char := PIC.CharIn
      temp_word := temp_char
      temp_word := temp_word << 8
      temp_char :=  PIC.CharIn
      temp_word := temp_word + temp_char
     
      if (debug == 1)
        PST.NewLine    
        PST.BIN(temp_word, 16)
        PST.NewLine
      
      if((temp_word & %11110111_00000000) <> optocheck0[i])
        PST.STR(STRING("ERROR OPTO I/O: "))
        ERROR++
        PST.DEC(i)
        PST.NewLine 
      else
        PST.STR(STRING("OPTO I/O PASS: "))
        PST.DEC(i)
        PST.NewLine   

 'Test Prop
  
  PST.NewLine
  PST.STR(STRING("PINHECK PROP I/O TESTING..."))
  PST.NewLine

  'SD Card

  repeat i from 0 to 3
    PRP.RxFlush
   
    PRP.Str(STRING("[w"))
   
    if (sdcPins[i] < 10)
      PRP.Dec(0)
      PRP.Dec(sdcPins[i])
    else
      PRP.Dec(sdcPins[i])
    PRP.Dec(0)
    PRP.Str(STRING("]"))
    PRP.NewLine
    PRP.StrIn(@PRPcode)
   
    waitcnt((clkfreq>>6) + cnt)
   
    GetIO
   
    if ((inputs[0] & %00001111) <> sdccheck0[i])
      PST.STR(STRING("ERROR SD I/O: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("SD I/O PASS: "))
      PST.DEC(i)
      PST.NewLine
   
    if (debug == 1)
      PST.NewLine    
      PST.BIN(inputs[0],8)
      PST.NewLine
   
    PRP.Str(STRING("[w"))
    
    if (sdcPins[i] < 10)
      PRP.Dec(0)
      PRP.Dec(sdcPins[i])
    else
      PRP.Dec(sdcPins[i])
    PRP.Dec(1)
    PRP.Str(STRING("]"))
    PRP.NewLine
    PRP.StrIn(@PRPcode)   

    
  
  repeat i from 0 to 1
    PRP.RxFlush
   
    PRP.Str(STRING("[w"))
   
    if (sndPins[i] < 10)
      PRP.Dec(0)
      PRP.Dec(sndPins[i])
    else
      PRP.Dec(sndPins[i])
    PRP.Dec(1)
    PRP.Str(STRING("]"))
    PRP.NewLine
    PRP.StrIn(@PRPcode)
   
    waitcnt((clkfreq>>6) + cnt)
   
    GetIO
   
    if ((inputs[0] & %00110000) <> sndcheck0[i])
      PST.STR(STRING("ERROR SOUND I/O: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("SOUND I/O PASS: "))
      PST.DEC(i)
      PST.NewLine
   
    if (debug == 1)
      PST.NewLine    
      PST.BIN(inputs[0],8)
      PST.NewLine
   
    PRP.Str(STRING("[w"))
    
    if (sndPins[i] < 10)
      PRP.Dec(0)
      PRP.Dec(sndPins[i])
    else
      PRP.Dec(sndPins[i])
    PRP.Dec(0)
    PRP.Str(STRING("]"))
    PRP.NewLine
    PRP.StrIn(@PRPcode)   

  repeat i from 0 to 1
    PRP.RxFlush
   
    PRP.Str(STRING("[w"))
   
    if (pauxPins[i] < 10)
      PRP.Dec(0)
      PRP.Dec(pauxPins[i])
    else
      PRP.Dec(pauxPins[i])
    PRP.Dec(1)
    PRP.Str(STRING("]"))
    PRP.NewLine
    PRP.StrIn(@PRPcode)
   
    waitcnt((clkfreq>>6) + cnt)
   
    GetIO
   
    if ((inputs[10] & %00001100) <> pauxcheck0[i])
      PST.STR(STRING("ERROR PROP AUX I/O: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("PROP AUX I/O PASS: "))
      PST.DEC(i)
      PST.NewLine
   
    if (debug == 1)
      PST.NewLine    
      PST.BIN(inputs[10],8)
      PST.NewLine
   
    PRP.Str(STRING("[w"))
    
    if (pauxPins[i] < 10)
      PRP.Dec(0)
      PRP.Dec(pauxPins[i])
    else
      PRP.Dec(pauxPins[i])
    PRP.Dec(0)
    PRP.Str(STRING("]"))
    PRP.NewLine
    PRP.StrIn(@PRPcode) 
 
  repeat i from 0 to 6
    PRP.RxFlush
    
    PRP.Str(STRING("[w"))
   
    if (dmdPins[i] < 10)
      PRP.Dec(0)
      PRP.Dec(dmdPins[i])
    else
      PRP.Dec(dmdPins[i])
    PRP.Dec(1)
    PRP.Str(STRING("]"))
    PRP.NewLine
    PRP.StrIn(@PRPcode)
    
    waitcnt((clkfreq>>6) + cnt)
   
    GetIO
   
    if (debug == 1)
      PST.NewLine    
      PST.BIN(inputs[11],8)
      PST.NewLine
      PST.BIN(inputs[12],8)
      PST.NewLine
   
    if ((inputs[11] & %11111100) <> dmdcheck0[i])
      PST.STR(STRING("ERROR DMD: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    elseif ((inputs[12] & %00000001) <> dmdcheck1[i]) 
      PST.STR(STRING("ERROR DMD: "))
      ERROR++ 
      PST.DEC(i)
      PST.NewLine
    else
      PST.STR(STRING("DMD PASS: "))
      PST.DEC(i)
      PST.NewLine
   
    PRP.Str(STRING("[w"))
   
    if (dmdPins[i] < 10)
      PRP.Dec(0)
      PRP.Dec(dmdPins[i])
    else
      PRP.Dec(dmdPins[i])
    PRP.Dec(0)
    PRP.Str(STRING("]"))
    PRP.NewLine 
    PRP.StrIn(@PRPcode)   
               
  PST.NewLine
  PST.STR(STRING("TEST COMPLETED."))
  PST.NewLine

  if(ERROR > 0)
    PST.STR(STRING("ERROR COUNT: "))
    PST.DEC(ERROR)
    PST.NewLine
    PST.STR(STRING("PLEASE CHECK LOG ABOVE FOR ERRORS."))
  else
    PST.STR(STRING("NO ERRORS FOUND!"))

  PST.NewLine
  PST.NewLine
                 
  TURNOFF  

PRI TURNOFF | i

  PST.Str(STRING("Turn off PWR."))
  PST.NewLine
  OUTA[PWR_ON] := FALSE

  repeat i from 1 to 5
    waitcnt(clkfreq + cnt)
    PST.Dec(i)
    PST.Str(STRING("..."))
    PST.Newline

  PST.Str(STRING("Safe to remove PINHECK."))
  PST.NewLine
  PST.NewLine

  PST.Str(STRING("Enter y to START again."))
  PST.NewLine

  repeat                                    
    PST.StrIn(@str_test)
    Parse(@str_test, @opcode, 0,5)
    
    if StrCount(STRING("y"),@opcode)
      QUIT
    else
      PST.Str(STRING("WRONG CMD"))
      PST.Newline

  REBOOT
  
PRI GetIO | i

  OUTA[LAT_165]~
  OUTA[LAT_165]~~
  
  waitcnt(clkfreq/1000 + cnt)

  repeat i from 0 to 12
    repeat 8
      OUTA[CLK_165]~
      shiftin := shiftin << 1 + INA[DAT_165]
      OUTA[CLK_165]~~
      waitcnt(clkfreq/1000 + cnt)

    inputs[i] := shiftin

  OUTA[CLK_165]~~
  OUTA[LAT_165]~~

  return

PRI PushIO

  repeat 8 
    OUTA[DAT_595] := optoOP
    waitcnt(clkfreq/1000 + cnt)
    optoOP := optoOP >> 1
    OUTA[CLK_595]~
    OUTA[CLK_595]~~
    OUTA[CLK_595]~
    waitcnt(clkfreq/1000 + cnt)    

  repeat 16   
    OUTA[DAT_595] := output
    waitcnt(clkfreq/1000 + cnt)
    output := output >> 1
    OUTA[CLK_595]~
    OUTA[CLK_595]~~
    OUTA[CLK_595]~
    waitcnt(clkfreq/1000 + cnt)

  OUTA[LAT_595]~~
  OUTA[LAT_595]~

  OUTA[CLK_595]~~

  return

PRI Parse (strAddr, parAddr, start, count) | j

  repeat j from 0 to (count - 1)

    byte[parAddr + j] := byte[strAddr + j + start]
    
  byte[parAddr + (count)] := 0                                                    ' terminate string
  
  return parAddr

PRI StrCount (strAddr, searchAddr) : count | size, searchsize, pos, loc

  size := strsize(strAddr) + 1              
  searchsize := strsize(searchAddr)   

  count := pos := 0     
  REPEAT WHILE ((loc := StrPos(strAddr, searchAddr, pos)) <> -1)                ' while a search string exists
    count++
    pos := loc + searchsize

PRI StrPos (strAddr, searchAddr, offset) | size, searchsize

  size := strsize(strAddr) + 1
  searchsize := strsize(searchAddr)

  REPEAT UNTIL (offset + searchsize > size)
    IF (strcomp(StrParse(strAddr, offset++, searchsize), searchAddr))           ' if string search found
      RETURN offset - 1                                                         ' return byte location
  RETURN -1

PRI StrParse (strAddr, start, count)

  count <#= constant(31)
  bytemove(@ostr, strAddr + start, count)                                       ' just move the selected section

  ostr[count] := 0                                                              ' terminate string
  RETURN @ostr

DAT  loadme file "loadme.binary" 

     solPins   BYTE 22, 23, 32, 25, 31, 30, 2, 4, 7, 11, 12, 70, 71, 72, 73, 75, 78, 79, 80, 81, 82, 83, 84, 85

     solcheck0 BYTE %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101, %11111110, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111   
     solcheck1 BYTE %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101, %11111110, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
     solcheck2 BYTE %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101, %11111110

     solignore BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1

     giPins    BYTE %10000000, %00000000, %01000000, %00000000, %00100000, %00000000, %00010000, %00000000, %00001000, %00000000, %00000100, %00000000, %00000010, %00000000, %00000001, %00000000, %00000000, %10000000, %00000000, %01000000, %00000000, %00100000, %00000000, %00010000, %00000000, %00001000, %00000000, %00000100, %00000000, %00000010, %00000000, %00000001

     gicheck0  BYTE %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101, %11111110, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
     gicheck1  BYTE %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101, %11111110

     giignore  BYTE 1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0

     lrPins    BYTE %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

     lrcheck0  BYTE %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101, %11111110

     lcPins    BYTE %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

     lccheck0  BYTE %10000000, %01000000, %00100000, %00010000, %00001000, %00000100, %00000010, %00000001

     sroutput  WORD %00000000_00000001, %00000000_00000010, %00000000_00000100, %00000000_00001000, %00000000_00010000, %00000000_00100000, %00000000_01000000, %00000000_10000000

     srcheck0  BYTE %11111110, %11111101, %11111011, %11110111, %11101111, %11011111, %10111111, %01111111     

     scPins    BYTE %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

     sccheck0  BYTE %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

     rgbobR    BYTE %11111111, %00000000, %00000000

     rgbobG    BYTE %00000000, %11111111, %00000000

     rgbobB    BYTE %00000000, %00000000, %11111111

     rgbcheck0 BYTE %00000011, %00000010, %00000001

     rgbcheck1 BYTE %01100000, %11010000, %10110000

     servoPins BYTE 46, 44, 17, 34, 33

     servocheck0 BYTE %00011110, %00011101, %00011011, %00010111, %00001111

     caboutput WORD %11111110_00000000, %11111101_00000000, %11111011_00000000, %11110111_00000000, %11101111_00000000, %11011111_00000000, %10111111_00000000, %01111111_00000000

     cabcheck0 WORD %00000000_00000100, %00000000_00000010, %00000000_00000001, %00000000_00010000, %00000000_00100000, %00000000_01000000, %00000000_10000000, %00000000_00001000

     sdcPins   BYTE 3, 2, 1, 0

     sdccheck0 BYTE %00001110, %00001101, %00001011, %00000111

     sndPins   BYTE 14, 15

     sndcheck0 BYTE %00100000, %00010000

     pauxPins  BYTE 4, 5

     pauxcheck0 BYTE %00000100, %00001000

     dmdPins   BYTE 22, 21, 20, 19, 18, 17, 16

     dmdcheck0 BYTE %00000100, %00001000, %00010000, %00100000, %01000000, %10000000, %00000000

     dmdcheck1 BYTE %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000001

     optooutput BYTE %11111110, %11111101, %11111011, %11110111, %11101111, %11011111, %10111111

     optocheck0 WORD %00000001_00000000, %00000010_00000000, %00000100_00000000, %00010000_00000000, %00100000_00000000, %01000000_00000000, %10000000_00000000

     ergbPins  BYTE 1, 10

     ergbcheck0 BYTE %00000001, %00000010