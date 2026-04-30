jrl_test_case(
  NAME "Pass when variable is not defined"
  CODE [[
    _jrl_check_var_not_defined(SOME_UNDEFINED_VAR_XYZ)
  ]]
)

jrl_test_case(
  NAME "Pass when variable is unset after being set"
  CODE [[
    set(MY_VAR "hello")
    unset(MY_VAR)
    _jrl_check_var_not_defined(MY_VAR)
  ]]
)

jrl_test_case(
  NAME "Fatal error with default message when variable is defined"
  CODE [[
    set(MY_DEFINED_VAR "hello")
    _jrl_check_var_not_defined(MY_DEFINED_VAR)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error with default message when variable is defined as empty string"
  CODE [[
    set(MY_EMPTY_VAR "")
    _jrl_check_var_not_defined(MY_EMPTY_VAR)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error with custom message when variable is defined"
  CODE [[
    set(MY_DEFINED_VAR "value")
    _jrl_check_var_not_defined(MY_DEFINED_VAR "MY_CUSTOM_ERROR")
  ]]
  PROPERTIES PASS_REGULAR_EXPRESSION "MY_CUSTOM_ERROR"
)

jrl_test_case(
  NAME "Fatal error default message contains variable name and value"
  CODE [[
    set(MY_DEFINED_VAR "secret_value")
    _jrl_check_var_not_defined(MY_DEFINED_VAR)
  ]]
  PROPERTIES PASS_REGULAR_EXPRESSION "MY_DEFINED_VAR"
)
