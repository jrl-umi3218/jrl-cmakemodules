cmake_minimum_required(VERSION 3.22)
project(eh-consumer)

find_package(eh-library 1.0.0 REQUIRED)

if(NOT TARGET eh-library::eh-library)
    message(FATAL_ERROR "eh-library::eh-library target not found")
endif()

get_target_property(_include_dirs eh-library::eh-library INTERFACE_INCLUDE_DIRECTORIES)
if(NOT _include_dirs)
    message(
        FATAL_ERROR
        "eh-library::eh-library does not have INTERFACE_INCLUDE_DIRECTORIES property set"
    )
endif()

message(STATUS "eh-library::eh-library include directories: ${_include_dirs}")

add_executable(check_header check_header.cpp)
target_link_libraries(check_header PRIVATE eh-library::eh-library)
install(TARGETS check_header DESTINATION bin)
