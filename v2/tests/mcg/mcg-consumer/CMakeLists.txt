cmake_minimum_required(VERSION 3.22)
project(mcg-consumer)

find_package(mcg-library REQUIRED)

if(NOT TARGET mcg-library::a)
    message(FATAL_ERROR "mcg-library::a target not found")
endif()

if(NOT TARGET mcg-library::b)
    message(FATAL_ERROR "mcg-library::b target not found")
endif()

if(NOT TARGET mcg-library::c)
    message(FATAL_ERROR "mcg-library::c target not found")
endif()

if(NOT TARGET mcg-library::d)
    message(FATAL_ERROR "mcg-library::d target not found")
endif()

add_executable(mcg-consumer main.cpp)
target_link_libraries(mcg-consumer PRIVATE mcg-library::c mcg-library::d)
