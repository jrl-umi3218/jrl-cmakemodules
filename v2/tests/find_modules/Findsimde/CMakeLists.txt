cmake_minimum_required(VERSION 3.22)
project(FindsimdeTest)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../find-modules")

find_package(simde REQUIRED)

if(NOT TARGET simde::simde)
    message(FATAL_ERROR "simde::simde imported target was not created")
endif()
