' Copyright (c) 2022 Thomas Hugo Williams
' License MIT <https://opensource.org/licenses/MIT>
' For PicoMite VGA, MMBasic 5.07.05

' Note 1:
'   This code is written for readability and to avoid duplication, not for
'   performance. If in your own programs performance when reading the
'   controllers is an issue then:
'    - inline constants to avoid overhead of "variable" lookup.
'    - unroll FOR loops.
'    - shorten variable names.
'    - use different functions to read ports A and B so that pin numbers can
'      be hard-coded.
'    - in extremis inline the xxx_read%() functions to avoid the overhead
'      of a subroutine call.
'
' Note 2:
'   Variables with CAPITALISED names are constants, this includes arrays
'   which have to be declared with DIM and where constant-ness is not enforced
'   by the MMBasic interpreter.

If Mm.Info(Option Base) <> 0 Then Error "OPTION BASE 0 required"

Const PG_INI_FILE$ = "/PicoGAME.ini"

Const PORT_A% = 0
Const PORT_B% = 1

If InStr(Mm.Device$, "PicoMite") > 0 Then

' Pin mappings for ATARI 1-button joystick.
Dim ATARI_FIRE_PIN%(1)  = ( Mm.Info(PinNo GP14), Mm.Info(PinNo GP28) )
Dim ATARI_UP_PIN%(1)    = ( Mm.Info(PinNo  GP0), Mm.Info(PinNo GP28) )
Dim ATARI_DOWN_PIN%(1)  = ( Mm.Info(PinNo  GP1), Mm.Info(PinNo  GP1) )
Dim ATARI_LEFT_PIN%(1)  = ( Mm.Info(PinNo  GP2), Mm.Info(PinNo  GP2) )
Dim ATARI_RIGHT_PIN%(1) = ( Mm.Info(PinNo  GP3), Mm.Info(PinNo  GP3) )

' Pin mappings for NES/SNES gamepad.
Dim NES_CLOCK_PIN%(1) = ( Mm.Info(PinNo  GP3), Mm.Info(PinNo GP22) )
Dim NES_DATA_PIN%(1)  = ( Mm.Info(PinNo  GP1), Mm.Info(PinNo  GP4) )
Dim NES_LATCH_PIN%(1) = ( Mm.Info(PinNo  GP2), Mm.Info(PinNo  GP5) )

EndIf

' The NES standard specifies a 12 micro-second pulse, but all the controllers
' I've tested work with 1 micro-second, and possibly less.
Const NES_PULSE_DURATION! = 0.001 ' 1 micro-second

Dim CONTROLLER_IDS$(3) Length 5 = ( "none", "atari", "nes", "snes" )
Dim CONTROLLER_NAMES$(3) Length 15 = ( "None", "Atari Joystick", "NES Gamepad" , "SNES Gamepad" )

' +----------------------------------------------------------------------------+
' |                        WORKING WITH THE .INI FILE                          |
' +----------------------------------------------------------------------------+

