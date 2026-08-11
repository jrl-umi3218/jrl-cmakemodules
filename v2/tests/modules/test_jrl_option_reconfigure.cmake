# Copyright 2025-2026 Inria

# These test cases run several `cmake -S . -B build` in one build tree, so that the CMake
# cache comes into play: an option must follow its CONDITION from one configure to the next.

jrl_test_case(
  NAME "[reconfigure] Enabling the condition restores and shows the option"
  CODE
    [[
    jrl_option(RC_OPTION "Conditional option" ON CONDITION "RC_DEP" FALLBACK OFF)

    expect_option(RC_OPTION VALUE ${EXPECTED_VALUE} ADVANCED ${EXPECTED_ADVANCED})
  ]]
  STEPS
    # The condition is false: the option is forced to its fallback and hidden.
    "-DRC_DEP=OFF -DEXPECTED_VALUE=OFF -DEXPECTED_ADVANCED=1"
    # The condition is now true: the option goes back to its default and becomes visible.
    "-DRC_DEP=ON -DEXPECTED_VALUE=ON -DEXPECTED_ADVANCED=0"
    # A plain re-configure keeps it that way.
    "-DEXPECTED_VALUE=ON -DEXPECTED_ADVANCED=0"
)

jrl_test_case(
  NAME "[reconfigure] Disabling the condition again hides the option again"
  CODE
    [[
    jrl_option(RC_OPTION "Conditional option" ON CONDITION "RC_DEP" FALLBACK OFF)

    expect_option(RC_OPTION VALUE ${EXPECTED_VALUE} ADVANCED ${EXPECTED_ADVANCED})
  ]]
  STEPS
    "-DRC_DEP=ON -DEXPECTED_VALUE=ON -DEXPECTED_ADVANCED=0"
    "-DRC_DEP=OFF -DEXPECTED_VALUE=OFF -DEXPECTED_ADVANCED=1"
    "-DRC_DEP=ON -DEXPECTED_VALUE=ON -DEXPECTED_ADVANCED=0"
    # Hiding it a second time is the case that needs mark_as_advanced(FORCE): the
    # re-enable above cleared the flag explicitly, so a plain mark_as_advanced() is a no-op.
    "-DRC_DEP=OFF -DEXPECTED_VALUE=OFF -DEXPECTED_ADVANCED=1"
)

jrl_test_case(
  NAME "[reconfigure] Option stays forced and hidden while the condition is false"
  CODE
    [[
    jrl_option(RC_OPTION "Conditional option" ON CONDITION "RC_DEP" FALLBACK OFF)

    expect_option(RC_OPTION VALUE ${EXPECTED_VALUE} ADVANCED ${EXPECTED_ADVANCED})
  ]]
  STEPS
    "-DRC_DEP=OFF -DEXPECTED_VALUE=OFF -DEXPECTED_ADVANCED=1"
    "-DEXPECTED_VALUE=OFF -DEXPECTED_ADVANCED=1"
    "-DEXPECTED_VALUE=OFF -DEXPECTED_ADVANCED=1"
)

jrl_test_case(
  NAME "[reconfigure] A value set by the user survives a condition round trip"
  CODE
    [[
    jrl_option(RC_OPTION "Conditional option" ON CONDITION "RC_DEP" FALLBACK OFF)

    expect_option(RC_OPTION VALUE ${EXPECTED_VALUE} ADVANCED ${EXPECTED_ADVANCED})
  ]]
  STEPS
    # The user turns OFF an option whose default is ON.
    "-DRC_DEP=ON -DRC_OPTION=OFF -DEXPECTED_VALUE=OFF -DEXPECTED_ADVANCED=0"
    "-DRC_DEP=OFF -DEXPECTED_VALUE=OFF -DEXPECTED_ADVANCED=1"
    # Their choice must be restored, not the ON default.
    "-DRC_DEP=ON -DEXPECTED_VALUE=OFF -DEXPECTED_ADVANCED=0"
)

jrl_test_case(
  NAME "[reconfigure] A value requested while disabled is applied once the condition holds"
  CODE
    [[
    jrl_option(RC_OPTION "Conditional option" OFF CONDITION "RC_DEP" FALLBACK OFF)

    expect_option(RC_OPTION VALUE ${EXPECTED_VALUE} ADVANCED ${EXPECTED_ADVANCED})
  ]]
  STEPS
    # cmake -DRC_OPTION=ON while the condition is false: still forced to the fallback.
    "-DRC_DEP=OFF -DRC_OPTION=ON -DEXPECTED_VALUE=OFF -DEXPECTED_ADVANCED=1"
    # The request is honoured as soon as the condition becomes true.
    "-DRC_DEP=ON -DEXPECTED_VALUE=ON -DEXPECTED_ADVANCED=0"
)

jrl_test_case(
  NAME "[reconfigure] A build tree hidden by an older jrl_option is recovered"
  CODE
    [[
    if(SIMULATE_LEGACY_CACHE)
      # Reproduce the cache an older jrl_option() left behind: the option sits at its
      # fallback value, is hidden, and carries no internal bookkeeping entry.
      set(RC_OPTION OFF CACHE BOOL "Conditional option" FORCE)
      mark_as_advanced(RC_OPTION)
    else()
      jrl_option(RC_OPTION "Conditional option" ON CONDITION "RC_DEP" FALLBACK OFF)
    endif()

    expect_option(RC_OPTION VALUE ${EXPECTED_VALUE} ADVANCED ${EXPECTED_ADVANCED})
  ]]
  STEPS
    "-DSIMULATE_LEGACY_CACHE=ON -DRC_DEP=OFF -DEXPECTED_VALUE=OFF -DEXPECTED_ADVANCED=1"
    # Upgrading jrl-cmakemodules must not require wiping that build tree.
    "-DSIMULATE_LEGACY_CACHE=OFF -DRC_DEP=ON -DEXPECTED_VALUE=ON -DEXPECTED_ADVANCED=0"
)

