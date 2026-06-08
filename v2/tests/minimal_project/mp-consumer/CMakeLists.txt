cmake_minimum_required(VERSION 3.22)
project(mp-consumer)

find_package(mp-library 1.0.0 REQUIRED)

if(NOT TARGET mp-library::mp-library)
    message(FATAL_ERROR "mp-library::mp-library target not found")
endif()
install(CODE "message(STATUS \"Found target: mp-library::mp-library\")")
