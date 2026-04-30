jrl_test_case(
  NAME "1.2.3 -> VERSION_FULL=1.2.3, VERSION_FULL_WITH_TWEAK=1.2.3.0"
  CODE [[
    _jrl_normalize_version("1.2.3"
      VERSION_FULL full
      VERSION_FULL_WITH_TWEAK full_tweak
      VERSION_MAJOR major
      VERSION_MINOR minor
      VERSION_PATCH patch
      VERSION_TWEAK tweak
    )

    _jrl_check_strequal("${full}"       "1.2.3")
    _jrl_check_strequal("${full_tweak}" "1.2.3.0")
    _jrl_check_strequal("${major}"      "1")
    _jrl_check_strequal("${minor}"      "2")
    _jrl_check_strequal("${patch}"      "3")
    _jrl_check_strequal("${tweak}"      "0")
  ]]
)

jrl_test_case(
  NAME "1.2 -> VERSION_FULL=1.2.0, VERSION_FULL_WITH_TWEAK=1.2.0.0"
  CODE [[
    _jrl_normalize_version("1.2"
      VERSION_FULL full
      VERSION_FULL_WITH_TWEAK full_tweak
      VERSION_MAJOR major
      VERSION_MINOR minor
      VERSION_PATCH patch
      VERSION_TWEAK tweak
    )

    _jrl_check_strequal("${full}"       "1.2.0")
    _jrl_check_strequal("${full_tweak}" "1.2.0.0")
    _jrl_check_strequal("${major}"      "1")
    _jrl_check_strequal("${minor}"      "2")
    _jrl_check_strequal("${patch}"      "0")
    _jrl_check_strequal("${tweak}"      "0")
  ]]
)

jrl_test_case(
  NAME "4 -> VERSION_FULL=4.0.0"
  CODE [[
    _jrl_normalize_version("4"
      VERSION_FULL full
      VERSION_FULL_WITH_TWEAK full_tweak
      VERSION_MAJOR major
      VERSION_MINOR minor
      VERSION_PATCH patch
    )

    _jrl_check_strequal("${full}"       "4.0.0")
    _jrl_check_strequal("${full_tweak}" "4.0.0.0")
    _jrl_check_strequal("${major}"      "4")
    _jrl_check_strequal("${minor}"      "0")
    _jrl_check_strequal("${patch}"      "0")
  ]]
)

jrl_test_case(
  NAME "1.0.5.2023 -> VERSION_FULL=1.0.5, VERSION_FULL_WITH_TWEAK=1.0.5.2023"
  CODE [[
    _jrl_normalize_version("1.0.5.2023"
      VERSION_FULL full
      VERSION_FULL_WITH_TWEAK full_tweak
      VERSION_TWEAK tweak
    )

    _jrl_check_strequal("${full}"       "1.0.5")
    _jrl_check_strequal("${full_tweak}" "1.0.5.2023")
    _jrl_check_strequal("${tweak}"      "2023")
  ]]
)

jrl_test_case(
  NAME "'' -> VERSION_FULL=0.0.0"
  CODE [[
    _jrl_normalize_version(""
      VERSION_FULL full
      VERSION_FULL_WITH_TWEAK full_tweak
      VERSION_MAJOR major
      VERSION_MINOR minor
      VERSION_PATCH patch
      VERSION_TWEAK tweak
    )

    _jrl_check_strequal("${full}"       "0.0.0")
    _jrl_check_strequal("${full_tweak}" "0.0.0.0")
    _jrl_check_strequal("${major}"      "0")
    _jrl_check_strequal("${minor}"      "0")
    _jrl_check_strequal("${patch}"      "0")
    _jrl_check_strequal("${tweak}"      "0")
  ]]
)

jrl_test_case(
  NAME "2.5-rc1 -> VERSION_FULL=2.5.0"
  CODE [[
    _jrl_normalize_version("2.5-rc1"
      VERSION_FULL full
      VERSION_FULL_WITH_TWEAK full_tweak
      VERSION_MAJOR major
      VERSION_MINOR minor
      VERSION_PATCH patch
    )

    _jrl_check_strequal("${full}"       "2.5.0")
    _jrl_check_strequal("${full_tweak}" "2.5.0.0")
    _jrl_check_strequal("${major}"      "2")
    _jrl_check_strequal("${minor}"      "5")
    _jrl_check_strequal("${patch}"      "0")
  ]]
)

jrl_test_case(
  NAME "Only VERSION_FULL requested"
  CODE [[
    unset(only_full)

    _jrl_normalize_version("3.1.4" VERSION_FULL only_full)

    _jrl_check_strequal("${only_full}" "3.1.4")
  ]]
)

jrl_test_case(
  NAME "Fatal error on unrecognized argument"
  CODE [[
    _jrl_normalize_version("1.0.0" UNKNOWN_ARG val)
  ]]
  WILL_FAIL
)
