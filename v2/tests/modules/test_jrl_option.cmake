set(jrl_script_path ${CMAKE_CURRENT_LIST_DIR}/../../modules/jrl.cmake)
include(${jrl_script_path})
include(${CMAKE_CURRENT_LIST_DIR}/jrl_test.cmake)

# Helper function to assert that a variable is defined and has expected value
function(assert_defined var_name expected_value)
    if(NOT DEFINED ${var_name})
        message(FATAL_ERROR "FAIL: ${var_name} is not defined (expected: ${expected_value})")
    endif()

    if(NOT "${${var_name}}" STREQUAL "${expected_value}")
        message(FATAL_ERROR "FAIL: ${var_name}=${${var_name}} (expected: ${expected_value})")
    endif()

    message(STATUS "PASS: ${var_name}=${${var_name}}")
endfunction()

# Helper function to assert that a variable is not defined
function(assert_not_defined var_name)
    if(DEFINED ${var_name})
        message(FATAL_ERROR "FAIL: ${var_name} is defined but should not be")
    endif()

    message(STATUS "PASS: ${var_name} is not defined")
endfunction()

#[============================================================================[
# Test 1: Basic option creation without CONDITION
#]============================================================================]
message(STATUS "\n=== Test 1: Basic option without CONDITION ===")
unset(TEST_OPTION_1 CACHE)
jrl_option(TEST_OPTION_1 "Test option 1" ON)
assert_defined(TEST_OPTION_1 ON)

#[============================================================================[
# Test 2: Option with CONDITION=TRUE
#]============================================================================]
message(STATUS "\n=== Test 2: Option with CONDITION=TRUE ===")
unset(TEST_OPTION_2 CACHE)
set(MY_DEP_ENABLED TRUE)
jrl_option(TEST_OPTION_2 "Test option 2" ON CONDITION "MY_DEP_ENABLED" FALLBACK OFF)
assert_defined(TEST_OPTION_2 ON)

#[============================================================================[
# Test 3: Option with CONDITION=FALSE (FALLBACK=OFF)
#]============================================================================]
message(STATUS "\n=== Test 3: Option with CONDITION=FALSE (FALLBACK=OFF) ===")
unset(TEST_OPTION_3 CACHE)
set(MY_DEP_DISABLED FALSE)
jrl_option(TEST_OPTION_3 "Test option 3" ON CONDITION "MY_DEP_DISABLED" FALLBACK OFF)
assert_defined(TEST_OPTION_3 OFF)

#[============================================================================[
# Test 4: Option with CONDITION=FALSE and custom FALLBACK
#]============================================================================]
message(STATUS "\n=== Test 4: Option with CONDITION=FALSE and custom FALLBACK=ON ===")
unset(TEST_OPTION_4 CACHE)
set(ANOTHER_DEP FALSE)
jrl_option(TEST_OPTION_4 "Test option 4" ON CONDITION "ANOTHER_DEP" FALLBACK ON)
assert_defined(TEST_OPTION_4 ON)

#[============================================================================[
# Test 5: Option with single LEGACY_NAME
#]============================================================================]
message(STATUS "\n=== Test 5: Option with single LEGACY_NAME ===")
unset(TEST_OPTION_5 CACHE)
unset(OLD_OPTION_NAME CACHE)
set(OLD_OPTION_NAME ON CACHE BOOL "Old option name")
jrl_option(TEST_OPTION_5 "Test option 5" OFF LEGACY_NAME OLD_OPTION_NAME)
assert_defined(TEST_OPTION_5 ON)

#[============================================================================[
# Test 6: jrl_legacy_option standalone usage
#]============================================================================]
message(STATUS "\n=== Test 6: jrl_legacy_option standalone ===")
unset(TEST_OPTION_6 CACHE)
unset(OLD_OPTION_6 CACHE)
# First create the new option
jrl_option(TEST_OPTION_6 "Test option 6" OFF)
# Set the old option
set(OLD_OPTION_6 ON CACHE BOOL "Old option 6")
# Call jrl_legacy_option to migrate
jrl_legacy_option(
    NEW_OPTION TEST_OPTION_6
    OLD_OPTION OLD_OPTION_6
)
# Should migrate to the old value
assert_defined(TEST_OPTION_6 ON)

