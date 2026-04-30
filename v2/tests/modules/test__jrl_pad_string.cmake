jrl_test_case(
  NAME "Shorter string is padded to exact width"
  CODE [[
    _jrl_pad_string("foo" 6 result)
    _jrl_check_strequal("${result}" "foo   ")
  ]]
)

jrl_test_case(
  NAME "String at exact width is unchanged"
  CODE [[
    _jrl_pad_string("hello" 5 result)
    _jrl_check_strequal("${result}" "hello")
  ]]
)

jrl_test_case(
  NAME "String longer than width is truncated"
  CODE [[
    _jrl_pad_string("abcdefgh" 4 result)
    _jrl_check_strequal("${result}" "abcd")
  ]]
)

jrl_test_case(
  NAME "Empty string padded to width produces all spaces"
  CODE [[
    _jrl_pad_string("" 3 result)
    _jrl_check_strequal("${result}" "   ")
  ]]
)

jrl_test_case(
  NAME "Width zero returns empty string"
  CODE [[
    _jrl_pad_string("hello" 0 result)
    _jrl_check_strequal("${result}" "")
  ]]
)

jrl_test_case(
  NAME "Result has exactly the specified width when padded"
  CODE [[
    _jrl_pad_string("x" 10 result)
    string(LENGTH "${result}" len)
    if(NOT len EQUAL 10)
      message(FATAL_ERROR "Expected length 10, got ${len} for '${result}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "Result has exactly the specified width when truncated"
  CODE [[
    _jrl_pad_string("abcdefghij" 5 result)
    string(LENGTH "${result}" len)
    if(NOT len EQUAL 5)
      message(FATAL_ERROR "Expected length 5, got ${len} for '${result}'")
    endif()
  ]]
)
