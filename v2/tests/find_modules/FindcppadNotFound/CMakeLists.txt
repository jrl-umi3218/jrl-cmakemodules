cmake_minimum_required(VERSION 3.22)
project(FindcppadNotFoundTest)

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

find_package(cppad QUIET)

if(TARGET cppad::cppad)
    set(target_exists true)
else()
    set(target_exists false)
endif()

message(
    STATUS
    "
cppad_FOUND=${cppad_FOUND}
cppad_INCLUDE_DIR=${cppad_INCLUDE_DIR}
cppad_LIBRARY=${cppad_LIBRARY}
cppad::cppad exists ? ${target_exists}
"
)
if(cppad_FOUND OR TARGET cppad::cppad)
    message(
        FATAL_ERROR
        "cppad_FOUND (${cppad_FOUND}) or cppad::cppad (${target_exists}) found but should not."
    )
endif()
