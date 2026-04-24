cmake_minimum_required(VERSION 3.22)
project(FindAccelerateTest)

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    message(STATUS "Accelerate is only available on macOS, skipping test")
    return()
endif()

jrl_find_package(Accelerate REQUIRED)

if(NOT TARGET Accelerate::Accelerate)
    message(FATAL_ERROR "Accelerate::Accelerate imported target was not created")
endif()
