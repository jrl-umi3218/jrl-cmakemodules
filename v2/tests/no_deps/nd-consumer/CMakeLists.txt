cmake_minimum_required(VERSION 3.22)
project(nd-consumer)

find_package(nd-library REQUIRED)

if(NOT TARGET nd-library::mylib)
    message(FATAL_ERROR "nd-library::mylib target not found")
endif()

add_executable(nd-consumer main.cpp)
target_link_libraries(nd-consumer PRIVATE nd-library::mylib)
install(TARGETS nd-consumer DESTINATION bin)