jrl_test_case(
  NAME "[reconfigure] A project hiding the option itself does not lose the user value"
  CODE
    [[
    jrl_option(RC_OPTION "Conditional option" ON CONDITION "RC_DEP" FALLBACK OFF)
    # A project may hide an option itself. This must not be mistaken for the cache an older
    # jrl_option() left behind, which looks the same: hidden and at the fallback value.
    mark_as_advanced(RC_OPTION)

    expect_option(RC_OPTION VALUE ${EXPECTED_VALUE} ADVANCED 1)
  ]]
  STEPS
    # The user turns the option OFF, which happens to be the fallback value.
    "-DRC_DEP=ON -DRC_OPTION=OFF -DEXPECTED_VALUE=OFF"
    # Re-configuring must keep their OFF, not restore the ON default.
    "-DRC_DEP=ON -DEXPECTED_VALUE=OFF"
    "-DRC_DEP=ON -DEXPECTED_VALUE=OFF"
)

jrl_test_case(
  NAME "[reconfigure] A semicolon-separated CONDITION list behaves like cmake_dependent_option"
  CODE
    [[
    jrl_option(RC_OPTION "Conditional option" ON CONDITION "RC_BAR;NOT RC_ZOT" FALLBACK OFF)

    expect_option(RC_OPTION VALUE ${EXPECTED_VALUE} ADVANCED ${EXPECTED_ADVANCED})
  ]]
  STEPS
    "-DRC_BAR=ON -DRC_ZOT=OFF -DEXPECTED_VALUE=ON -DEXPECTED_ADVANCED=0"
    # Either element going false is enough to disable the option.
    "-DRC_ZOT=ON -DEXPECTED_VALUE=OFF -DEXPECTED_ADVANCED=1"
    "-DRC_ZOT=OFF -DEXPECTED_VALUE=ON -DEXPECTED_ADVANCED=0"
    "-DRC_BAR=OFF -DEXPECTED_VALUE=OFF -DEXPECTED_ADVANCED=1"
)

jrl_test_case(
  NAME "[reconfigure] A legacy name migrates once and then stops overriding"
  CODE
    [[
    jrl_option(RC_OPTION "Migrated option" OFF LEGACY_NAME RC_OLD_OPTION)

    expect_option(RC_OPTION VALUE ${EXPECTED_VALUE} ADVANCED 0)
  ]]
  STEPS
    # The user still passes the deprecated name: its value is migrated.
    "-DRC_OLD_OPTION=ON -DEXPECTED_VALUE=ON"
    # They follow the deprecation warning and use the new name. This has to work without
    # also clearing the old one with -URC_OLD_OPTION.
    "-DRC_OPTION=OFF -DEXPECTED_VALUE=OFF"
    "-DEXPECTED_VALUE=OFF"
)

jrl_test_case(
  NAME "[reconfigure] A legacy name does not bypass a false CONDITION"
  CODE
    [[
    jrl_option(RC_OPTION "Conditional option" OFF CONDITION "RC_DEP" FALLBACK OFF LEGACY_NAME RC_OLD_OPTION)

    expect_option(RC_OPTION VALUE ${EXPECTED_VALUE} ADVANCED ${EXPECTED_ADVANCED})
  ]]
  STEPS
    # Asking for ON through the deprecated name while the condition is false must be
    # overridden, exactly as -DRC_OPTION=ON would be.
    "-DRC_DEP=OFF -DRC_OLD_OPTION=ON -DEXPECTED_VALUE=OFF -DEXPECTED_ADVANCED=1"
    # ... and remembered, so it applies once the condition holds.
    "-DRC_DEP=ON -DEXPECTED_VALUE=ON -DEXPECTED_ADVANCED=0"
)

jrl_test_case(
  NAME "[reconfigure] Unconditional options keep their user value"
  CODE
    [[
    jrl_option(RC_OPTION "Plain option" ON)

    expect_option(RC_OPTION VALUE ${EXPECTED_VALUE} ADVANCED 0)
  ]]
  STEPS
    "-DEXPECTED_VALUE=ON"
    "-DRC_OPTION=OFF -DEXPECTED_VALUE=OFF"
    "-DEXPECTED_VALUE=OFF"
)

jrl_test_case(
  NAME "[reconfigure] An option taken over by the parent project stays out of the cache"
  CODE
    [[
    # Simulate a parent project setting the variable before add_subdirectory().
    set(RC_OPTION OFF)
    jrl_option(RC_OPTION "Conditional option" ON CONDITION "RC_DEP" FALLBACK OFF)

    if(NOT "${RC_OPTION}" STREQUAL "${EXPECTED_VALUE}")
      message(FATAL_ERROR "Expected RC_OPTION to be '${EXPECTED_VALUE}', got '${RC_OPTION}'")
    endif()
    # Ensure no cache entry is created.
    if(DEFINED CACHE{RC_OPTION})
      message(FATAL_ERROR "Expected no RC_OPTION cache entry, got '$CACHE{RC_OPTION}'")
    endif()
  ]]
  STEPS
    "-DRC_DEP=ON -DEXPECTED_VALUE=OFF"
    # Reconfiguring must not create a cache entry.
    "-DRC_DEP=ON -DEXPECTED_VALUE=OFF"
    # Condition going false keeps the fallback value.
    "-DRC_DEP=OFF -DEXPECTED_VALUE=OFF"
)
