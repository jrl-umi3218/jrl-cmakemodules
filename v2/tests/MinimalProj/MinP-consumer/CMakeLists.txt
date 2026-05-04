cmake_minimum_required(VERSION 3.22)
project(MinP-consumer)

find_package(MinP-library 1.0.0 REQUIRED)

if(NOT TARGET MinP-library::MinP-library)
    message(FATAL_ERROR "MinP-library::MinP-library target not found")
endif()
install(CODE "message(STATUS \"Found target: MinP-library::MinP-library\")")
