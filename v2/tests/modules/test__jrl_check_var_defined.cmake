jrl_test_case(
  NAME "Pass when variable is defined"
  CODE [[
    set(MY_DEFINED_VAR "hello")

    _jrl_check_var_defined(MY_DEFINED_VAR)
  ]]
)

jrl_test_case(
  NAME "Pass when variable is defined as empty string"
  CODE [[
    set(MY_EMPTY_VAR "")

    _jrl_check_var_defined(MY_EMPTY_VAR)
  ]]
)

jrl_test_case(
  NAME "Fatal error with default message when variable is not defined"
  CODE [[
    _jrl_check_var_defined(UNDEFINED_VAR_XYZ)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error with custom message when variable is not defined"
  CODE [[
    _jrl_check_var_defined(ANOTHER_UNDEFINED_VAR "My custom error message")
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Pass when variable is defined with numeric value"
  CODE [[
    set(MY_NUMERIC_VAR 42)

    _jrl_check_var_defined(MY_NUMERIC_VAR)
  ]]
)
