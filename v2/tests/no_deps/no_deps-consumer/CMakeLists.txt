cmake_minimum_required(VERSION 3.22)
project(no_deps-consumer)

find_package(no_deps-library REQUIRED)

if(NOT TARGET no_deps-library::mylib)
    message(FATAL_ERROR "no_deps-library::mylib target not found")
endif()

add_executable(no_deps-consumer main.cpp)
target_link_libraries(no_deps-consumer PRIVATE no_deps-library::mylib)
install(TARGETS no_deps-consumer DESTINATION bin)
