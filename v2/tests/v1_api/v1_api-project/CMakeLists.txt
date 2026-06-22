cmake_minimum_required(VERSION 3.22)

set(PROJECT_NAME v1_api-project)
set(PROJECT_DESCRIPTION "A project description")
set(PROJECT_URL http://jrl-cmakemodules.readthedocs.io)

# Load the old v1 API
find_package(jrl-cmakemodules REQUIRED)

if(NOT TARGET jrl-cmakemodules::jrl-cmakemodules)
    message(
        FATAL_ERROR
        "jrl-cmakemodules::jrl-cmakemodules target not defined by jrl-cmakemodules v1"
    )
endif()

get_property(
    JRL_CMAKEMODULES
    TARGET jrl-cmakemodules::jrl-cmakemodules
    PROPERTY INTERFACE_INCLUDE_DIRECTORIES
)

if(NOT DEFINED JRL_CMAKEMODULES)
    message(
        FATAL_ERROR
        "The INTERFACE_INCLUDE_DIRECTORIES property of jrl-cmakemodules::jrl-cmakemodules is not defined"
    )
endif()

message(STATUS "JRL CMake Modules v1 found on system at ${JRL_CMAKEMODULES}")
include("${JRL_CMAKEMODULES}/base.cmake")

project(${PROJECT_NAME} VERSION 1.0.0 LANGUAGES CXX)
