jrl_test_case(
  NAME "Basic option without CONDITION"
  CODE
    [[
    unset(TEST_OPTION_1 CACHE)

    jrl_option(TEST_OPTION_1 "Test option 1" ON)

    _jrl_check(DEFINED TEST_OPTION_1)
    _jrl_check("${TEST_OPTION_1}" STREQUAL "ON")
  ]]
)

jrl_test_case(
  NAME "Option with CONDITION=TRUE"
  CODE
    [[
    unset(TEST_OPTION_2 CACHE)
    set(MY_DEP_ENABLED TRUE)

    jrl_option(TEST_OPTION_2 "Test option 2" ON CONDITION "MY_DEP_ENABLED" FALLBACK OFF)

    _jrl_check(DEFINED TEST_OPTION_2)
    _jrl_check("${TEST_OPTION_2}" STREQUAL "ON")
  ]]
)

jrl_test_case(
  NAME "Option with CONDITION=FALSE (FALLBACK=OFF)"
  CODE
    [[
    unset(TEST_OPTION_3 CACHE)
    set(MY_DEP_DISABLED FALSE)

    jrl_option(TEST_OPTION_3 "Test option 3" ON CONDITION "MY_DEP_DISABLED" FALLBACK OFF)

    _jrl_check(DEFINED TEST_OPTION_3)
    _jrl_check("${TEST_OPTION_3}" STREQUAL "OFF")
  ]]
)

jrl_test_case(
  NAME "Option with CONDITION=FALSE and custom FALLBACK=ON"
  CODE
    [[
    unset(TEST_OPTION_4 CACHE)
    set(ANOTHER_DEP FALSE)

    jrl_option(TEST_OPTION_4 "Test option 4" ON CONDITION "ANOTHER_DEP" FALLBACK ON)

    _jrl_check(DEFINED TEST_OPTION_4)
    _jrl_check("${TEST_OPTION_4}" STREQUAL "ON")
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

    _jrl_check(DEFINED TEST_OPTION_5)
    _jrl_check("${TEST_OPTION_5}" STREQUAL "ON")
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

    _jrl_check(DEFINED TEST_OPTION_6)
    _jrl_check("${TEST_OPTION_6}" STREQUAL "ON")
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

    # The legacy name is an alias, not a way around CONDITION: asking for ON through it
    # must be overridden, exactly as -DTEST_OPTION_7=ON would be.
    _jrl_check(DEFINED TEST_OPTION_7)
    _jrl_check("${TEST_OPTION_7}" STREQUAL "OFF")
  ]]
)

jrl_test_case(
  NAME "A legacy value is honoured once the CONDITION holds"
  CODE
    [[
    unset(TEST_OPTION_7B CACHE)
    unset(OLD_OPTION_7B CACHE)
    set(COMBO_DEP ON)
    set(OLD_OPTION_7B OFF CACHE BOOL "Old option 7b")

    jrl_option(TEST_OPTION_7B "Test option 7b" ON CONDITION "COMBO_DEP" FALLBACK OFF LEGACY_NAME OLD_OPTION_7B)

    # The condition is true, so the migrated value wins over the ON default.
    _jrl_check(DEFINED TEST_OPTION_7B)
    _jrl_check("${TEST_OPTION_7B}" STREQUAL "OFF")
  ]]
)

jrl_test_case(
  NAME "A migrated legacy option stops overriding the new name"
  CODE
    [[
    unset(TEST_OPTION_7C CACHE)
    unset(OLD_OPTION_7C CACHE)
    set(OLD_OPTION_7C ON CACHE BOOL "Old option 7c")

    jrl_option(TEST_OPTION_7C "Test option 7c" OFF LEGACY_NAME OLD_OPTION_7C)
    _jrl_check("${TEST_OPTION_7C}" STREQUAL "ON")

    # The legacy entry is consumed by the migration, so it cannot come back and re-force
    # the option on the next configure.
    _jrl_check(NOT DEFINED CACHE{OLD_OPTION_7C})
  ]]
)