#[============================================================================[
# Test 7: Option with CONDITION and FALLBACK and LEGACY_NAME
#]============================================================================]
message(STATUS "\n=== Test 7: Combination of CONDITION, FALLBACK, and LEGACY_NAME ===")
unset(TEST_OPTION_7 CACHE)
unset(OLD_OPTION_7 CACHE)
set(COMBO_DEP FALSE)
set(OLD_OPTION_7 ON CACHE BOOL "Old option 7")
jrl_option(
    TEST_OPTION_7
    "Test option 7"
    ON
    CONDITION "COMBO_DEP"
    FALLBACK OFF
    LEGACY_NAME OLD_OPTION_7
)
# Legacy option should override even when condition fails
assert_defined(TEST_OPTION_7 ON)

#[============================================================================[
# Test 8: Option already set in cache (should respect existing value)
#]============================================================================]
message(STATUS "\n=== Test 8: Option already set in cache ===")
unset(TEST_OPTION_8 CACHE)
set(TEST_OPTION_8 OFF CACHE BOOL "Pre-set option")
jrl_option(TEST_OPTION_8 "Test option 8" ON)
# When using option() built-in, existing cache values are preserved
assert_defined(TEST_OPTION_8 OFF)

#[============================================================================[
# Test 9: Complex CONDITION expression
#]============================================================================]
message(STATUS "\n=== Test 9: Complex CONDITION expression ===")
unset(TEST_OPTION_9 CACHE)
set(DEP_A TRUE)
set(DEP_B FALSE)
jrl_option(TEST_OPTION_9 "Test option 9" ON CONDITION "DEP_A AND NOT DEP_B" FALLBACK OFF)
assert_defined(TEST_OPTION_9 ON)

#[============================================================================[
# Test 10: Complex CONDITION expression with FALSE result
#]============================================================================]
message(STATUS "\n=== Test 10: Complex CONDITION expression (FALSE) ===")
unset(TEST_OPTION_10 CACHE)
set(DEP_C TRUE)
set(DEP_D TRUE)
jrl_option(TEST_OPTION_10 "Test option 10" ON CONDITION "DEP_C AND NOT DEP_D" FALLBACK OFF)
assert_defined(TEST_OPTION_10 OFF)

#[============================================================================[
# Test 11: Option without LEGACY_NAME (should work normally)
#]============================================================================]
message(STATUS "\n=== Test 11: Option without LEGACY_NAME ===")
unset(TEST_OPTION_11 CACHE)
jrl_option(TEST_OPTION_11 "Test option 11" ON)
assert_defined(TEST_OPTION_11 ON)

#[============================================================================[
# Test 12: FALLBACK with non-standard value
#]============================================================================]
message(STATUS "\n=== Test 12: FALLBACK with custom value ===")
unset(TEST_OPTION_12 CACHE)
set(CUSTOM_DEP FALSE)
jrl_option(TEST_OPTION_12 "Test option 12" ON CONDITION "CUSTOM_DEP" FALLBACK "CUSTOM_VALUE")
assert_defined(TEST_OPTION_12 "CUSTOM_VALUE")

#[============================================================================[
# Test 13: jrl_legacy_option when old option is not defined (should do nothing)
#]============================================================================]
message(STATUS "\n=== Test 13: jrl_legacy_option with undefined old option ===")
unset(TEST_OPTION_13 CACHE)
unset(OLD_OPTION_13 CACHE)
jrl_option(TEST_OPTION_13 "Test option 13" OFF)
jrl_legacy_option(
    NEW_OPTION TEST_OPTION_13
    OLD_OPTION OLD_OPTION_13
)
# Should keep the default value
assert_defined(TEST_OPTION_13 OFF)

