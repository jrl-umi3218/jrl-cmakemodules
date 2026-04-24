cmake_minimum_required(VERSION 3.22)
project(multicomp-consumer-all)

# Not specifying components will import them all
find_package(multicomp-library 1.0.0 REQUIRED)

add_executable(multicomp-consumer-all main.cpp)
target_link_libraries(
    multicomp-consumer-all
    PRIVATE
        multicomp-library::base_math
        multicomp-library::extra_utils
        multicomp-library::extra_formatter
)
install(TARGETS multicomp-consumer-all DESTINATION bin)
