jrl_test_case(
  NAME "Pass when directory exists"
  CODE [[
    _jrl_check_dir_exists(${CMAKE_CURRENT_LIST_DIR})
  ]]
)

jrl_test_case(
  NAME "Pass with repo root directory"
  CODE [[
    _jrl_check_dir_exists(${CMAKE_CURRENT_LIST_DIR}/../..)
  ]]
)

jrl_test_case(
  NAME "Fatal error with default message for non-existent directory"
  CODE [[
    _jrl_check_dir_exists("/this/directory/does/not/exist/at/all")
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error with custom message for non-existent directory"
  CODE [[
    _jrl_check_dir_exists("/nonexistent/path" "Custom directory missing message")
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error for a file path (not a directory)"
  CODE [[
    _jrl_check_dir_exists("${CMAKE_CURRENT_LIST_FILE}")
  ]]
  WILL_FAIL
)
