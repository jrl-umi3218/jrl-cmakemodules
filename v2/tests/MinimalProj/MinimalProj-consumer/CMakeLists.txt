cmake_minimum_required(VERSION 3.22)
project(MinimalProj-consumer)

find_package(MinimalProj-library 1.0.0 REQUIRED)

if(NOT TARGET MinimalProj-library::MinimalProj-library)
    message(FATAL_ERROR "MinimalProj-library::MinimalProj-library target not found")
endif()
