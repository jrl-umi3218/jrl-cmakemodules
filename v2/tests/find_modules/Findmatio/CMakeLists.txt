cmake_minimum_required(VERSION 3.22)
project(FindmatioTest)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../find-modules")

find_package(matio REQUIRED)

if(NOT TARGET matio::matio)
    message(FATAL_ERROR "matio::matio imported target was not created")
endif()
