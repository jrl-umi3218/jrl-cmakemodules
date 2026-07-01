cmake_minimum_required(VERSION 3.22)
project(thr-consumer LANGUAGES CXX)

find_package(thr-library 1.0.0 REQUIRED)

if(NOT TARGET thr-library::mylib)
    message(FATAL_ERROR "thr-library::mylib target not found")
endif()

add_executable(consumer_exe main.cpp)
target_link_libraries(consumer_exe PRIVATE thr-library::mylib)

install(TARGETS consumer_exe DESTINATION bin)
