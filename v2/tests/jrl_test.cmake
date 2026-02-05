cmake_minimum_required(VERSION 3.22)

#[============================================================================[
# `jrl_try_catch`

```cpp
jrl_try_catch(
    CODE <code_block>
    [RESULT_VAR <result_variable>]
    [ERROR_VAR <error_variable>]
)
```

**Type:** function


### Description
  Executes a block of CMake code in a subprocess to catch fatal errors.


### Arguments
* `CODE`: (OneValue) The block of CMake code to execute. Must be quoted or in brackets `[[...]]`.
* `RESULT_VAR`: (OneValue) Variable to store exit code (0 = success).
* `ERROR_VAR`: (OneValue) Variable to store stderr output.


### Example
```cmake
jrl_try_catch(
    CODE [[
        message(FATAL_ERROR "This creates an error")
    ]]
    RESULT_VAR res
    ERROR_VAR err
)
```
#]============================================================================]
function(jrl_try_catch)
    set(options "")
    set(oneValueArgs RESULT_VAR ERROR_VAR CODE)
    set(multiValueArgs "")
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT arg_CODE)
        message(FATAL_ERROR "jrl_try_catch requires a CODE argument.")
    endif()

    # 1. Write to temp file
    string(MD5 code_hash "${arg_CODE}")
    set(tmp_script "tmp_jrl_try_${code_hash}.cmake")
    file(CONFIGURE OUTPUT "${tmp_script}" CONTENT "${arg_CODE}" ESCAPE_QUOTES @ONLY)

    # 2. Execute
    execute_process(
        COMMAND ${CMAKE_COMMAND} -P "${tmp_script}"
        RESULT_VARIABLE proc_result
        ERROR_VARIABLE proc_error
        OUTPUT_VARIABLE proc_output
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_STRIP_TRAILING_WHITESPACE
    )

    # 3. Propagate results
    if(arg_RESULT_VAR)
        set(${arg_RESULT_VAR} "${proc_result}" PARENT_SCOPE)
    endif()

    if(arg_ERROR_VAR)
        set(${arg_ERROR_VAR} "${proc_error}" PARENT_SCOPE)
    endif()

    # Cleanup
    file(REMOVE "${tmp_script}")
endfunction()

#[============================================================================[
# `jrl_expect_error`

```cpp
jrl_expect_error(
    CODE <code_block>
    [MATCH <regex>]
)
```

**Type:** function


### Description
  Asserts that a block of code fails.


### Arguments
* `CODE`: (OneValue) The block of CMake code to execute. Must be quoted or in brackets `[[...]]`.
* `MATCH`: (Optional) Regex to match against the error message. If not provided, any error is accepted.


### Example
```cmake
# Expect any error
jrl_expect_error(
    CODE [[
        message(FATAL_ERROR "Some error")
    ]]
)

# Expect specific error
jrl_expect_error(
    CODE [[
        message(FATAL_ERROR "Specific error")
    ]]
    MATCH "Specific error"
)
```
#]============================================================================]
function(jrl_expect_error)
    set(options "")
    # CODE is now in oneValueArgs here too for consistency
    set(oneValueArgs MATCH CODE)
    set(multiValueArgs "")
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT DEFINED arg_CODE)
        message(FATAL_ERROR "jrl_expect_error requires a CODE argument.")
    endif()

    # Call the renamed function
    jrl_try_catch(
        CODE "${arg_CODE}"
        RESULT_VAR res
        ERROR_VAR  err_out
    )

    if(res EQUAL 0)
        message(FATAL_ERROR "jrl_expect_error failed: Code succeeded but was expected to fail.")
    else()
        if(DEFINED arg_MATCH)
            string(REGEX MATCH "${arg_MATCH}" match_found "${err_out}")
            if(NOT match_found)
                message(
                    FATAL_ERROR
                    "jrl_expect_error failed: Error message mismatch.\n"
                    "  Expected Regex : ${arg_MATCH}\n"
                    "  Actual Output  : ${err_out}"
                )
            else()
                message(
                    STATUS
                    "[PASS] jrl_expect_error: Caught expected error matching '${arg_MATCH}'"
                )
            endif()
        else()
            message(STATUS "[PASS] jrl_expect_error: Caught expected error.")
        endif()
    endif()
endfunction()
