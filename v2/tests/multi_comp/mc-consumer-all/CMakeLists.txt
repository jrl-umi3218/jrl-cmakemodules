cmake_minimum_required(VERSION 3.22)
project(mc-consumer-all)

# Not specifying components will import them all
find_package(mc-library 1.0.0 REQUIRED)

add_executable(mc-consumer-all main.cpp)
target_link_libraries(
    mc-consumer-all
    PRIVATE mc-library::base_math mc-library::extra_utils mc-library::extra_formatter
)
install(TARGETS mc-consumer-all DESTINATION bin)
