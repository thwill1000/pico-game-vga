'PicoGame Test Program - prototype

MODE 1
Font 3
CLS
Print "PicoGAME VGA Test Suite   PROTOTYPE ONLY"
TILE 0,0,RGB(white),RGB(blue),26
TILE 26,0,RGB(white),RGB(red),14
Print
Print "This test suite will check the operation"
Print "of a PicoGAME VGA. It is intended to"
Print "give a quick check after construction."
Print
Print "At each stage you have the opportunity"
Print "to either continue to the next or to"
Print "quit so that you have the opportunity to"
Print "fix any problems as you go along."
Print
Print "Ideally you will have a DB9 plug to fit"
Print "the Ports - it just makes life a bit"
Print "easier than holding wires onto the pins."
Print
Print "There are tests for the Controllers, but"
Print "these can be skipped if you don't have"
Print "them."
Print
Print
Print
Print "Press a key to continue"
Print
Print "The LED on the front should flash then"
Print "remain on Red"
Do
Loop Until Inkey$>""

'Flash the LED on the prototype board
SetPin gp15,dout
Pin(gp15)=0
For i=0 To 9
 Pin(GP15)=Not(Pin(gp15))
 Pause 500
Next
SetPin gp15,off

'=========== KEYBOARD ===========

MODE 1
Font 3
CLS
Print "Keyboard Test"
TILE 0,0,RGB(white),RGB(blue),40
Print
Print
Print "This is a very simple test to ensure"
Print "that you have a minimally working"
Print "keyboard."
Print
Print "Press any 10 alphanumeric keys"
Print
For i=1 To 10
Do
 k$=UCase$(Inkey$)
 a=Instr("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",k$)
Loop Until a>0
Print k$" ";
Next
Print
Print
Print "If you can see the 10 characters then"
Print "your keyboard is probably ok."
Print
Print "Press a key to continue"
Do
Loop Until Inkey$>""


'=========== COLOURS ============

MODE 1
Font 3
CLS
Print "Colour Test"
TILE 0,0,RGB(white),RGB(blue),40
Print
Print "WHITE  YELLOW  LILAC  BROWN  FUCHSIA"
Print
Print "RUST   MAGENTA RED    CYAN   GREEN  "
Print
Print "CERULEAN  MIDGREEN  "
Print
Print "COBALT    MYRTLE      BLUE   BLACK  "
Print
TILE 0,2,RGB(black),RGB(white),6
TILE 7,2,RGB(black),RGB(yellow),7
TILE 15,2,RGB(black),RGB(lilac),6
TILE 22,2,RGB(black),RGB(brown),6
TILE 29,2,RGB(black),RGB(fuchsia),8
TILE 0,4,RGB(black),RGB(rust),6
TILE 7,4,RGB(black),RGB(magenta),7
TILE 15,4,RGB(white),RGB(red),6
TILE 22,4,RGB(black),RGB(cyan),6
TILE 29,4,RGB(black),RGB(green),8
TILE 0,6,RGB(white),RGB(cerulean),9
TILE 10,6,RGB(white),RGB(midgreen),9
TILE 0,8,RGB(white),RGB(cobalt),7
TILE 10,8,RGB(white),RGB(myrtle),7
TILE 22,8,RGB(white),RGB(blue),6
TILE 29,8,RGB(white),RGB(black),6
Print
Print "The background colours should match the"
Print "colour names."
Print
Print
Print "Press Q to quit or Y to continue"
Do
a=Instr("qQyY",Inkey$)
If a=1 Or a=2 Then End
If a=3 Or a=4 Then Exit
Loop

'============== I/O PINS ============

MODE 1
Font 3
CLS
Print "Identification of I/O pins"
TILE 0,0,RGB(white),RGB(blue),40
Print
Print "       PORT A       PORT B"
Print
Print "     1 2 3 4 5    1 2 3 4 5"
Print
Print "      6 7 8 9      6 7 8 9 "
Print
Print
Print "Pin 8 is common GND."
Print
Print "Pins 6 and 7 should both have 3V3 to GND"
Print
Print "All I/O pins are digital inputs for this"
Print "test."
Print
Print "Short RED pins to ground and GREEN pins"
Print "to 3V3 to test."
Print
Print "Shorting pin 7 on Port B to GND will"
Print "short out the power and cause a reset!"
TILE 0,9,RGB(cyan),,40,12
Print
Print
Print "Press Q to quit or Y to continue"
SetPin gp0,din
SetPin gp1,din
SetPin gp2,din
SetPin gp3,din
SetPin gp4,din
SetPin gp5,din
SetPin gp22,din
SetPin gp14,din

SetPin gp15,dout

SetPin gp26,din
SetPin gp27,din
SetPin gp28,din

