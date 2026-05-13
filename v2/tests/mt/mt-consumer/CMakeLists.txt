cmake_minimum_required(VERSION 3.22)
project(mt-consumer)

find_package(mt-library 1.0.0 REQUIRED)

add_executable(mt-consumer main.cpp)
target_link_libraries(mt-consumer PRIVATE mt-library::math mt-library::string_utils)
install(TARGETS mt-consumer DESTINATION bin)
