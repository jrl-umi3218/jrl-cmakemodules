cmake_minimum_required(VERSION 3.22)
project(python_module_version LANGUAGES NONE)

include(${CMAKE_CURRENT_SOURCE_DIR}/../add_cmake_test.cmake)

enable_testing()

# Getting the jrl-cmakemodules dep.
add_cmake_test(NAME jrl-cmakemodules SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../..")

# 1. Version constraints, EXACT, ranges and probe caching.
add_cmake_test(
    NAME pmv-checks
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/pmv-checks"
    DEPENDS jrl-cmakemodules
    BUILD_TARGET all
)

# 2. A REQUIRED module whose version is not satisfied must fail the configuration.
add_cmake_test(
    NAME pmv-required-fail
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/pmv-required-fail"
    DEPENDS jrl-cmakemodules
    BUILD_TARGET all
    WILL_FAIL TRUE
)
