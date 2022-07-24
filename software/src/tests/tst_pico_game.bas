' Copyright (c) 2022 Thomas Hugo Williams
' License MIT <https://opensource.org/licenses/MIT>
' For PicoMite VGA, MMBasic 5.07.05

Option Explicit On
Option Default None

#Include "../../../../sptools/src/splib/system.inc"
#Include "../../../../sptools/src/splib/array.inc"
#Include "../../../../sptools/src/splib/list.inc"
#Include "../../../../sptools/src/splib/string.inc"
#Include "../../../../sptools/src/splib/file.inc"
#Include "../../../../sptools/src/splib/map.inc"
#Include "../../../../sptools/src/splib/set.inc"
#Include "../../../../sptools/src/splib/vt100.inc"
#Include "../../../../sptools/src/sptest/unittest.inc"
#Include "../PicoGAME.inc"

Const TMP_DIR$ = sys.string_prop$("tmpdir")

add_test("test_read_inifile")
add_test("test_read_inifile_errors")
add_test("test_write_inifile")
add_test("test_get_prop")
add_test("test_put_prop")
add_test("test_read_ctrl_types")
add_test("test_ctrl_bits_to_string")

run_tests()

End

Sub test_read_inifile()
  Const f$ = TMP_DIR$ + "/test_read.ini"
  Local kv$(5), expected$(5)

  ' Test given file is empty.
  Open f$ For Output As #1
  Close #1
  assert_int_equals(0, read_inifile%(f$, kv$()))
  assert_string_array_equals(expected$(), kv$())

  ' Test given file has content.
  Open f$ For Output As #1
  Print #1, "port-a=nes"
  Print #1, "port-b=atari"
  Close #1
  assert_int_equals(2, read_inifile%(f$, kv$()))
  expected$(0) = "port-a=nes"
  expected$(1) = "port-b=atari"
  assert_string_array_equals(expected$(), kv$())

  ' Test given additional whitespace.
  Open f$ For Output As #1
  Print #1, "port-a = nes  "
  Print #1, "   port-b = atari"
  Close #1
  assert_int_equals(2, read_inifile%(f$, kv$()))
  assert_string_array_equals(expected$(), kv$())

  ' Test given comments.
  Open f$ For Output As #1
  Print #1, "; this is a comment"
  Print #1, "port-a=nes; and so"
  Print #1, "port-b=atari ; is this "
  Close #1
  assert_int_equals(2, read_inifile%(f$, kv$()))
  assert_string_array_equals(expected$(), kv$())

  ' Test given empty value.
  Open f$ For Output As #1
  Print #1, "port-a=nes"
  Print #1, "port-b=  "
  Close #1
  assert_int_equals(2, read_inifile%(f$, kv$()))
  expected$(1) = "port-b="
  assert_string_array_equals(expected$(), kv$())

  ' Test given too many values.
  Open f$ For Output As #1
  Print #1, "one=1"
  Print #1, "two=2"
  Print #1, "three=3"
  Print #1, "four=4"
  Print #1, "five=5"
  Print #1, "six=6"
  Print #1, "seven=7"
  Close #1
  assert_int_equals(7, read_inifile%(f$, kv$()))
  Local expected2$(5) = ("one=1", "two=2", "three=3", "four=4", "five=5", "six=6")
  assert_string_array_equals(expected2$(), kv$())
End Sub

Sub test_read_inifile_errors()
  Const f$ = TMP_DIR$ + "/test_read.ini"
  Local kv$(5)

  ' Test given file does not exist.
  assert_int_equals(-1, read_inifile%(TMP_DIR$ + "/does_not_exist", kv$()))

  ' Test given file is a directory.
  MkDir TMP_DIR$ + "/test_read_dir"
  assert_int_equals(-2, read_inifile%(TMP_DIR$ + "/test_read_dir", kv$()))
  Kill TMP_DIR$ + "/test_read_dir"

  ' Test given value without key.
  Open f$ For Output As #1
  Print #1, "port-a = nes"
  Print #1, "=atari"
  Close #1
  assert_int_equals(-3, read_inifile%(f$, kv$()))

  ' Test given key without value.
  Open f$ For Output As #1
  Print #1, "port-a = nes"
  Print #1, "atari"
  Close #1
  assert_int_equals(-4, read_inifile%(f$, kv$()))
End Sub

