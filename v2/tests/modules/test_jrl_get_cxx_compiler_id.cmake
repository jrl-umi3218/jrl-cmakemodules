jrl_test_case(
  NAME "Returns GCC when CMAKE_CXX_COMPILER_ID is GNU"
  CODE [[
    set(CMAKE_CXX_COMPILER_ID "GNU")
    jrl_get_cxx_compiler_id(result)
    _jrl_check("${result}" STREQUAL "GNU")
  ]]
)

jrl_test_case(
  NAME "Returns Clang when CMAKE_CXX_COMPILER_ID is Clang"
  CODE [[
    set(CMAKE_CXX_COMPILER_ID "Clang")
    jrl_get_cxx_compiler_id(result)
    _jrl_check("${result}" STREQUAL "Clang")
  ]]
)

jrl_test_case(
  NAME "Returns Clang when CMAKE_CXX_COMPILER_ID is AppleClang"
  CODE [[
    set(CMAKE_CXX_COMPILER_ID "AppleClang")
    jrl_get_cxx_compiler_id(result)
    _jrl_check("${result}" STREQUAL "Clang")
  ]]
)

jrl_test_case(
  NAME "Returns MSVC when CMAKE_CXX_COMPILER_ID is MSVC"
  CODE [[
    set(CMAKE_CXX_COMPILER_ID "MSVC")
    jrl_get_cxx_compiler_id(result)
    _jrl_check("${result}" STREQUAL "MSVC")
  ]]
)

jrl_test_case(
  NAME "Returns MSVC when clang-cl via SIMULATE_ID branch (no FRONTEND_VARIANT)"
  CODE [[
    set(CMAKE_CXX_COMPILER_ID "Clang")
    set(CMAKE_CXX_SIMULATE_ID "MSVC")
    jrl_get_cxx_compiler_id(result)
    _jrl_check("${result}" STREQUAL "MSVC")
  ]]
)

jrl_test_case(
  NAME "Returns MSVC when real clang-cl (FRONTEND_VARIANT=MSVC takes priority)"
  CODE [[
    set(CMAKE_CXX_COMPILER_ID "Clang")
    set(CMAKE_CXX_SIMULATE_ID "MSVC")
    set(CMAKE_CXX_COMPILER_FRONTEND_VARIANT "MSVC")
    jrl_get_cxx_compiler_id(result)
    _jrl_check("${result}" STREQUAL "MSVC")
  ]]
)

jrl_test_case(
  NAME "FRONTEND_VARIANT takes priority over compiler ID"
  CODE [[
    set(CMAKE_CXX_COMPILER_ID "Clang")
    set(CMAKE_CXX_COMPILER_FRONTEND_VARIANT "GNU")
    jrl_get_cxx_compiler_id(result)
    _jrl_check("${result}" STREQUAL "GNU")
  ]]
)

jrl_test_case(
  NAME "Fatal error when CMAKE_CXX_COMPILER_ID is not defined"
  CODE [[
    unset(CMAKE_CXX_COMPILER_ID)
    jrl_get_cxx_compiler_id(result)
  ]]
  WILL_FAIL
)
