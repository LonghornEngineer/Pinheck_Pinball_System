{Object_Title_and_Purpose}


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
   
OBJ

  PST : "Parallax Serial Terminal"
  PIC : "Parallax Serial Terminal"
  PRP : "Parallax Serial Terminal"

  ADC : "MAX11613"
  
                       
PUB MAIN

  DIRA[PWR_ON]~~
  OUTA[PWR_ON] := 1
  
  ADC.Init(28)

  PST.Start(115200)

  PST.Str(STRING("STARTING PinHeck Test Jig."))
  PST.Newline
  PST.Str(STRING("STARTING PIC32 COM."))
  PST.Newline
  
  if(PIC.StartRxTx(RX_PIC32, TX_PIC32, 0, 115200))
    PST.Str(STRING("PIC32 COM Success."))
    PST.Newline
  else
    PST.Str(STRING("PIC32 COM FAIL."))
    PST.Newline
  
  PST.Str(STRING("STARTING PROP COM."))
  PST.Newline
  
  if(PRP.StartRxTx(RX_PROP, TX_PROP, 0, 115200))
    PST.Str(STRING("PROP COM Success."))
    PST.Newline
  else
    PST.Str(STRING("PROP COM FAIL."))
    PST.Newline

  'READY?!
  
  PST.Str(STRING("Ready"))
  PST.Newline

  repeat                                    
    PST.StrIn(@str_test)
    Parse(@str_test, @opcode, 0,5)
    
    if StrCount(STRING("START"),@opcode)
      QUIT
    else
      PST.Str(STRING("WRONG CMD"))
      PST.Newline

  PST.Str(STRING("Starting Test..."))
  PST.Newline

  PST.Str(STRING("Turn on PWR."))
  PST.Newline

  OUTA[PWR_ON] := 0


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