Do
If Pin(gp0)=1 Then TILE 7,4,RGB(red) Else TILE 7,4,RGB(green)
If Pin(gp1)=1 Then TILE 9,4,RGB(red) Else TILE 9,4,RGB(green)
If Pin(gp2)=1 Then TILE 11,4,RGB(red) Else TILE 11,4,RGB(green)
If Pin(gp28)=1 Then TILE 12,6,RGB(red) Else TILE 12,6,RGB(green)

If Pin(gp3)=1 Then TILE 18,4,RGB(red) Else TILE 18,4,RGB(green)
If Pin(gp4)=1 Then TILE 20,4,RGB(red) Else TILE 20,4,RGB(green)
If Pin(gp5)=1 Then TILE 22,4,RGB(red) Else TILE 22,4,RGB(green)
If Pin(gp22)=1 Then TILE 24,4,RGB(red) Else TILE 24,4,RGB(green)

If Pin(gp14)=1 Then TILE 19,6,RGB(red) Else TILE 19,6,RGB(green)
If Pin(gp26)=1 Then TILE 26,4,RGB(red) Else TILE 26,4,RGB(green)
If Pin(gp27)=1 Then TILE 25,6,RGB(red) Else TILE 25,6,RGB(green)
Pause 10

a=Instr("qQyY",Inkey$)
If a=1 Or a=2 Then End
If a=3 Or a=4 Then Exit

Loop

'========= ANALOGUE INPUTS =========

MODE 1
Font 3
CLS
Print "Analogue input tests"
TILE 0,0,RGB(white),RGB(blue),40
Print
Print "Ensure that all three links on LB1 are"
Print "in the UP position before continuing."
Print
Print "Press a key when ready"
Do
Loop Until Inkey$>""
SetPin gp26, ain
SetPin gp27, ain
SetPin gp28, ain
Print "All inputs should be close to 3.3V"
Print "10k to GND should give approx. 1.6V"
Text 2,280,"Press Q to quit or Y to continue"
Do
Text 5,170,"  Port B Pin 5 (GP26) = "
Print Str$(Pin(gp26),1,2)
Pause 5
Text 5,200,"  Port B Pin 9 (GP27) = "
Print Str$(Pin(gp27),1,2)
Pause 5
Text 5,230,"  Port A Pin 9 (GP28) = "
Print Str$(Pin(gp28),1,2)
Pause 40

a=Instr("qQyY",Inkey$)
If a=1 Or a=2 Then End
If a=3 Or a=4 Then Exit

Loop

Text 0,290,""
Print "Ensure that all three links on LB1 are"
Print "in the DN position before continuing."
Print
Print "Press a key when ready"
CLS
Print "Analogue input tests"
TILE 0,0,RGB(white),RGB(blue),40
Print
Print "All inputs should be close to 0V"
Print "10k to 3V3 should give approx. 1.6V"
Text 2,280,"Press Q to quit or Y to continue"
Do
Text 5,170,"  Port B Pin 5 (GP26) = "
Print Str$(Pin(gp26),1,2)
Pause 5
Text 5,200,"  Port B Pin 9 (GP27) = "
Print Str$(Pin(gp27),1,2)
Pause 5
Text 5,230,"  Port A Pin 9 (GP28) = "
Print Str$(Pin(gp28),1,2)
Pause 40
a=Instr("qQyY",Inkey$)
If a=1 Or a=2 Then End
If a=3 Or a=4 Then Exit

Loop

'====== CONTROLLERS - PORT A =======

MODE 1
Font 3
CLS
Print "Controller tests - Port A"
TILE 0,0,RGB(white),RGB(blue),40
Print
Print "For these tests you will need a"
Print "NES-compatible controller with a DB9"
Print "9-pin plug."
Print
Print "Press S to skip these tests or Y"
Print "to continue"
Do
a=Instr("sSyY",Inkey$)
If a=1 Or a=2 Then GoTo Audio 'Look! A GOTO instruction! Destroy the evil! :)
If a=3 Or a=4 Then Exit
Loop
Print
Print "Plug the Controller into Port A"
Print "Press a key when ready"

Do
Loop Until Inkey$>""

Const a_dat=1   'GP0
Const a_latch=2 'GP1
Const a_clk=4   'GP2
Const pulse_len!=0.012 '12uS
SetPin a_dat, din
SetPin a_latch, dout
SetPin a_clk, dout
Pin(a_latch)=0
Pin(a_clk)=0

