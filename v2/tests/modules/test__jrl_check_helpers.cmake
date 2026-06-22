# ---------------------------------------------------------------------------
# _jrl_check_var_defined
# ---------------------------------------------------------------------------

jrl_test_case(
  NAME "_jrl_check_var_defined: pass when variable is defined"
  CODE [[
    set(MY_VAR "hello")
    _jrl_check_var_defined(MY_VAR)
  ]]
)

jrl_test_case(
  NAME "_jrl_check_var_defined: pass when variable is defined as empty string"
  CODE [[
    set(MY_EMPTY_VAR "")
    _jrl_check_var_defined(MY_EMPTY_VAR)
  ]]
)

jrl_test_case(
  NAME "_jrl_check_var_defined: fail with default message for undefined variable"
  CODE [[
    _jrl_check_var_defined(UNDEFINED_VAR_XYZ)
  ]]
  PROPERTIES PASS_REGULAR_EXPRESSION "Variable 'UNDEFINED_VAR_XYZ' is not defined\\."
)

jrl_test_case(
  NAME "_jrl_check_var_defined: fail with custom message for undefined variable"
  CODE [[
    _jrl_check_var_defined(UNDEFINED_VAR_XYZ "Custom: set UNDEFINED_VAR_XYZ first")
  ]]
  PROPERTIES PASS_REGULAR_EXPRESSION "Custom: set UNDEFINED_VAR_XYZ first"
)

# ---------------------------------------------------------------------------
# _jrl_check_file_exists
# ---------------------------------------------------------------------------

jrl_test_case(
  NAME "_jrl_check_file_exists: pass for an existing file"
  CODE [[
    _jrl_check_file_exists("${CMAKE_CURRENT_LIST_FILE}")
  ]]
)

jrl_test_case(
  NAME "_jrl_check_file_exists: pass for an existing directory (EXISTS is true for dirs)"
  CODE [[
    _jrl_check_file_exists("${CMAKE_CURRENT_LIST_DIR}")
  ]]
)

jrl_test_case(
  NAME "_jrl_check_file_exists: fail with default message for non-existent path"
  CODE [[
    _jrl_check_file_exists("/this/path/does/not/exist.txt")
  ]]
  PROPERTIES
    PASS_REGULAR_EXPRESSION "File does not exist: '/this/path/does/not/exist\\.txt'\\."
)

jrl_test_case(
  NAME "_jrl_check_file_exists: fail with custom message for non-existent path"
  CODE [[
    _jrl_check_file_exists("/nonexistent/file.cmake" "Custom: file.cmake is missing")
  ]]
  PROPERTIES PASS_REGULAR_EXPRESSION "Custom: file\\.cmake is missing"
)

# ---------------------------------------------------------------------------
# _jrl_check_dir_exists
# ---------------------------------------------------------------------------

jrl_test_case(
  NAME "_jrl_check_dir_exists: pass for an existing directory"
  CODE [[
    _jrl_check_dir_exists("${CMAKE_CURRENT_LIST_DIR}")
  ]]
)

jrl_test_case(
  NAME "_jrl_check_dir_exists: fail with default message for non-existent directory"
  CODE [[
    _jrl_check_dir_exists("/this/directory/does/not/exist/at/all")
  ]]
  PROPERTIES
    PASS_REGULAR_EXPRESSION
    "Directory does not exist: '/this/directory/does/not/exist/at/all'\\."
)

jrl_test_case(
  NAME "_jrl_check_dir_exists: fail for a file path (IS_DIRECTORY is false for files)"
  CODE [[
    _jrl_check_dir_exists("${CMAKE_CURRENT_LIST_FILE}")
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "_jrl_check_dir_exists: fail with custom message for non-existent directory"
  CODE [[
    _jrl_check_dir_exists("/nonexistent/path" "Custom: include dir is missing")
  ]]
  PROPERTIES PASS_REGULAR_EXPRESSION "Custom: include dir is missing"
)

# ---------------------------------------------------------------------------
# _jrl_check_target_exists
# ---------------------------------------------------------------------------

jrl_test_case(
  NAME "_jrl_check_target_exists: fail with default message for non-existent target"
  CODE [[
    _jrl_check_target_exists(nonexistent_target_xyz)
  ]]
  PROPERTIES PASS_REGULAR_EXPRESSION "Target 'nonexistent_target_xyz' does not exist\\."
)

jrl_test_case(
  NAME "_jrl_check_target_exists: fail with custom message for non-existent target"
  CODE [[
    _jrl_check_target_exists(nonexistent_target_xyz "Call find_package(MyLib REQUIRED) first.")
  ]]
  PROPERTIES PASS_REGULAR_EXPRESSION "Call find_package\\(MyLib REQUIRED\\) first\\."
)
