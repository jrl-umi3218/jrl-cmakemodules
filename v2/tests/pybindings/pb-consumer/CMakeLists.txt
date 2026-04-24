cmake_minimum_required(VERSION 3.22)
project(pb-consumer)

find_package(pb-library REQUIRED)

if(NOT TARGET pb-library::pb)
    message(FATAL_ERROR "pb-library::pb target not found")
endif()

add_executable(pb-consumer main.cpp)
target_link_libraries(pb-consumer PRIVATE pb-library::pb)
install(TARGETS pb-consumer RUNTIME DESTINATION bin LIBRARY DESTINATION lib ARCHIVE DESTINATION lib)

# Python binding tests
find_package(Python 3.10 REQUIRED COMPONENTS Interpreter)

enable_testing()
add_test(
    NAME "Python Bindings Consumer Test"
    COMMAND
        $<TARGET_FILE:Python::Interpreter>
        ${CMAKE_CURRENT_SOURCE_DIR}/tests/test_pybindings_consumer.py
)
