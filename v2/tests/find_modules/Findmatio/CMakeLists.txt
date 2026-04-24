cmake_minimum_required(VERSION 3.22)
project(FindmatioTest)

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)

jrl_find_package(matio REQUIRED)

if(NOT TARGET matio::matio)
    message(FATAL_ERROR "matio::matio imported target was not created")
endif()