jrl_test_case(
  NAME "Option already set in cache"
  CODE
    [[
    unset(TEST_OPTION_8 CACHE)
    set(TEST_OPTION_8 OFF CACHE BOOL "Pre-set option")

    jrl_option(TEST_OPTION_8 "Test option 8" ON)

    _jrl_check(DEFINED TEST_OPTION_8)
    _jrl_check("${TEST_OPTION_8}" STREQUAL "OFF")
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

    _jrl_check(DEFINED TEST_OPTION_9)
    _jrl_check("${TEST_OPTION_9}" STREQUAL "ON")
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

    _jrl_check(DEFINED TEST_OPTION_10)
    _jrl_check("${TEST_OPTION_10}" STREQUAL "OFF")
  ]]
)

jrl_test_case(
  NAME "Semicolon-separated CONDITION list (all conditions hold)"
  CODE
    [[
    unset(TEST_OPTION_9B CACHE)
    set(USE_BAR TRUE)
    set(USE_ZOT FALSE)

    # Same spelling as cmake_dependent_option(): every element of the list must hold.
    jrl_option(TEST_OPTION_9B "Test option 9b" ON CONDITION "USE_BAR;NOT USE_ZOT" FALLBACK OFF)

    _jrl_check(DEFINED TEST_OPTION_9B)
    _jrl_check("${TEST_OPTION_9B}" STREQUAL "ON")
  ]]
)

jrl_test_case(
  NAME "Semicolon-separated CONDITION list (one condition fails)"
  CODE
    [[
    unset(TEST_OPTION_9C CACHE)
    set(USE_BAR TRUE)
    set(USE_ZOT TRUE)

    jrl_option(TEST_OPTION_9C "Test option 9c" ON CONDITION "USE_BAR;NOT USE_ZOT" FALLBACK OFF)

    _jrl_check(DEFINED TEST_OPTION_9C)
    _jrl_check("${TEST_OPTION_9C}" STREQUAL "OFF")
  ]]
)

jrl_test_case(
  NAME "Option without LEGACY_NAME"
  CODE
    [[
    unset(TEST_OPTION_11 CACHE)

    jrl_option(TEST_OPTION_11 "Test option 11" ON)

    _jrl_check(DEFINED TEST_OPTION_11)
    _jrl_check("${TEST_OPTION_11}" STREQUAL "ON")
  ]]
)

jrl_test_case(
  NAME "FALLBACK with custom value"
  CODE
    [[
    unset(TEST_OPTION_12 CACHE)
    set(CUSTOM_DEP FALSE)

    jrl_option(TEST_OPTION_12 "Test option 12" ON CONDITION "CUSTOM_DEP" FALLBACK "CUSTOM_VALUE")

    _jrl_check(DEFINED TEST_OPTION_12)
    _jrl_check("${TEST_OPTION_12}" STREQUAL "CUSTOM_VALUE")
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

    _jrl_check(DEFINED TEST_OPTION_13)
    _jrl_check("${TEST_OPTION_13}" STREQUAL "OFF")
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

    _jrl_check(DEFINED TEST_OPTION_14)
    _jrl_check("${TEST_OPTION_14}" STREQUAL "OFF")
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
    _jrl_check(DEFINED TEST_OPTION_15)
    _jrl_check("${TEST_OPTION_15}" STREQUAL "ON")

    jrl_legacy_option(NEW_OPTION TEST_OPTION_15 OLD_OPTION OLD_OPTION_15B)
    _jrl_check(DEFINED TEST_OPTION_15)
    _jrl_check("${TEST_OPTION_15}" STREQUAL "OFF")
  ]]
)

