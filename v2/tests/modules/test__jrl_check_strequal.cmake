jrl_test_case(
  NAME "Pass when strings are equal"
  CODE [[
    _jrl_check_strequal("hello" "hello")
  ]]
)

jrl_test_case(
  NAME "Pass when both strings are empty"
  CODE [[
    _jrl_check_strequal("" "")
  ]]
)

jrl_test_case(
  NAME "Pass when variable value equals expected"
  CODE [[
    set(MY_VAR "Release")
    _jrl_check_strequal("${MY_VAR}" "Release")
  ]]
)

jrl_test_case(
  NAME "Fatal error when strings differ"
  CODE [[
    _jrl_check_strequal("foo" "bar")
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error when case differs"
  CODE [[
    _jrl_check_strequal("Release" "release")
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error when actual is empty but expected is not"
  CODE [[
    _jrl_check_strequal("" "something")
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error with default message mentions expected and actual values"
  CODE [[
    _jrl_check_strequal("foo" "bar")
  ]]
  PROPERTIES PASS_REGULAR_EXPRESSION "Expected.*bar|bar.*Expected"
)

jrl_test_case(
  NAME "Fatal error with custom message"
  CODE [[
    _jrl_check_strequal("foo" "bar" "MY_CUSTOM_MSG")
  ]]
  PROPERTIES PASS_REGULAR_EXPRESSION "MY_CUSTOM_MSG"
)
