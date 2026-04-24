cmake_minimum_required(VERSION 3.22)
project(FindmatioQuietTest)

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)

# Restrict search paths to ensure Pytest is not found on the system.
set(CMAKE_FIND_USE_CMAKE_SYSTEM_PATH false)
set(CMAKE_FIND_USE_CMAKE_PATH false)
set(CMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH false)
set(CMAKE_FIND_USE_INSTALL_PREFIX false)
set(CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH false)
set(CMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY false)
set(CMAKE_FIND_USE_PACKAGE_REGISTRY false)
set(CMAKE_FIND_USE_PACKAGE_ROOT_PATH false)

jrl_find_package(matio QUIET)

if(TARGET matio::matio)
    set(target_exists true)
else()
    set(target_exists false)
endif()

message(
    STATUS
    "
matio_FOUND=${matio_FOUND}
matio_LIBRARY=${matio_LIBRARY}
matio_INCLUDE_DIR=${matio_INCLUDE_DIR}
matio::matio exists ? ${target_exists}
"
)
if(matio_FOUND OR TARGET matio::matio)
    message(
        FATAL_ERROR
        "matio_FOUND (${matio_FOUND}) or matio::matio (${target_exists}) found but should not."
    )
endif()
