cmake_minimum_required(VERSION 3.22)
project(FindsimdeTest)

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)

jrl_find_package(simde REQUIRED)

if(NOT TARGET simde::simde)
    message(FATAL_ERROR "simde::simde imported target was not created")
endif()
