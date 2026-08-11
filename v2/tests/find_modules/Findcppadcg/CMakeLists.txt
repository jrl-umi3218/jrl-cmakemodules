cmake_minimum_required(VERSION 3.22)
project(FindcppadcgTest)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../find-modules")

find_package(cppadcg REQUIRED)

message(
    STATUS
    "
cppadcg_FOUND=${cppadcg_FOUND}
cppadcg_VERSION=${cppadcg_VERSION}
cppadcg_INCLUDE_DIR=${cppadcg_INCLUDE_DIR}
"
)

if(NOT cppadcg_FOUND)
    message(FATAL_ERROR "cppadcg_FOUND is false after find_package(cppadcg REQUIRED)")
endif()

foreach(target IN ITEMS cppadcg::cppadcg cppad::cppad)
    if(NOT TARGET ${target})
        message(FATAL_ERROR "${target} imported target was not created")
    endif()
endforeach()

if(NOT cppadcg_VERSION)
    message(FATAL_ERROR "cppadcg_VERSION could not be parsed from the cppadcg headers")
endif()

get_target_property(target_include_dirs cppadcg::cppadcg INTERFACE_INCLUDE_DIRECTORIES)
if(NOT target_include_dirs)
    message(FATAL_ERROR "cppadcg::cppadcg does not expose INTERFACE_INCLUDE_DIRECTORIES")
endif()
