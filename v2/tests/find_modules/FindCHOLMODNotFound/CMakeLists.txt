cmake_minimum_required(VERSION 3.22)
project(FindCHOLMODNotFoundTest)

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

find_package(CHOLMOD QUIET)

if(TARGET SuiteSparse::CHOLMOD)
    set(target_exists true)
else()
    set(target_exists false)
endif()

message(
    STATUS
    "
CHOLMOD_FOUND=${CHOLMOD_FOUND}
CHOLMOD_LIBRARY=${CHOLMOD_LIBRARY}
CHOLMOD_INCLUDE_DIR=${CHOLMOD_INCLUDE_DIR}
SuiteSparse::CHOLMOD exists ? ${target_exists}
"
)
if(CHOLMOD_FOUND OR TARGET SuiteSparse::CHOLMOD)
    message(
        FATAL_ERROR
        "CHOLMOD_FOUND (${CHOLMOD_FOUND}) or SuiteSparse::CHOLMOD (${target_exists}) found but should not."
    )
endif()
