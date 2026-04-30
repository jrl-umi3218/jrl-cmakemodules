jrl_test_case(
  NAME "Basic option without CONDITION"
  CODE
    [[
    unset(TEST_OPTION_1 CACHE)

    jrl_option(TEST_OPTION_1 "Test option 1" ON)

    _jrl_check_var_defined(TEST_OPTION_1)
    _jrl_check_strequal("${TEST_OPTION_1}" "ON")
  ]]
)

jrl_test_case(
  NAME "Option with CONDITION=TRUE"
  CODE
    [[
    unset(TEST_OPTION_2 CACHE)
    set(MY_DEP_ENABLED TRUE)

    jrl_option(TEST_OPTION_2 "Test option 2" ON CONDITION "MY_DEP_ENABLED" FALLBACK OFF)

    _jrl_check_var_defined(TEST_OPTION_2)
    _jrl_check_strequal("${TEST_OPTION_2}" "ON")
  ]]
)

jrl_test_case(
  NAME "Option with CONDITION=FALSE (FALLBACK=OFF)"
  CODE
    [[
    unset(TEST_OPTION_3 CACHE)
    set(MY_DEP_DISABLED FALSE)

    jrl_option(TEST_OPTION_3 "Test option 3" ON CONDITION "MY_DEP_DISABLED" FALLBACK OFF)

    _jrl_check_var_defined(TEST_OPTION_3)
    _jrl_check_strequal("${TEST_OPTION_3}" "OFF")
  ]]
)

jrl_test_case(
  NAME "Option with CONDITION=FALSE and custom FALLBACK=ON"
  CODE
    [[
    unset(TEST_OPTION_4 CACHE)
    set(ANOTHER_DEP FALSE)

    jrl_option(TEST_OPTION_4 "Test option 4" ON CONDITION "ANOTHER_DEP" FALLBACK ON)

    _jrl_check_var_defined(TEST_OPTION_4)
    _jrl_check_strequal("${TEST_OPTION_4}" "ON")
  ]]
)

jrl_test_case(
  NAME "Option with single LEGACY_NAME"
  CODE
    [[
    unset(TEST_OPTION_5 CACHE)
    unset(OLD_OPTION_NAME CACHE)
    set(OLD_OPTION_NAME ON CACHE BOOL "Old option name")

    jrl_option(TEST_OPTION_5 "Test option 5" OFF LEGACY_NAME OLD_OPTION_NAME)

    _jrl_check_var_defined(TEST_OPTION_5)
    _jrl_check_strequal("${TEST_OPTION_5}" "ON")
  ]]
)

jrl_test_case(
  NAME "jrl_legacy_option standalone usage"
  CODE
    [[
    unset(TEST_OPTION_6 CACHE)
    unset(OLD_OPTION_6 CACHE)
    jrl_option(TEST_OPTION_6 "Test option 6" OFF)
    set(OLD_OPTION_6 ON CACHE BOOL "Old option 6")

    jrl_legacy_option(NEW_OPTION TEST_OPTION_6 OLD_OPTION OLD_OPTION_6)

    _jrl_check_var_defined(TEST_OPTION_6)
    _jrl_check_strequal("${TEST_OPTION_6}" "ON")
  ]]
)

jrl_test_case(
  NAME "Combination of CONDITION, FALLBACK, and LEGACY_NAME"
  CODE
    [[
    unset(TEST_OPTION_7 CACHE)
    unset(OLD_OPTION_7 CACHE)
    set(COMBO_DEP FALSE)
    set(OLD_OPTION_7 ON CACHE BOOL "Old option 7")

    jrl_option(TEST_OPTION_7 "Test option 7" ON CONDITION "COMBO_DEP" FALLBACK OFF LEGACY_NAME OLD_OPTION_7)

    _jrl_check_var_defined(TEST_OPTION_7)
    _jrl_check_strequal("${TEST_OPTION_7}" "ON")
  ]]
)

jrl_test_case(
  NAME "Option already set in cache"
  CODE
    [[
    unset(TEST_OPTION_8 CACHE)
    set(TEST_OPTION_8 OFF CACHE BOOL "Pre-set option")

    jrl_option(TEST_OPTION_8 "Test option 8" ON)

    _jrl_check_var_defined(TEST_OPTION_8)
    _jrl_check_strequal("${TEST_OPTION_8}" "OFF")
  ]]
)

jrl_test_case(
  NAME "Complex CONDITION expression"
  CODE
    [[
    unset(TEST_OPTION_9 CACHE)
    set(DEP_A TRUE)
    set(DEP_B FALSE)

    jrl_option(TEST_OPTION_9 "Test option 9" ON CONDITION "DEP_A AND NOT DEP_B" FALLBACK OFF)

    _jrl_check_var_defined(TEST_OPTION_9)
    _jrl_check_strequal("${TEST_OPTION_9}" "ON")
  ]]
)

