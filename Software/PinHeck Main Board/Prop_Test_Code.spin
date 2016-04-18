{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        LEFT_BRACKET  = %01011011                       'assci for [
        RIGHT_BRACKET = %01011101                       'assci for ]

        W_OP          = %01110111                       'assci for w
        R_OP          = %01110010                       'assci for r

        
OBJ

        PST : "Parallax Serial Terminal"
        
VAR
  byte str_test[32]
  byte opcode[32]
  byte ostr[32] 

PUB MAIN | temp0, temp1, temp2

  PST.Start(115200) 

  repeat                                    
    PST.StrIn(@opcode)

    if (LEFT_BRACKET <> opcode[0]) OR (RIGHT_BRACKET <> opcode[5])
      PST.Str(STRING("{ERRO}"))

    elseif (W_OP == opcode[1])
    
      temp0 := opcode[2]
      temp1 := opcode[3]

      temp0 := temp0 - 48
      temp1 := temp1 - 48

      temp2 := (temp0 * 10) + temp1

      if (temp2 < 0) OR (temp2 > 31) OR ((opcode[4] - 48) < 0 ) OR ((opcode[4] - 48) > 1)
        PST.Str(STRING("{ERR2}"))

      else
        DIRA[temp2]~~
        if((opcode[4] - 48) == 0)      
          OUTA[temp2]~
        else
          OUTA[temp2]~~
          
        PST.Str(STRING("{wACK}"))

    elseif (R_OP == opcode[1])
      'for reading states and sending back to fixture. FU.  


    else
      PST.Str(STRING("{ERR1}"))


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
