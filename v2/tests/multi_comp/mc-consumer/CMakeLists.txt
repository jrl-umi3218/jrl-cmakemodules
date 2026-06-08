cmake_minimum_required(VERSION 3.22)
project(mc-consumer)

find_package(mc-library 1.0.0 REQUIRED COMPONENTS base extra)

add_executable(mc-consumer main.cpp)
target_link_libraries(
    mc-consumer
    PRIVATE mc-library::base_math mc-library::extra_utils mc-library::extra_formatter
)
install(TARGETS mc-consumer DESTINATION bin)