Sub test_write_inifile()
  Const f$ = TMP_DIR$ + "/test_write.ini"
  Local kv$(5) = ("port-a=nes", "port-b=atari", "", "", "", "")

  assert_int_equals(0, write_inifile%(f$, kv$()))

  Open f$ For Input As #1
  Local s$
  Line Input #1, s$
  assert_string_equals("port-a = nes", s$)
  Line Input #1, s$
  assert_string_equals("port-b = atari", s$)
  assert_true(Eof(#1))
  Close #1
End Sub

Sub test_get_prop()
  Const f$ = TMP_DIR$ + "/test_read.ini"
  Local kv$(5)

  Open f$ For Output As #1
  Print #1, "port-a=nes"
  Print #1, "port-b=atari"
  Close #1

  assert_int_equals(2, read_inifile%(f$, kv$()))

  assert_string_equals("nes",   get_prop$(kv$(), "port-a"))
  assert_string_equals("nes",   get_prop$(kv$(), "PORT-A"))
  assert_string_equals("atari", get_prop$(kv$(), "port-b"))
  assert_string_equals("",      get_prop$(kv$(), "port-c"))
  assert_string_equals("foo",   get_prop$(kv$(), "port-c", "foo"))
End Sub

Sub test_put_prop()
  Local expected$(5), kv$(5)

  assert_int_equals(0, put_prop%(kv$(), "foo", "bar"))
  expected$(0) = "foo=bar"
  assert_string_array_equals(expected$(), kv$())

  assert_int_equals(0, put_prop%(kv$(), "sna", "fu"))
  expected$(1) = "sna=fu"
  assert_string_array_equals(expected$(), kv$())

  assert_int_equals(0, put_prop%(kv$(), "FOO", "banana"))
  expected$(0) = "FOO=banana"
  assert_string_array_equals(expected$(), kv$())

  assert_int_equals(0, put_prop%(kv$(), "three", "apples"))
  expected$(2) = "three=apples"
  assert_int_equals(0, put_prop%(kv$(), "four", "pears"))
  expected$(3) = "four=pears"
  assert_int_equals(0, put_prop%(kv$(), "five", "oranges"))
  expected$(4) = "five=oranges"
  assert_int_equals(0, put_prop%(kv$(), "six", "grapes"))
  expected$(5) = "six=grapes"
  assert_string_array_equals(expected$(), kv$())

  ' Given too many properties.
  assert_int_equals(-1, put_prop%(kv$(), "seven", "kumquats"))
  assert_string_array_equals(expected$(), kv$())

  ' Given replacing existing property when at maximum number of properties.
  assert_int_equals(0, put_prop%(kv$(), "five", "kumquats"))
  expected$(4) = "five=kumquats"
  assert_string_array_equals(expected$(), kv$())
End Sub

Sub test_read_ctrl_types()
  Const f$ = TMP_DIR$ + "/test_read.ini"

  ' Given base case.
  Open f$ For Output As #1
  Print #1, "port-a=nes"
  Print #1, "port-b=atari"
  Close #1
  assert_string_equals("nes,atari", read_ctrl_types$(f$))

  ' Given no port-a or port-b keys.
  Open f$ For Output As #1
  Close #1
  assert_string_equals("none,none", read_ctrl_types$(f$))

  ' Given only port-a key.
  Open f$ For Output As #1
  Print #1, "port-a=nes"
  Close #1
  assert_string_equals("nes,none", read_ctrl_types$(f$))

  ' Given only port-b key.
  Open f$ For Output As #1
  Print #1, "port-b=atari"
  Close #1
  assert_string_equals("none,atari", read_ctrl_types$(f$))

  ' Given non-standard capitalisation.
  Open f$ For Output As #1
  Print #1, "PORT-A=nes"
  Print #1, "port-b=ATARI"
  Close #1
  assert_string_equals("nes,atari", read_ctrl_types$(f$))

  ' Given comments.
  Open f$ For Output As #1
  Print #1, "; This is a comment"
  Print #1, "port-a=nes;and so is this"
  Print #1, ";port-b=atari"
  Close #1
  assert_string_equals("nes,none", read_ctrl_types$(f$))

  ' Given keys in reverse order.
  Open f$ For Output As #1
  Print #1, "port-b=atari"
  Print #1, "port-a=nes"
  Close #1
  assert_string_equals("nes,atari", read_ctrl_types$(f$))

  ' Given additional key=value pairs.
  Open f$ For Output As #1
  Print #1, "one=apple"
  Print #1, "port-a=nes"
  Print #1, "two=orange"
  Print #1, "port-b=atari"
  Print #1, "three=pear"
  Close #1
  assert_string_equals("nes,atari", read_ctrl_types$(f$))
End Sub

Sub test_ctrl_bits_to_string()
  assert_string_equals("", ctrl_bits_to_string$("none", 0))
  assert_string_equals("241: Fire, Up, Down, Left, Right", ctrl_bits_to_string$("atari", &b11110001))
  assert_string_equals("255: A, B, Select, Start, Up, Down, Left, Right", ctrl_bits_to_string$("nes", &b11111111))
  assert_string_equals("4095: B, Y, Select, Start, Up, Down, Left, Right, A, X, L, R", ctrl_bits_to_string$("snes", &b111111111111))
End Sub
