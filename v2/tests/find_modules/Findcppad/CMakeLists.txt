cmake_minimum_required(VERSION 3.22)
project(FindcppadTest)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../find-modules")

find_package(cppad REQUIRED)

message(
    STATUS
    "
cppad_FOUND=${cppad_FOUND}
cppad_VERSION=${cppad_VERSION}
cppad_INCLUDE_DIR=${cppad_INCLUDE_DIR}
cppad_LIBRARY=${cppad_LIBRARY}
"
)

if(NOT cppad_FOUND)
    message(FATAL_ERROR "cppad_FOUND is false after find_package(cppad REQUIRED)")
endif()

foreach(target IN ITEMS cppad::cppad)
    if(NOT TARGET ${target})
        message(FATAL_ERROR "${target} imported target was not created")
    endif()
endforeach()

if(NOT cppad_VERSION)
    message(FATAL_ERROR "cppad_VERSION could not be parsed from the cppad headers")
endif()

get_target_property(target_include_dirs cppad::cppad INTERFACE_INCLUDE_DIRECTORIES)
if(NOT target_include_dirs)
    message(FATAL_ERROR "cppad::cppad does not expose INTERFACE_INCLUDE_DIRECTORIES")
endif()
