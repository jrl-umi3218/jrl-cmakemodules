jrl_test_case(
  NAME "_jrl_check: pass with DEFINED condition (var defined)"
  CODE [[
    set(MY_VAR "hello")
    _jrl_check(DEFINED MY_VAR)
  ]]
)

jrl_test_case(
  NAME "_jrl_check: fail with DEFINED condition (var not defined)"
  CODE [[
    _jrl_check(DEFINED UNDEFINED_VAR_XYZ)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "_jrl_check: pass with NOT TARGET condition (target does not exist)"
  CODE [[
    _jrl_check(NOT TARGET nonexistent_target_xyz)
  ]]
)

jrl_test_case(
  NAME "_jrl_check: fail with TARGET condition (target does not exist)"
  CODE [[
    _jrl_check(TARGET nonexistent_target_xyz)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "_jrl_check: pass with STREQUAL condition"
  CODE [[
    set(MY_VAR "Release")
    _jrl_check("${MY_VAR}" STREQUAL "Release")
  ]]
)

jrl_test_case(
  NAME "_jrl_check: fail with STREQUAL condition"
  CODE [[
    set(MY_VAR "Debug")
    _jrl_check("${MY_VAR}" STREQUAL "Release")
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "_jrl_check: pass with numeric GREATER condition"
  CODE [[
    _jrl_check(5 GREATER 3)
  ]]
)

jrl_test_case(
  NAME "_jrl_check: fail with numeric GREATER condition"
  CODE [[
    _jrl_check(1 GREATER 5)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "_jrl_check: fail shows condition in default message"
  CODE [[
    _jrl_check(DEFINED UNDEFINED_VAR_XYZ)
  ]]
  PROPERTIES PASS_REGULAR_EXPRESSION "Condition failed: DEFINED UNDEFINED_VAR_XYZ"
)

jrl_test_case(
  NAME "_jrl_check: fail shows custom ERROR_MESSAGE"
  CODE [[
    _jrl_check(DEFINED UNDEFINED_VAR_XYZ ERROR_MESSAGE "My custom error message")
  ]]
  PROPERTIES PASS_REGULAR_EXPRESSION "My custom error message"
)

jrl_test_case(
  NAME "_jrl_check: pass with NOT condition"
  CODE [[
    _jrl_check(NOT DEFINED UNDEFINED_VAR_XYZ)
  ]]
)

jrl_test_case(
  NAME "_jrl_check: pass with EXISTS condition"
  CODE [[
    _jrl_check(EXISTS "${CMAKE_CURRENT_LIST_FILE}")
  ]]
)
