cmake_minimum_required(VERSION 3.22)
project(multicomp-consumer)

find_package(multicomp-library 1.0.0 REQUIRED COMPONENTS base extra)

add_executable(multicomp-consumer main.cpp)
target_link_libraries(
    multicomp-consumer
    PRIVATE
        multicomp-library::base_math
        multicomp-library::extra_utils
        multicomp-library::extra_formatter
)
install(TARGETS multicomp-consumer DESTINATION bin)
