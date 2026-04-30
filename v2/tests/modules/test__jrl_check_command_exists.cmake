jrl_test_case(
  NAME "Pass for built-in command 'message'"
  CODE [[
    _jrl_check_command_exists(message)
  ]]
)

jrl_test_case(
  NAME "Pass for built-in command 'set'"
  CODE [[
    _jrl_check_command_exists(set)
  ]]
)

jrl_test_case(
  NAME "Pass for a function defined by jrl.cmake"
  CODE [[
    _jrl_check_command_exists(_jrl_check_var_defined)
  ]]
)

jrl_test_case(
  NAME "Pass for a user-defined function"
  CODE [[
    function(my_custom_test_function)
    endfunction()

    _jrl_check_command_exists(my_custom_test_function)
  ]]
)

jrl_test_case(
  NAME "Fatal error with default message for non-existent command"
  CODE [[
    _jrl_check_command_exists(this_command_does_not_exist_xyz)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error with custom message for non-existent command"
  CODE [[
    _jrl_check_command_exists(nonexistent_command "Custom: call find_package(MyLib) first")
  ]]
  WILL_FAIL
)
