cmake_minimum_required(VERSION 3.22)
project(FindPytestTest)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../find-modules")

# Python::Interpreter is required by FindPytest.cmake before it can proceed.
# Find it with full search paths before restricting them.
find_package(Python REQUIRED COMPONENTS Interpreter)

find_package(Pytest REQUIRED)

if(NOT TARGET Pytest::Pytest)
    message(FATAL_ERROR "Pytest::Pytest imported target was not created")
endif()
