cmake_minimum_required(VERSION 3.22)
project(FindGMPTest)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../find-modules")

find_package(GMP REQUIRED)

message(
    STATUS
    "
GMP_FOUND=${GMP_FOUND}
GMP_VERSION=${GMP_VERSION}
GMP_INCLUDE_DIR=${GMP_INCLUDE_DIR}
GMP_LIBRARY=${GMP_LIBRARY}
"
)

if(NOT GMP_FOUND)
    message(FATAL_ERROR "GMP_FOUND is false after find_package(GMP REQUIRED)")
endif()

foreach(target IN ITEMS GMP::GMP)
    if(NOT TARGET ${target})
        message(FATAL_ERROR "${target} imported target was not created")
    endif()
endforeach()

if(NOT GMP_VERSION)
    message(FATAL_ERROR "GMP_VERSION could not be parsed from the GMP headers")
endif()

get_target_property(target_include_dirs GMP::GMP INTERFACE_INCLUDE_DIRECTORIES)
if(NOT target_include_dirs)
    message(FATAL_ERROR "GMP::GMP does not expose INTERFACE_INCLUDE_DIRECTORIES")
endif()
