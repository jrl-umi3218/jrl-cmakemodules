cmake_minimum_required(VERSION 3.22)
project(FindcppadcgNotFoundTest)

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

find_package(cppadcg QUIET)

if(TARGET cppadcg::cppadcg)
    set(target_exists true)
else()
    set(target_exists false)
endif()

message(
    STATUS
    "
cppadcg_FOUND=${cppadcg_FOUND}
cppadcg_INCLUDE_DIR=${cppadcg_INCLUDE_DIR}
cppadcg::cppadcg exists ? ${target_exists}
"
)
if(cppadcg_FOUND OR TARGET cppadcg::cppadcg)
    message(
        FATAL_ERROR
        "cppadcg_FOUND (${cppadcg_FOUND}) or cppadcg::cppadcg (${target_exists}) found but should not."
    )
endif()