i=0
out=0
Print
Print "Press Q to quit or Y to continue"
Do
 Pulse a_latch, pulse_len!
 out=&h0
 For i=0 To 7
  If Not Pin(a_dat) Then out=out Or 2^i
  Pulse a_clk, pulse_len!
 Next

 Text 3,240,""
 Print
 Print "    ##                    TB  TA"
 Print "    ##                    @@  @@"
 Print "  ##  ##                  @@  @@"
 Print "  ##  ##"
 Print "    ##    Select  Start   @@  @@"
 Print "    ##      ##      ##    @@  @@"
 Print "                          B   A"

 If out And &h01 Then TILE 30,20,RGB(red),,2,2 Else TILE 30,20,RGB(blue),,2,2
 If out And &h02 Then TILE 26,20,RGB(red),,2,2 Else TILE 26,20,RGB(blue),,2,2
 If out And &h04 Then TILE 12,21,RGB(red),,2 Else TILE 12,21,RGB(blue),,2
 If out And &h08 Then TILE 20,21,RGB(red),,2 Else TILE 20,21,RGB(blue),,2
 If out And &h10 Then TILE 4,16,RGB(red),,2,2 Else TILE 4,16,RGB(blue),,2,2
 If out And &h20 Then TILE 4,20,RGB(red),,2,2 Else TILE 4,20,RGB(blue),,2,2
 If out And &h40 Then TILE 2,18,RGB(red),,2,2 Else TILE 2,18,RGB(blue),,2,2
 If out And &h80 Then TILE 6,18,RGB(red),,2,2 Else TILE 6,18,RGB(blue),,2,2

 a=Instr("qQyY",Inkey$)
 If a=1 Or a=2 Then End
 If a=3 Or a=4 Then Exit
Loop

'===== CONTROLLERS - PORT B =======

MODE 1
Font 3
CLS
Print "Controller tests - Port B"
TILE 0,0,RGB(white),RGB(blue),40
Print
Print
Print "Plug the Controller into Port B"
Print "Press a key when ready"

Do
Loop Until Inkey$>""

Const b_dat=6   'GP4
Const b_latch=7 'GP5
Const b_clk=29   'GP22
SetPin b_dat, din
SetPin b_latch, dout
SetPin b_clk, dout
Pin(b_latch)=0
Pin(b_clk)=0

i=0
out=0
Print
Print "Press Q to quit or Y to continue"

Do
 Pulse b_latch, pulse_len!
 out=&h0
 For i=0 To 7
  If Not Pin(b_dat) Then out=out Or 2^i
  Pulse b_clk, pulse_len!
 Next
 Text 3,240,""
 Print
 Print "    ##                    TB  TA"
 Print "    ##                    @@  @@"
 Print "  ##  ##                  @@  @@"
 Print "  ##  ##"
 Print "    ##    Select  Start   @@  @@"
 Print "    ##      ##      ##    @@  @@"
 Print "                          B   A"

 If out And &h01 Then TILE 30,20,RGB(red),,2,2 Else TILE 30,20,RGB(blue),,2,2
 If out And &h02 Then TILE 26,20,RGB(red),,2,2 Else TILE 26,20,RGB(blue),,2,2
 If out And &h04 Then TILE 12,21,RGB(red),,2 Else TILE 12,21,RGB(blue),,2
 If out And &h08 Then TILE 20,21,RGB(red),,2 Else TILE 20,21,RGB(blue),,2
 If out And &h10 Then TILE 4,16,RGB(red),,2,2 Else TILE 4,16,RGB(blue),,2,2
 If out And &h20 Then TILE 4,20,RGB(red),,2,2 Else TILE 4,20,RGB(blue),,2,2
 If out And &h40 Then TILE 2,18,RGB(red),,2,2 Else TILE 2,18,RGB(blue),,2,2
 If out And &h80 Then TILE 6,18,RGB(red),,2,2 Else TILE 6,18,RGB(blue),,2,2

 a=Instr("qQyY",Inkey$)
 If a=1 Or a=2 Then End
 If a=3 Or a=4 Then Exit
Loop

'=============== AUDIO =============

Audio:
MODE 1
Font 3
CLS
Print "Audio tests"
TILE 0,0,RGB(white),RGB(blue),40
Print
Print "For these tests you will need a pair of"
Print "earphones or headphones. You need to"
Print "know which are the Left and Right"
Print "channels."
Print
Print "After carrying out channel recognition"
Print "you can connect the output to a low"
Print "level amplifier and speakers."
Print
Print "Connect both links of LB2 to the H"
Print "position and connect the headphones."
Print "Press a key to continue"
Print
Print
Print "Press L for a low Left tone"
Print "Press R for a high Right tone"
Print "Press Q to quit"
Do
 a=Instr("lLrRqQ",Inkey$)
 Select Case a
  Case 1,2
   Play tone 600,0,1000
  Case 3,4
   Play tone 0,1000,1000
  Case 5,6
   Exit
 End Select
Loop
Print
Print "Before connecting the PicoGAME VGA to an"
Print "amplifier or amplified speakers change "
Print "both links on LB2 to the L position."
Print
Print "Press a key to continue."
Do
Loop Until Inkey$>""


'=============== SD CARD ==============



'=============== COMPLETED ============

MODE 1
Font 3
CLS
Print "Tests Completed"
TILE 0,0,RGB(white),RGB(blue),40
Print
Print "You have now completed the test suite."
Print :Print :End
