jrl_test_case(
  NAME "Pass when no unparsed arguments"
  CODE [[
    cmake_parse_arguments(arg "" "ONE_VAL" "MULTI_VAL" ONE_VAL value1 MULTI_VAL a b c)

    _jrl_check_no_unrecognized_arguments(arg)
  ]]
)

jrl_test_case(
  NAME "Pass with only flags"
  CODE [[
    cmake_parse_arguments(arg2 "FLAG_A;FLAG_B" "" "" FLAG_A FLAG_B)

    _jrl_check_no_unrecognized_arguments(arg2)
  ]]
)

jrl_test_case(
  NAME "Pass when ARGN is empty"
  CODE [[
    cmake_parse_arguments(arg3 "" "" "" "")

    _jrl_check_no_unrecognized_arguments(arg3)
  ]]
)

jrl_test_case(
  NAME "Fatal error with unrecognized arguments"
  CODE [[
    cmake_parse_arguments(arg "" "ONE_VAL" "" UNEXPECTED_ARG)

    _jrl_check_no_unrecognized_arguments(arg)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error reports multiple unrecognized arguments"
  CODE [[
    cmake_parse_arguments(arg "" "" "" FOO BAR BAZ)

    _jrl_check_no_unrecognized_arguments(arg)
  ]]
  WILL_FAIL
)
