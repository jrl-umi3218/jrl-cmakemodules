cmake_minimum_required(VERSION 3.22)
project(FindMPFRNotFoundTest)

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

find_package(MPFR QUIET)

if(TARGET MPFR::MPFR)
    set(target_exists true)
else()
    set(target_exists false)
endif()

message(
    STATUS
    "
MPFR_FOUND=${MPFR_FOUND}
MPFR_INCLUDE_DIR=${MPFR_INCLUDE_DIR}
MPFR_LIBRARY=${MPFR_LIBRARY}
MPFR::MPFR exists ? ${target_exists}
"
)
if(MPFR_FOUND OR TARGET MPFR::MPFR)
    message(
        FATAL_ERROR
        "MPFR_FOUND (${MPFR_FOUND}) or MPFR::MPFR (${target_exists}) found but should not."
    )
endif()
