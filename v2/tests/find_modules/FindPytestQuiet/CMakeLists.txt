cmake_minimum_required(VERSION 3.22)
project(FindPytestQuietTest)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../find-modules")

# Python::Interpreter is required by FindPytest.cmake before it can proceed.
# Find it with full search paths before restricting them.
find_package(Python REQUIRED COMPONENTS Interpreter)

# Restrict search paths to ensure Pytest is not found on the system.
set(CMAKE_FIND_USE_CMAKE_SYSTEM_PATH false)
set(CMAKE_FIND_USE_CMAKE_PATH false)
set(CMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH false)
set(CMAKE_FIND_USE_INSTALL_PREFIX false)
set(CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH false)
set(CMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY false)
set(CMAKE_FIND_USE_PACKAGE_REGISTRY false)
set(CMAKE_FIND_USE_PACKAGE_ROOT_PATH false)

# Clear any cached result from a previous run to ensure a fresh search.
unset(Pytest_EXECUTABLE CACHE)

find_package(Pytest QUIET)

message(
    STATUS
    "
Pytest_EXECUTABLE=${Pytest_EXECUTABLE}
Pytest_FOUND=${Pytest_FOUND}
"
)

if(Pytest_FOUND)
    message(FATAL_ERROR "Pytest_FOUND should be FALSE when no search paths are available")
endif()