jrl_test_case(
  NAME "LEGACY_NAME when legacy option not defined"
  CODE
    [[
    unset(TEST_OPTION_16 CACHE)
    unset(OLD_OPTION_16 CACHE)

    jrl_option(TEST_OPTION_16 "Test option 16" ON LEGACY_NAME OLD_OPTION_16)

    _jrl_check(DEFINED TEST_OPTION_16)
    _jrl_check("${TEST_OPTION_16}" STREQUAL "ON")
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

# The test cases below emulate re-configuring a build tree: the cache survives between the
# two jrl_option() calls, like it does between two `cmake -S . -B build`.

jrl_test_case(
  NAME "Option is restored to its default when CONDITION becomes true"
  CODE
    [[
    unset(TEST_OPTION_17 CACHE)
    set(DEP_17 OFF)

    # First configure: the condition is false, the option is forced to the fallback and hidden.
    jrl_option(TEST_OPTION_17 "Test option 17" ON CONDITION "DEP_17" FALLBACK OFF)
    _jrl_check("${TEST_OPTION_17}" STREQUAL "OFF")
    get_property(advanced CACHE TEST_OPTION_17 PROPERTY ADVANCED)
    _jrl_check("${advanced}" ERROR_MESSAGE "Disabled option should be hidden (advanced)")

    # Second configure: the condition is true, so the option goes back to its default value
    # and becomes visible again in cmake-gui/ccmake.
    set(DEP_17 ON)
    jrl_option(TEST_OPTION_17 "Test option 17" ON CONDITION "DEP_17" FALLBACK OFF)
    _jrl_check("${TEST_OPTION_17}" STREQUAL "ON")
    get_property(advanced CACHE TEST_OPTION_17 PROPERTY ADVANCED)
    _jrl_check(NOT "${advanced}" ERROR_MESSAGE "Re-enabled option should not be advanced")
    get_property(type CACHE TEST_OPTION_17 PROPERTY TYPE)
    _jrl_check("${type}" STREQUAL "BOOL")
  ]]
)

jrl_test_case(
  NAME "Option stays hidden while CONDITION remains false"
  CODE
    [[
    unset(TEST_OPTION_18 CACHE)
    set(DEP_18 OFF)

    jrl_option(TEST_OPTION_18 "Test option 18" ON CONDITION "DEP_18" FALLBACK OFF)
    jrl_option(TEST_OPTION_18 "Test option 18" ON CONDITION "DEP_18" FALLBACK OFF)

    _jrl_check("${TEST_OPTION_18}" STREQUAL "OFF")
    get_property(advanced CACHE TEST_OPTION_18 PROPERTY ADVANCED)
    _jrl_check("${advanced}" ERROR_MESSAGE "Disabled option should stay hidden (advanced)")
  ]]
)

jrl_test_case(
  NAME "User value set while enabled survives a CONDITION round trip"
  CODE
    [[
    unset(TEST_OPTION_19 CACHE)
    set(DEP_19 ON)

    # The user explicitly disables an option whose default is ON.
    jrl_option(TEST_OPTION_19 "Test option 19" ON CONDITION "DEP_19" FALLBACK OFF)
    set(TEST_OPTION_19 OFF CACHE BOOL "Test option 19" FORCE)

    # Disabling then re-enabling the condition must not silently turn it back ON.
    set(DEP_19 OFF)
    jrl_option(TEST_OPTION_19 "Test option 19" ON CONDITION "DEP_19" FALLBACK OFF)
    _jrl_check("${TEST_OPTION_19}" STREQUAL "OFF")

    set(DEP_19 ON)
    jrl_option(TEST_OPTION_19 "Test option 19" ON CONDITION "DEP_19" FALLBACK OFF)
    _jrl_check("${TEST_OPTION_19}" STREQUAL "OFF" ERROR_MESSAGE "User value must be restored, not the default")
  ]]
)

jrl_test_case(
  NAME "Value requested while CONDITION is false is applied once it becomes true"
  CODE
    [[
    unset(TEST_OPTION_20 CACHE)
    set(DEP_20 OFF)

    # cmake -DTEST_OPTION_20=ON while the condition is false: the option is still forced
    # to the fallback, but the request is remembered.
    set(TEST_OPTION_20 ON CACHE BOOL "Test option 20")
    jrl_option(TEST_OPTION_20 "Test option 20" OFF CONDITION "DEP_20" FALLBACK OFF)
    _jrl_check("${TEST_OPTION_20}" STREQUAL "OFF")

    set(DEP_20 ON)
    jrl_option(TEST_OPTION_20 "Test option 20" OFF CONDITION "DEP_20" FALLBACK OFF)
    _jrl_check("${TEST_OPTION_20}" STREQUAL "ON" ERROR_MESSAGE "Requested value should be applied")
  ]]
)

jrl_test_case(
  NAME "Option hidden by an older jrl_option is recovered without wiping the cache"
  CODE
    [[
    unset(TEST_OPTION_22 CACHE)

    # Emulate an older jrl_option(), which left no internal entry behind: the option is
    # stuck at its fallback value and hidden.
    set(TEST_OPTION_22 OFF CACHE BOOL "Test option 22")
    mark_as_advanced(TEST_OPTION_22)

    set(DEP_22 ON)
    jrl_option(TEST_OPTION_22 "Test option 22" ON CONDITION "DEP_22" FALLBACK OFF)

    _jrl_check("${TEST_OPTION_22}" STREQUAL "ON")
    get_property(advanced CACHE TEST_OPTION_22 PROPERTY ADVANCED)
    _jrl_check(NOT "${advanced}" ERROR_MESSAGE "Recovered option should not be advanced")
  ]]
)

jrl_test_case(
  NAME "CONDITION expanding to a false constant disables the option"
  CODE
    [[
    unset(TEST_OPTION_21 CACHE)
    set(DEP_21 OFF)

    # A condition passed already expanded, e.g. CONDITION "${DEP_21}".
    jrl_option(TEST_OPTION_21 "Test option 21" ON CONDITION "${DEP_21}" FALLBACK OFF)

    _jrl_check("${TEST_OPTION_21}" STREQUAL "OFF")
  ]]
)

jrl_test_case(
  NAME "Fatal error when CONDITION is empty"
  CODE
    [[
    set(PROJECT_NAME test_project)

    jrl_option(EMPTY_COND_OPT "desc" ON CONDITION "${UNDEFINED_DEP}" FALLBACK OFF)
  ]]
  WILL_FAIL
)

# The messages below are checked with CTest's own PASS_REGULAR_EXPRESSION /
# FAIL_REGULAR_EXPRESSION properties, which jrl_test_case forwards verbatim.

jrl_test_case(
  NAME "An overridden request is reported again on the next configure"
  CODE
    [[
    set(PROJECT_NAME test_project)
    unset(OPT_MSG_1 CACHE)
    set(OPT_MSG_1 ON CACHE BOOL "Value the user asked for")

    jrl_option(OPT_MSG_1 "An option" OFF CONDITION "MSG_DEP" FALLBACK OFF)
    message(STATUS "=== next configure ===")
    # The request is still pending, so it is reported again: re-running cmake is the only
    # place where the user can learn why the option does not follow them.
    jrl_option(OPT_MSG_1 "An option" OFF CONDITION "MSG_DEP" FALLBACK OFF)
  ]]
  PROPERTIES
    PASS_REGULAR_EXPRESSION
    "=== next configure ===.*Option OPT_MSG_1 is forced to 'OFF'"
)

jrl_test_case(
  NAME "Nothing is reported when no request is being overridden"
  CODE
    [[
    set(PROJECT_NAME test_project)
    unset(OPT_MSG_2 CACHE)

    set(MSG_DEP ON)
    jrl_option(OPT_MSG_2 "An option" OFF CONDITION "MSG_DEP" FALLBACK OFF)
    # The remembered value is the fallback, so nothing is being overridden.
    set(MSG_DEP OFF)
    jrl_option(OPT_MSG_2 "An option" OFF CONDITION "MSG_DEP" FALLBACK OFF)
  ]]
  PROPERTIES FAIL_REGULAR_EXPRESSION "is forced to"
)

jrl_test_case(
  NAME "Becoming available again is reported"
  CODE
    [[
    set(PROJECT_NAME test_project)
    unset(OPT_MSG_3 CACHE)

    jrl_option(OPT_MSG_3 "An option" ON CONDITION "MSG_DEP" FALLBACK OFF)
    set(MSG_DEP ON)
    jrl_option(OPT_MSG_3 "An option" ON CONDITION "MSG_DEP" FALLBACK OFF)
  ]]
  PROPERTIES
    PASS_REGULAR_EXPRESSION
    "Option OPT_MSG_3 is available again.*and set to 'ON'"
)

jrl_test_case(
  NAME "Becoming available is only reported on the transition"
  CODE
    [[
    set(PROJECT_NAME test_project)
    unset(OPT_MSG_4 CACHE)

    # An option that was never forced is an ordinary enabled option, so it must not be
    # reported as available again.
    set(MSG_DEP ON)
    set(OPT_MSG_4 ON CACHE BOOL "Already set")
    jrl_option(OPT_MSG_4 "An option" ON CONDITION "MSG_DEP" FALLBACK OFF)
  ]]
  PROPERTIES FAIL_REGULAR_EXPRESSION "is available again"
)

jrl_test_case(
  NAME "The options summary says why an option is unavailable"
  CODE
    [[
    set(PROJECT_NAME test_project)
    unset(OPT_MSG_5 CACHE)

    # Nothing was requested here, so nothing is printed while configuring: only the summary
    # can explain why the value differs from the default.
    jrl_option(OPT_MSG_5 "An option" ON CONDITION "MSG_DEP" FALLBACK OFF)
    jrl_print_options_summary()
  ]]
  PROPERTIES
    PASS_REGULAR_EXPRESSION
    "Unavailable: condition 'MSG_DEP' is false"
)

jrl_test_case(
  NAME "The options summary does not flag an available option"
  CODE
    [[
    set(PROJECT_NAME test_project)
    unset(OPT_MSG_6 CACHE)

    set(MSG_DEP ON)
    jrl_option(OPT_MSG_6 "An option" ON CONDITION "MSG_DEP" FALLBACK OFF)
    jrl_print_options_summary()
  ]]
  PROPERTIES FAIL_REGULAR_EXPRESSION "Unavailable"
)

# CMP0077: a normal variable set by a parent project takes precedence.

jrl_test_case(
  NAME "A normal variable set by the parent project wins, like option()"
  CODE
    [[
    unset(OPT_CMP0077_1 CACHE)
    set(OPT_CMP0077_1 OFF)

    jrl_option(OPT_CMP0077_1 "An option" ON)

    _jrl_check("${OPT_CMP0077_1}" STREQUAL "OFF")
    # Do not create a cache entry so GUI tools reflect the actual value used.
    _jrl_check(NOT DEFINED CACHE{OPT_CMP0077_1})
  ]]
)

jrl_test_case(
  NAME "A normal variable does not stop a false CONDITION from applying"
  CODE
    [[
    unset(OPT_CMP0077_2 CACHE)
    set(OPT_CMP0077_2 ON)
    set(CMP0077_DEP OFF)

    jrl_option(OPT_CMP0077_2 "An option" ON CONDITION "CMP0077_DEP" FALLBACK OFF)

    # A false condition still overrides normal variables from parent projects.
    _jrl_check("${OPT_CMP0077_2}" STREQUAL "OFF")
  ]]
)

jrl_test_case(
  NAME "Overriding a normal variable to satisfy a CONDITION is reported"
  CODE
    [[
    set(PROJECT_NAME test_project)
    unset(OPT_CMP0077_3 CACHE)
    set(OPT_CMP0077_3 ON)
    set(CMP0077_DEP OFF)

    jrl_option(OPT_CMP0077_3 "An option" ON CONDITION "CMP0077_DEP" FALLBACK OFF)
  ]]
  PROPERTIES
    PASS_REGULAR_EXPRESSION
    "Option OPT_CMP0077_3 is forced to 'OFF'.*set to 'ON' by the parent project"
)

jrl_test_case(
  NAME "An option taken over by the parent project still appears in the summary"
  CODE
    [[
    set(PROJECT_NAME test_project)
    unset(OPT_CMP0077_4 CACHE)
    set(OPT_CMP0077_4 OFF)

    jrl_option(OPT_CMP0077_4 "An option" ON)
    jrl_print_options_summary()
  ]]
  PROPERTIES PASS_REGULAR_EXPRESSION "OPT_CMP0077_4"
)
