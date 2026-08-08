# Copyright 2025-2026 Inria

jrl_test_case(
  NAME "empty request is always compatible"
  CODE [[
    _jrl_version_is_compatible("1.2.3" "" OUTPUT ok)
    _jrl_check("${ok}")

    _jrl_version_is_compatible("" "" OUTPUT ok)
    _jrl_check("${ok}")
  ]]
)

jrl_test_case(
  NAME "minimum version request"
  CODE [[
    _jrl_version_is_compatible("4.12.2" "4.5" OUTPUT ok)
    _jrl_check("${ok}")

    _jrl_version_is_compatible("4.5" "4.5" OUTPUT ok)
    _jrl_check("${ok}")

    _jrl_version_is_compatible("4.5.0" "4.5" OUTPUT ok)
    _jrl_check("${ok}")

    _jrl_version_is_compatible("4.4.9" "4.5" OUTPUT ok)
    _jrl_check(NOT "${ok}")

    _jrl_version_is_compatible("3" "4" OUTPUT ok)
    _jrl_check(NOT "${ok}")
  ]]
)

jrl_test_case(
  NAME "EXACT only compares the requested components"
  CODE [[
    _jrl_version_is_compatible("1.2.7" "1.2" EXACT OUTPUT ok)
    _jrl_check("${ok}")

    _jrl_version_is_compatible("1.2.7" "1.2.7" EXACT OUTPUT ok)
    _jrl_check("${ok}")

    _jrl_version_is_compatible("1.2.7" "1.2.8" EXACT OUTPUT ok)
    _jrl_check(NOT "${ok}")

    _jrl_version_is_compatible("1.3.0" "1.2" EXACT OUTPUT ok)
    _jrl_check(NOT "${ok}")

    _jrl_version_is_compatible("2.0.0" "2" EXACT OUTPUT ok)
    _jrl_check("${ok}")
  ]]
)

jrl_test_case(
  NAME "inclusive version range"
  CODE [[
    _jrl_version_is_compatible("1.5.0" "1.2...2.0" OUTPUT ok)
    _jrl_check("${ok}")

    _jrl_version_is_compatible("1.2" "1.2...2.0" OUTPUT ok)
    _jrl_check("${ok}")

    _jrl_version_is_compatible("2.0" "1.2...2.0" OUTPUT ok)
    _jrl_check("${ok}")

    _jrl_version_is_compatible("2.0.1" "1.2...2.0" OUTPUT ok)
    _jrl_check(NOT "${ok}")

    _jrl_version_is_compatible("1.1.9" "1.2...2.0" OUTPUT ok)
    _jrl_check(NOT "${ok}")
  ]]
)

jrl_test_case(
  NAME "exclusive upper bound version range"
  CODE [[
    _jrl_version_is_compatible("2.9.9" "1.21...<3" OUTPUT ok)
    _jrl_check("${ok}")

    _jrl_version_is_compatible("3.0.0" "1.21...<3" OUTPUT ok)
    _jrl_check(NOT "${ok}")

    _jrl_version_is_compatible("2.0" "1.21...<2.0" OUTPUT ok)
    _jrl_check(NOT "${ok}")
  ]]
)

jrl_test_case(
  NAME "python version suffixes are ignored"
  CODE [[
    _jrl_version_is_compatible("4.12.2.post1" "4.12.2" OUTPUT ok)
    _jrl_check("${ok}")

    _jrl_version_is_compatible("2.0.0rc1" "2.0.0" EXACT OUTPUT ok)
    _jrl_check("${ok}")

    _jrl_version_is_compatible("1.0.5.dev0" "1.0...2.0" OUTPUT ok)
    _jrl_check("${ok}")
  ]]
)

jrl_test_case(
  NAME "non numeric version is not compatible"
  CODE [[
    _jrl_version_is_compatible("unknown" "1.0" OUTPUT ok)
    _jrl_check(NOT "${ok}")
  ]]
)

jrl_test_case(
  NAME "suffixed versions are accepted in the request"
  CODE [[
    _jrl_version_is_compatible("2.0.0" "2.0.0rc1" OUTPUT ok)
    _jrl_check("${ok}")

    _jrl_version_is_compatible("1.5.0" "1.0...2.0.0-dev" OUTPUT ok)
    _jrl_check("${ok}")

    # A numeric prefix is enough, the rest of the bound is ignored.
    _jrl_version_is_compatible("1.0.0" "99garbage" OUTPUT ok)
    _jrl_check(NOT "${ok}")
  ]]
)

jrl_test_case(
  NAME "a version request without a version number fails"
  WILL_FAIL
  CODE [[
    _jrl_version_is_compatible("1.0.0" "invalid_version" OUTPUT ok)
  ]]
)

jrl_test_case(
  NAME "a version request without a version number fails with EXACT"
  WILL_FAIL
  CODE [[
    _jrl_version_is_compatible("1.2.3" "beta" EXACT OUTPUT ok)
  ]]
)

jrl_test_case(
  NAME "an invalid range lower bound fails"
  WILL_FAIL
  CODE [[
    _jrl_version_is_compatible("1.5.0" "garbage...2.0" OUTPUT ok)
  ]]
)

jrl_test_case(
  NAME "an invalid range upper bound fails"
  WILL_FAIL
  CODE [[
    _jrl_version_is_compatible("1.5.0" "1.0...garbage" OUTPUT ok)
  ]]
)

jrl_test_case(
  NAME "EXACT without a version fails"
  WILL_FAIL
  CODE [[
    _jrl_version_is_compatible("1.2.3" "" EXACT OUTPUT ok)
  ]]
)

jrl_test_case(
  NAME "EXACT with a version range fails"
  WILL_FAIL
  CODE [[
    _jrl_version_is_compatible("1.5" "1.2...2.0" EXACT OUTPUT ok)
  ]]
)

jrl_test_case(
  NAME "OUTPUT is required"
  WILL_FAIL
  CODE [[
    _jrl_version_is_compatible("1.5" "1.2")
  ]]
)

jrl_test_case(
  NAME "jrl_check_python_module EXACT without a version fails"
  WILL_FAIL
  CODE [[
    jrl_check_python_module(some_module EXACT)
  ]]
)
