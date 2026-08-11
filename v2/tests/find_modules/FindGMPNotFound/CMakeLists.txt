cmake_minimum_required(VERSION 3.22)
project(FindGMPNotFoundTest)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../find-modules")

# Restrict search paths to ensure we don't search the system.
set(CMAKE_FIND_USE_CMAKE_SYSTEM_PATH false)
set(CMAKE_FIND_USE_CMAKE_PATH false)
set(CMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH false)
set(CMAKE_FIND_USE_INSTALL_PREFIX false)
set(CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH false)
set(CMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY false)
set(CMAKE_FIND_USE_PACKAGE_REGISTRY false)
set(CMAKE_FIND_USE_PACKAGE_ROOT_PATH false)

find_package(GMP QUIET)

if(TARGET GMP::GMP)
    set(target_exists true)
else()
    set(target_exists false)
endif()

message(
    STATUS
    "
GMP_FOUND=${GMP_FOUND}
GMP_INCLUDE_DIR=${GMP_INCLUDE_DIR}
GMP_LIBRARY=${GMP_LIBRARY}
GMP::GMP exists ? ${target_exists}
"
)
if(GMP_FOUND OR TARGET GMP::GMP)
    message(
        FATAL_ERROR
        "GMP_FOUND (${GMP_FOUND}) or GMP::GMP (${target_exists}) found but should not."
    )
endif()
