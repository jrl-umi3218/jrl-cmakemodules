cmake_minimum_required(VERSION 3.22)
project(FindPytestTest)

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)

# Python::Interpreter is required by FindPytest.cmake before it can proceed.
# Find it with full search paths before restricting them.
find_package(Python REQUIRED COMPONENTS Interpreter)

jrl_find_package(Pytest REQUIRED)

if(NOT TARGET Pytest::Pytest)
    message(FATAL_ERROR "Pytest::Pytest imported target was not created")
endif()
