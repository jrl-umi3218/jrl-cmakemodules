jrl_test_case(
  NAME "Pass when file exists"
  CODE [[
    _jrl_check_file_exists(${CMAKE_CURRENT_LIST_FILE})
  ]]
)

jrl_test_case(
  NAME "Pass with jrl.cmake"
  CODE [[
    _jrl_top_dir(top_dir)

    _jrl_check_file_exists(${top_dir}/modules/jrl.cmake)
  ]]
)

jrl_test_case(
  NAME "Fatal error with default message for non-existent file"
  CODE [[
    _jrl_check_file_exists("/this/file/does/not/exist.cmake")
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error with custom message for non-existent file"
  CODE [[
    _jrl_check_file_exists("/nonexistent/file.cmake" "Custom file missing message")
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Pass for a directory path (EXISTS is true for dirs too)"
  CODE [[
    _jrl_check_file_exists(${CMAKE_CURRENT_LIST_DIR})
  ]]
)
