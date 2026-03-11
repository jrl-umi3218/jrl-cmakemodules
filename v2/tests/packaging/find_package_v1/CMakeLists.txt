cmake_minimum_required(VERSION 3.22)

set(PROJECT_NAME jrl-cmakemodules-find-package-test-v1)
set(PROJECT_DESCRIPTION "A project description")
set(PROJECT_URL http://jrl-cmakemodules.readthedocs.io)

# This should work for v1 and v2
find_package(jrl-cmakemodules CONFIG REQUIRED)

project(${PROJECT_NAME} VERSION 1.0.0 LANGUAGES CXX)

get_property(
    JRL_CMAKE_MODULES
    TARGET jrl-cmakemodules::jrl-cmakemodules
    PROPERTY INTERFACE_INCLUDE_DIRECTORIES
)
message(STATUS "JRL cmakemodules found on system at ${JRL_CMAKE_MODULES}")

include("${JRL_CMAKE_MODULES}/base.cmake")
