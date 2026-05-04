jrl_test_case(
  NAME "Sets CMAKE_BUILD_TYPE when not already set"
  CODE [[
    unset(CMAKE_BUILD_TYPE CACHE)
    unset(CMAKE_CONFIGURATION_TYPES CACHE)
    unset(ENV{CMAKE_BUILD_TYPE})

    jrl_configure_default_build_type(Release)

    if(NOT CMAKE_BUILD_TYPE STREQUAL "Release")
      message(FATAL_ERROR "FAIL: CMAKE_BUILD_TYPE was not set to Release")
    endif()
  ]]
)

jrl_test_case(
  NAME "Does not override CMAKE_BUILD_TYPE when already set"
  CODE [[
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "existing" FORCE)

    jrl_configure_default_build_type(Release)

    if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
      message(FATAL_ERROR "FAIL: CMAKE_BUILD_TYPE changed from Debug")
    endif()
  ]]
)

jrl_test_case(
  NAME "Does not set CMAKE_BUILD_TYPE when CMAKE_CONFIGURATION_TYPES is set"
  CODE [[
    unset(CMAKE_BUILD_TYPE CACHE)
    unset(ENV{CMAKE_BUILD_TYPE})
    set(CMAKE_CONFIGURATION_TYPES Release CACHE STRING multi-config FORCE)

    jrl_configure_default_build_type(Release)

    if(CMAKE_BUILD_TYPE)
      message(FATAL_ERROR "FAIL: CMAKE_BUILD_TYPE should not be set")
    endif()
  ]]
)

jrl_test_case(
  NAME "AUTHOR_WARNING emitted for non-standard build type"
  CODE [[
    unset(CMAKE_BUILD_TYPE CACHE)
    unset(CMAKE_CONFIGURATION_TYPES CACHE)
    unset(ENV{CMAKE_BUILD_TYPE})

    jrl_configure_default_build_type(NonStandardBuildType)
  ]]
)

jrl_test_case(
  NAME "Sets CMAKE_BUILD_TYPE to Debug"
  CODE [[
    unset(CMAKE_BUILD_TYPE CACHE)
    unset(CMAKE_CONFIGURATION_TYPES CACHE)
    unset(ENV{CMAKE_BUILD_TYPE})

    jrl_configure_default_build_type(Debug)

    if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
      message(FATAL_ERROR "FAIL: CMAKE_BUILD_TYPE was not set to Debug")
    endif()
  ]]
)
