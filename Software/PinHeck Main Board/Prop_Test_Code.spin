{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 6_500_000

        LEFT_BRACKET  = %01011011                       'assci for [
        RIGHT_BRACKET = %01011101                       'assci for ]

        W_OP          = %01110111                       'assci for w
        R_OP          = %01110010                       'assci for r

        
OBJ

        PST : "Parallax Serial Terminal"
        
VAR
  byte opcode[32]
  long blinkstack[50]

PUB MAIN | temp0, temp1, temp2

  PST.StartRxTx(31, 30, %0000, 9600)

  cognew(Blink, @blinkstack)


  repeat                                    
    PST.StrIn(@opcode)

    if (LEFT_BRACKET <> opcode[0]) OR (RIGHT_BRACKET <> opcode[5])
      PST.Str(STRING("{ERRO}"))
      PST.NewLine

    elseif (W_OP == opcode[1])
    
      temp0 := opcode[2]
      temp1 := opcode[3]

      temp0 := temp0 - 48
      temp1 := temp1 - 48

      temp2 := (temp0 * 10) + temp1

      if (temp2 < 0) OR (temp2 > 31) OR ((opcode[4] - 48) < 0 ) OR ((opcode[4] - 48) > 1)
        PST.Str(STRING("{ERR2}"))
        PST.NewLine

      else
        DIRA[temp2]~~
        if((opcode[4] - 48) == 0)      
          OUTA[temp2]~
        else
          OUTA[temp2]~~
          
        PST.Str(STRING("{wACK}"))
        PST.NewLine

    elseif (R_OP == opcode[1])
      'for reading states and sending back to fixture. FU.  


    else
      PST.Str(STRING("{ERR1}"))
      PST.NewLine

    waitcnt(cnt+clkfreq)


return

PUB Blink

  DIRA[27]~~


  repeat
    OUTA[27]~
    waitcnt((clkfreq>>1)+cnt)
    OUTA[27]~~
    waitcnt((clkfreq>>1)+cnt)
    

