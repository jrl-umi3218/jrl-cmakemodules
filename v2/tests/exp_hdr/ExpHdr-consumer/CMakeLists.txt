cmake_minimum_required(VERSION 3.22)
project(ExpHdr-consumer)

find_package(ExpHdr-library 1.0.0 REQUIRED)

if(NOT TARGET ExpHdr-library::ExpHdr-library)
    message(FATAL_ERROR "ExpHdr-library::ExpHdr-library target not found")
endif()

get_target_property(_include_dirs ExpHdr-library::ExpHdr-library INTERFACE_INCLUDE_DIRECTORIES)
if(NOT _include_dirs)
    message(
        FATAL_ERROR
        "ExpHdr-library::ExpHdr-library does not have INTERFACE_INCLUDE_DIRECTORIES property set"
    )
endif()

message(STATUS "ExpHdr-library::ExpHdr-library include directories: ${_include_dirs}")

add_executable(check_header check_header.cpp)
target_link_libraries(check_header PRIVATE ExpHdr-library::ExpHdr-library)
install(TARGETS check_header DESTINATION bin)
