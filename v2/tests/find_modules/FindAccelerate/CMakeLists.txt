cmake_minimum_required(VERSION 3.22)
project(FindAccelerateTest)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../find-modules")

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    message(STATUS "Accelerate is only available on macOS, skipping test")
    return()
endif()

find_package(Accelerate REQUIRED)

if(NOT TARGET Accelerate::Accelerate)
    message(FATAL_ERROR "Accelerate::Accelerate imported target was not created")
endif()
