cmake_minimum_required(VERSION 3.22)
project(FindMPFRTest)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../find-modules")

find_package(MPFR REQUIRED)

message(
    STATUS
    "
MPFR_FOUND=${MPFR_FOUND}
MPFR_VERSION=${MPFR_VERSION}
MPFR_INCLUDE_DIR=${MPFR_INCLUDE_DIR}
MPFR_LIBRARY=${MPFR_LIBRARY}
"
)

if(NOT MPFR_FOUND)
    message(FATAL_ERROR "MPFR_FOUND is false after find_package(MPFR REQUIRED)")
endif()

foreach(target IN ITEMS MPFR::MPFR GMP::GMP)
    if(NOT TARGET ${target})
        message(FATAL_ERROR "${target} imported target was not created")
    endif()
endforeach()

if(NOT MPFR_VERSION)
    message(FATAL_ERROR "MPFR_VERSION could not be parsed from the MPFR headers")
endif()

get_target_property(target_include_dirs MPFR::MPFR INTERFACE_INCLUDE_DIRECTORIES)
if(NOT target_include_dirs)
    message(FATAL_ERROR "MPFR::MPFR does not expose INTERFACE_INCLUDE_DIRECTORIES")
endif()
