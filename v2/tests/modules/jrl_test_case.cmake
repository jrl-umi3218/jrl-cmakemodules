# Copyright 2025-2026 Inria

include_guard(GLOBAL)
cmake_minimum_required(VERSION 3.22)

#[============================================================================[
# `jrl_test_case`

```cmake
jrl_test_case(
    NAME <name>
    CODE <code_block>
    [WILL_FAIL]
    [PROPERTIES <prop> <value> ...]
)
```

**Type:** function


### Description
  Writes a temporary CMake script containing the code block and registers it as a CTest test.


### Arguments
* `NAME`: (OneValue) The name of the test case.
* `CODE`: (OneValue) The block of CMake code to execute. Must be quoted or in brackets `[[...]]`.
* `WILL_FAIL`: (Option) Shortcut for `PROPERTIES WILL_FAIL TRUE`. CTest will treat a non-zero exit as PASS.
* `PROPERTIES`: (MultiValue) Key-value pairs forwarded verbatim to `set_tests_properties(... PROPERTIES ...)`. Use any CTest test property, e.g. `PASS_REGULAR_EXPRESSION "regex"`.


### Example
```cmake
jrl_test_case(
    NAME "My variable check fails"
    WILL_FAIL
    CODE [[
        _jrl_check(DEFINED UNDEFINED_VAR)
    ]]
)
```
#]============================================================================]
function(jrl_test_case)
    set(options WILL_FAIL)
    set(oneValueArgs NAME RESULT_VAR ERROR_VAR CODE)
    set(multiValueArgs PROPERTIES)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")

    if(NOT arg_NAME)
        message(FATAL_ERROR "jrl_test_case requires a NAME argument.")
    endif()

    if(NOT arg_CODE)
        message(FATAL_ERROR "jrl_test_case requires a CODE argument.")
    endif()

    # Determine path to jrl.cmake
    set(jrl_path "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../../modules/jrl.cmake")
    cmake_path(ABSOLUTE_PATH jrl_path NORMALIZE)
    if(NOT EXISTS "${jrl_path}")
        message(FATAL_ERROR "jrl.cmake not found at expected path: ${jrl_path}")
    endif()

    # 1. Write temp script combining include and code
    string(SHA256 code_hash "${arg_CODE}")
    set(tmp_script "${CMAKE_CURRENT_BINARY_DIR}/tmp_jrl_test_case_${code_hash}.cmake")
    file(WRITE "${tmp_script}" "include(\"${jrl_path}\")\n${arg_CODE}")

    # 2. Register as a CTest test
    add_test(NAME "${arg_NAME}" COMMAND "${CMAKE_COMMAND}" -P "${tmp_script}")

    # 3. Forward PROPERTIES to set_tests_properties
    if(arg_WILL_FAIL)
        set_tests_properties("${arg_NAME}" PROPERTIES WILL_FAIL TRUE)
    endif()
    if(arg_PROPERTIES)
        set_tests_properties("${arg_NAME}" PROPERTIES ${arg_PROPERTIES})
    endif()
endfunction()
