cmake_minimum_required(VERSION 3.22)
project(multitargets-consumer)

find_package(multitargets-library 1.0.0 REQUIRED)

add_executable(multitargets-consumer main.cpp)
target_link_libraries(
    multitargets-consumer
    PRIVATE multitargets-library::math multitargets-library::string_utils
)