jrl_test_case(
  NAME "Complex CONDITION expression (FALSE)"
  CODE
    [[
    unset(TEST_OPTION_10 CACHE)
    set(DEP_C TRUE)
    set(DEP_D TRUE)

    jrl_option(TEST_OPTION_10 "Test option 10" ON CONDITION "DEP_C AND NOT DEP_D" FALLBACK OFF)

    _jrl_check_var_defined(TEST_OPTION_10)
    _jrl_check_strequal("${TEST_OPTION_10}" "OFF")
  ]]
)

jrl_test_case(
  NAME "Option without LEGACY_NAME"
  CODE
    [[
    unset(TEST_OPTION_11 CACHE)

    jrl_option(TEST_OPTION_11 "Test option 11" ON)

    _jrl_check_var_defined(TEST_OPTION_11)
    _jrl_check_strequal("${TEST_OPTION_11}" "ON")
  ]]
)

jrl_test_case(
  NAME "FALLBACK with custom value"
  CODE
    [[
    unset(TEST_OPTION_12 CACHE)
    set(CUSTOM_DEP FALSE)

    jrl_option(TEST_OPTION_12 "Test option 12" ON CONDITION "CUSTOM_DEP" FALLBACK "CUSTOM_VALUE")

    _jrl_check_var_defined(TEST_OPTION_12)
    _jrl_check_strequal("${TEST_OPTION_12}" "CUSTOM_VALUE")
  ]]
)

jrl_test_case(
  NAME "jrl_legacy_option with undefined old option"
  CODE
    [[
    unset(TEST_OPTION_13 CACHE)
    unset(OLD_OPTION_13 CACHE)
    jrl_option(TEST_OPTION_13 "Test option 13" OFF)

    jrl_legacy_option(NEW_OPTION TEST_OPTION_13 OLD_OPTION OLD_OPTION_13)

    _jrl_check_var_defined(TEST_OPTION_13)
    _jrl_check_strequal("${TEST_OPTION_13}" "OFF")
  ]]
)

jrl_test_case(
  NAME "jrl_legacy_option retrieves help text from cache"
  CODE
    [[
    unset(TEST_OPTION_14 CACHE)
    unset(OLD_OPTION_14 CACHE)
    jrl_option(TEST_OPTION_14 "Custom help text for option 14" ON)
    set(OLD_OPTION_14 OFF CACHE BOOL "Old help text")

    jrl_legacy_option(NEW_OPTION TEST_OPTION_14 OLD_OPTION OLD_OPTION_14)

    _jrl_check_var_defined(TEST_OPTION_14)
    _jrl_check_strequal("${TEST_OPTION_14}" "OFF")
    get_property(help_text CACHE TEST_OPTION_14 PROPERTY HELPSTRING)
    if(NOT "${help_text}" STREQUAL "Custom help text for option 14")
      message(FATAL_ERROR "FAIL: Help text was not preserved: '${help_text}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "Multiple legacy options via separate calls"
  CODE
    [[
    unset(TEST_OPTION_15 CACHE)
    unset(OLD_OPTION_15A CACHE)
    unset(OLD_OPTION_15B CACHE)
    jrl_option(TEST_OPTION_15 "Test option 15" OFF)
    set(OLD_OPTION_15A ON CACHE BOOL "First old option")
    set(OLD_OPTION_15B OFF CACHE BOOL "Second old option")

    jrl_legacy_option(NEW_OPTION TEST_OPTION_15 OLD_OPTION OLD_OPTION_15A)
    _jrl_check_var_defined(TEST_OPTION_15)
    _jrl_check_strequal("${TEST_OPTION_15}" "ON")

    jrl_legacy_option(NEW_OPTION TEST_OPTION_15 OLD_OPTION OLD_OPTION_15B)
    _jrl_check_var_defined(TEST_OPTION_15)
    _jrl_check_strequal("${TEST_OPTION_15}" "OFF")
  ]]
)

jrl_test_case(
  NAME "LEGACY_NAME when legacy option not defined"
  CODE
    [[
    unset(TEST_OPTION_16 CACHE)
    unset(OLD_OPTION_16 CACHE)

    jrl_option(TEST_OPTION_16 "Test option 16" ON LEGACY_NAME OLD_OPTION_16)

    _jrl_check_var_defined(TEST_OPTION_16)
    _jrl_check_strequal("${TEST_OPTION_16}" "ON")
  ]]
)

jrl_test_case(
  NAME "Fatal error when NEW_OPTION is undefined in cache"
  CODE
    [[
    set(PROJECT_NAME test_project)
    set(OLD_OPT ON CACHE BOOL "old")

    jrl_legacy_option(NEW_OPTION NON_EXISTENT OLD_OPTION OLD_OPT)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error when CONDITION set but FALLBACK missing"
  CODE
    [[
    set(PROJECT_NAME test_project)

    jrl_option(BAD_OPT "desc" ON CONDITION "TRUE")
  ]]
  WILL_FAIL
)
