cmake_minimum_required(VERSION 3.22)
project(CamelCase-consumer)

find_package(CamelCase-library 1.0.0 REQUIRED)

if(NOT TARGET CamelCase-library::CamelCase-library)
    message(FATAL_ERROR "CamelCase-library::CamelCase-library target not found")
endif()
install(CODE "message(STATUS \"Found target: CamelCase-library::CamelCase-library\")")
