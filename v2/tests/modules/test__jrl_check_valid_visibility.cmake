jrl_test_case(
  NAME "Pass with PRIVATE"
  CODE [[
    _jrl_check_valid_visibility(PRIVATE)
  ]]
)

jrl_test_case(
  NAME "Pass with PUBLIC"
  CODE [[
    _jrl_check_valid_visibility(PUBLIC)
  ]]
)

jrl_test_case(
  NAME "Pass with INTERFACE"
  CODE [[
    _jrl_check_valid_visibility(INTERFACE)
  ]]
)

jrl_test_case(
  NAME "Fatal error for invalid visibility value"
  CODE [[
    _jrl_check_valid_visibility(INVALID)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error for lowercase visibility"
  CODE [[
    _jrl_check_valid_visibility(private)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error for unrelated string value"
  CODE [[
    _jrl_check_valid_visibility(VISIBILITY)
  ]]
  WILL_FAIL
)