' Reads an array of "key=value" pairs from a .INI file.
'
' @param[in]   f$     path of the file to read.
' @param[out]  kv$()  array to store "key=value" pairs in.
' @return             number of pairs read on success,
'                     if the file contains more pairs than can be stored in the
'                     array then the extra pairs will be included in this count,
'                     but not stored.
'                     -1 if the file does not exist.
'                     -2 if the file is a directory.
'                     -3 if the file contained a value without a key.
'                     -4 if the file contained a key without a value.
'                     -5 if the file contained too many key/value pairs.
Function read_inifile%(f$, kv$())
  Local idx%, key$, value$, p%, s$

  Select Case Mm.Info(FileSize f$)
    Case -2 : read_inifile% = -2
    Case -1 : read_inifile% = -1
  End Select
  If read_inifile% Then Exit Function

  Open f$ For Input As #1

  ' TODO: support quoted string values.
  ' TODO: support escapes for = and ; characters.
  Do While Not Eof(#1)
    Line Input #1, s$
    p% = InStr(s$, ";")
    If p% > 0 Then s$ = Left$(s$, p% - 1)
    s$ = trim$(s$)
    If s$ = "" Then Continue Do
    p% = InStr(s$, "=")
    key$ = Choice(p% = 0, s$, trim$(Left$(s$, p% - 1)))
    value$ = Choice(p% = 0, "", trim$(Mid$(s$, p% + 1)))
    If key$ = "" Then read_inifile% = -3
    If value$ = "" And p% = 0 Then read_inifile% = -4
    If read_inifile% <> 0 Then Exit Do
    If idx% <= Bound(kv$(), 1) Then kv$(idx%) = key$ + "=" + value$
    Inc idx%
  Loop

  If Not read_inifile% Then read_inifile% = idx%

  Close #1
End Function

' Writes an array of "key=value" pairs as a .INI file.
Function write_inifile%(f$, kv$())
  Open f$ For Output As #1
  Local i%
  For i% = Bound(kv$(), 0) To Bound(kv$(), 1)
    If kv$(i%) = "" Then Exit For
    Print #1, Field$(kv$(i%), 1, "=") " = " Field$(kv$(i%), 2, "=")
  Next
  Close #1
End Function

' Gets the value corresponding to a key from an array of "key=value" pairs.
'
' Currently performs a linear lookup as the array is not expected to be large.
'
' @param kv$       array of "key=value" pairs to search.
' @param key$      case-insensitive key to search for.
' @param default$  value to return if the key is not present.
' @return          value corresponding to the key, or default$ if not present.
Function get_prop$(kv$(), key$, default$)
  Local i%
  For i% = Bound(kv$(), 0) To Bound(kv$(), 1)
    If kv$(i%) = "" Then Exit For
    If LCase$(Field$(kv$(i%), 1, "=")) = LCase$(key$) Then
      get_prop$ = Field$(kv$(i%), 2, "=")
      Exit Function
    EndIf
  Next
  get_prop$ = default$
End Function

' Adds a "key=value" pair to an array of such values.
' If the key already exists then replaces the existing value.
'
' @param kv$     array of "key=value" pairs to search.
' @param key$    case-insensitive key to add.
' @param value$  value to add.
' @return        0 on success,
'                -1 if the array is full unless key is already present.
Function put_prop%(kv$(), key$, value$)
  Local i%, lkey$ = LCase$(key$), s$
  For i% = Bound(kv$(), 0) To Bound(kv$(), 1)
    Select Case LCase$(Field$(kv$(i%), 1, "="))
      Case "", lkey$
        kv$(i%) = key$ + "=" + value$
        Exit Function
    End Select
  Next
  put_prop% = -1
End Function

' +----------------------------------------------------------------------------+
' |                         READING GAME CONTROLLERS                           |
' +----------------------------------------------------------------------------+

' Reads values corresponding to the "port-a" and "port-b" keys from a .INI file.
'
' @param f$  optional file-path, if unspecified then reads "/PicoGAME.ini"
' @return    comma-separated pair of values, if either "port-a" or "port-b" is
'            missing then the value "none" is used for them.
'            Each value is expected to be one of "atari", "nes", "snes" or
'            "none" but that is not enforced by this function.
Function read_ctrl_types$(f$)
  Local p%, port_a$ = "none", port_b$ = "none", s$
  Open Choice(f$ = "", PG_INI_FILE$, f$) For Input As #1
  Do While Not Eof(#1)
    Line Input #1, s$
    p% = InStr(s$, ";") ' semi-colon is used to start a comment.
    If p% > 0 Then s$ = Left$(s$, p% - 1)
    s$ = LCase$(s$)
    If trim$(Field$(s$, 1, "=")) = "port-a" Then port_a$ = trim$(Field$(s$, 2, "="))
    If trim$(Field$(s$, 1, "=")) = "port-b" Then port_b$ = trim$(Field$(s$, 2, "="))
  Loop
  Close #1
  read_ctrl_types$ = port_a$ + "," + port_b$
End Function

' Initialises a port connected to an ATARI 1-button joystick.
'
' @param idx%   controller port: only port A = 0 is supported.
Sub atari_init(idx%)
  SetPin ATARI_UP_PIN%(idx%), DIn
  SetPin ATARI_DOWN_PIN%(idx%), DIn
  SetPin ATARI_LEFT_PIN%(idx%), DIn
  SetPin ATARI_RIGHT_PIN%(idx%), DIn
  SetPin ATARI_FIRE_PIN%(idx%), DIn
End Sub

' Reads a port connected to an ATARI 1-button joystick.
'
' @param idx%   controller port: only port A = 0 is supported.
' @return       bitmap corresponding to current controller state:
'                 7 6 5 4 3 2 1 0
'                 | | | | | | | |
'                 | | | | | | | +-- Fire Button
'                 | | | | | | +---- unused
'                 | | | | | +------ unused
'                 | | | | +-------- unused
'                 | | | +---------- Up
'                 | | +------------ Down
'                 | +-------------- Left
'                 +---------------- Right
Function atari_read%(idx%)
  Inc atari_read%, Not Pin(ATARI_FIRE_PIN%(idx%))
  Inc atari_read%, Not Pin(ATARI_UP_PIN%(idx%)) * 16
  Inc atari_read%, Not Pin(ATARI_DOWN_PIN%(idx%)) * 32
  Inc atari_read%, Not Pin(ATARI_LEFT_PIN%(idx%)) * 64
  Inc atari_read%, Not Pin(ATARI_RIGHT_PIN%(idx%)) * 128
End Function

' Initialises a port connected to a SNES gamepad.
' - this is the same intialisation as an NES gamepad.
'
' @param idx%   controller port: A = 0 or B = 1.
Sub snes_init(idx%)
  nes_init(idx%)
End Sub

' Reads a port connected to a SNES gamepad.
'
' @param idx%   controller port: A = 0 or B = 1.
' @return       bitmap corresponding to current controller state:
'                 11 10 9 8 7 6 5 4 3 2 1 0
'                 |  |  | | | | | | | | | |
'                 |  |  | | | | | | | | | +-- Button B
'                 |  |  | | | | | | | | +---- Button Y
'                 |  |  | | | | | | | +------ Select
'                 |  |  | | | | | | +-------- Start
'                 |  |  | | | | | +---------- Up
'                 |  |  | | | | +------------ Down
'                 |  |  | | | +-------------- Left
'                 |  |  | | +---------------- Right
'                 |  |  | +------------------ Button A
'                 |  |  +-------------------- Button X
'                 |  +----------------------- Left Bumper
'                 +-------------------------- Right Bumper
Function snes_read%(idx%)
  Local i%
  Pulse NES_LATCH_PIN%(idx%), NES_PULSE_DURATION!
  For i% = 0 To 11
    Inc snes_read%, Not Pin(NES_DATA_PIN%(idx%)) * 2^i%
    Pulse NES_CLOCK_PIN%(idx%), NES_PULSE_DURATION!
  Next
End Function

' Initialises a port connected to a NES gamepad.
'
' @param idx%   controller port: A = 0 or B = 1.
Sub nes_init(idx%)
  SetPin NES_LATCH_PIN%(idx%), Dout
  SetPin NES_CLOCK_PIN%(idx%), Dout
  SetPin NES_DATA_PIN%(idx%), Din
  Pin(NES_LATCH_PIN%(idx%)) = 0
  Pin(NES_CLOCK_PIN%(idx%)) = 0
End Sub

' Reads a port connected to a NES gamepad.
'
' @param idx%   controller port: A = 0 or B = 1.
' @return       bitmap corresponding to current controller state:
'                 7 6 5 4 3 2 1 0
'                 | | | | | | | |
'                 | | | | | | | +-- Button A
'                 | | | | | | +---- Button B
'                 | | | | | +------ Select
'                 | | | | +-------- Start
'                 | | | +---------- Up
'                 | | +------------ Down
'                 | +-------------- Left
'                 +---------------- Right
'
' Note that in theory it should not be necessary to pulse the clock pin after
' reading bit 7 (Right), but in practice there are some clone NES controllers
' which return the wrong value on subsequent reads of bit 7 if it not pulsed.
Function nes_read%(idx%)
  Local i%
  Pulse NES_LATCH_PIN%(idx%), NES_PULSE_DURATION!
  For i% = 0 To 7
    Inc nes_read%, Not Pin(NES_DATA_PIN%(idx%)) * 2^i%
    Pulse NES_CLOCK_PIN%(idx%), NES_PULSE_DURATION!
  Next
End Function

' Gets a string representation of bits read from a controller.
'
' @param id$    controller Id from CONTROLLER_IDS$().
' @param bits%  controller state returned by xxx_read%() function.
Function ctrl_bits_to_string$(id$, bits%)
  ' These are the names of the buttons on a SNES controller;
  ' we adjust them in the SELECT CASE below for NES/ATARI names.
  Static BUTTONS$(11) = ("B","Y","Select","Start","Up","Down","Left","Right","A","X","L","R")

  If bits% = 0 Then Exit Function

  ctrl_bits_to_string$ = Str$(bits%) + " = "
  Local count%, i%, s$
  For i% = 0 To Bound(BUTTONS$(), 1)
    If bits% And 2^i% Then
      s$ = BUTTONS$(i%)
      Select Case id$
        Case "atari"
          If s$ = "B" Then s$ = "Fire"
        Case "nes"
          If s$ = "B" Then s$ = "A"
          If s$ = "Y" Then s$ = "B"
        Case "none", "snes"
          ' No extra manipulation.
        Case Else
          Error "Unknown controller: " + id$
      End Select
      If count% > 0 Then Cat ctrl_bits_to_string$, ", "
      Cat ctrl_bits_to_string$, s$
      Inc count%
    EndIf
  Next
End Function

' +----------------------------------------------------------------------------+
' |                            STRING MANIPULATION                             |
' +----------------------------------------------------------------------------+

' Gets a string padded to a given width with spaces to the right.
'
' @param s$  the string.
' @param w%  the width.
' @return    the padded string.
'            If Len(s$) > w% then returns the unpadded string.
Function rpad$(s$, w%)
  rpad$ = s$
  If Len(s$) < w% Then Cat rpad$$, Space$(w% - Len(s$))
End Function

' Gets a new string by trimming leading and trailing spaces from a given string.
Function trim$(s$)
  Local st%, en%
  For st% = 1 To Len(s$)
    If Peek(Var s$, st%) <> 32 Then Exit For
  Next
  For en% = Len(s$) To 1 Step -1
    If Peek(Var s$, en%) <> 32 Then Exit For
  Next
  If en% >= st% Then trim$ = Mid$(s$, st%, en% - st% + 1)
End Function