#[============================================================================[
# Test 14: jrl_legacy_option retrieves help text from cache
#]============================================================================]
message(STATUS "\n=== Test 14: jrl_legacy_option retrieves help text from cache ===")
unset(TEST_OPTION_14 CACHE)
unset(OLD_OPTION_14 CACHE)
jrl_option(TEST_OPTION_14 "Custom help text for option 14" ON)
set(OLD_OPTION_14 OFF CACHE BOOL "Old help text")
jrl_legacy_option(
    NEW_OPTION TEST_OPTION_14
    OLD_OPTION OLD_OPTION_14
)
# Should migrate value
assert_defined(TEST_OPTION_14 OFF)
# Verify help text was preserved from NEW_OPTION
get_property(help_text CACHE TEST_OPTION_14 PROPERTY HELPSTRING)
if(NOT "${help_text}" STREQUAL "Custom help text for option 14")
    message(FATAL_ERROR "FAIL: Help text was not preserved: '${help_text}'")
endif()
message(STATUS "PASS: Help text preserved: '${help_text}'")

#[============================================================================[
# Test 15: Multiple legacy options migration
#]============================================================================]
message(STATUS "\n=== Test 15: Multiple legacy options via separate calls ===")
unset(TEST_OPTION_15 CACHE)
unset(OLD_OPTION_15A CACHE)
unset(OLD_OPTION_15B CACHE)
jrl_option(TEST_OPTION_15 "Test option 15" OFF)
set(OLD_OPTION_15A ON CACHE BOOL "First old option")
set(OLD_OPTION_15B OFF CACHE BOOL "Second old option")
# Migrate from first old option
jrl_legacy_option(
    NEW_OPTION TEST_OPTION_15
    OLD_OPTION OLD_OPTION_15A
)
assert_defined(TEST_OPTION_15 ON)
# Trying to migrate from second old option (should override)
jrl_legacy_option(
    NEW_OPTION TEST_OPTION_15
    OLD_OPTION OLD_OPTION_15B
)
assert_defined(TEST_OPTION_15 OFF)

#[============================================================================[
# Test 16: LEGACY_NAME in jrl_option when legacy option not defined
#]============================================================================]
message(STATUS "\n=== Test 16: LEGACY_NAME when legacy option not defined ===")
unset(TEST_OPTION_16 CACHE)
unset(OLD_OPTION_16 CACHE)
jrl_option(TEST_OPTION_16 "Test option 16" ON LEGACY_NAME OLD_OPTION_16)
# Should use default value since OLD_OPTION_16 is not defined
assert_defined(TEST_OPTION_16 ON)

#[============================================================================[
# Test 17: Fatal error when NEW_OPTION is undefined in cache
#]============================================================================]
message(STATUS "\n=== Test 17: Fatal error when NEW_OPTION is undefined in cache ===")
jrl_expect_error(
    CODE "
        include(\"${jrl_script_path}\")
        set(PROJECT_NAME test_project)
        set(OLD_OPT ON CACHE BOOL \"old\")
        jrl_legacy_option(NEW_OPTION NON_EXISTENT OLD_OPTION OLD_OPT)
    "
    MATCH "jrl_legacy_option: NEW_OPTION 'NON_EXISTENT' does not exist in cache"
)

#[============================================================================[
# Test 18: Fatal error when CONDITION is set but FALLBACK is missing
#]============================================================================]
message(STATUS "\n=== Test 18: Fatal error when CONDITION is set but FALLBACK is missing ===")
jrl_expect_error(
    CODE "
        include(\"${jrl_script_path}\")
        set(PROJECT_NAME test_project)
        jrl_option(BAD_OPT \"desc\" ON CONDITION \"TRUE\")
    "
    MATCH "FALLBACK argument must be provided when CONDITION is used"
)

message(STATUS "\n=== All tests passed! ===\n")
