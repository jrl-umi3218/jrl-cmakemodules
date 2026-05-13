cmake_minimum_required(VERSION 3.22)
project(FindsimdeQuietTest)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../find-modules")

# Restrict search paths to ensure Pytest is not found on the system.
set(CMAKE_FIND_USE_CMAKE_SYSTEM_PATH false)
set(CMAKE_FIND_USE_CMAKE_PATH false)
set(CMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH false)
set(CMAKE_FIND_USE_INSTALL_PREFIX false)
set(CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH false)
set(CMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY false)
set(CMAKE_FIND_USE_PACKAGE_REGISTRY false)
set(CMAKE_FIND_USE_PACKAGE_ROOT_PATH false)

find_package(simde QUIET)

message(
    STATUS
    "

simde_FOUND: ${simde_FOUND}
simde_VERSION: ${simde_VERSION}
simde_INCLUDE_DIR: ${simde_INCLUDE_DIR}

"
)

if(simde_FOUND)
    message(FATAL_ERROR "simde_FOUND should be FALSE when no search paths are available")
endif()
