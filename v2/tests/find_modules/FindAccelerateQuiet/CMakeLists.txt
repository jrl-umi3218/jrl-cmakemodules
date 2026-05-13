cmake_minimum_required(VERSION 3.22)
project(FindAccelerateQuietTest)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../find-modules")

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    message(STATUS "Accelerate is only available on macOS, skipping test")
    return()
endif()

# Restrict search paths to ensure Pytest is not found on the system.
set(CMAKE_FIND_USE_CMAKE_SYSTEM_PATH false)
set(CMAKE_FIND_USE_CMAKE_PATH false)
set(CMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH false)
set(CMAKE_FIND_USE_INSTALL_PREFIX false)
set(CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH false)
set(CMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY false)
set(CMAKE_FIND_USE_PACKAGE_REGISTRY false)
set(CMAKE_FIND_USE_PACKAGE_ROOT_PATH false)

find_package(Accelerate QUIET)

if(Accelerate_FOUND)
    message(FATAL_ERROR "Accelerate_FOUND should be FALSE when no search paths are available")
endif()
