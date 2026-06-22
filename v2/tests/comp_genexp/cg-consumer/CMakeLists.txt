cmake_minimum_required(VERSION 3.22)
project(cg-consumer)

find_package(cg-library REQUIRED)

if(NOT TARGET cg-library::a)
    message(FATAL_ERROR "cg-library::a target not found")
endif()

if(NOT TARGET cg-library::b)
    message(FATAL_ERROR "cg-library::b target not found")
endif()

if(NOT TARGET cg-library::c)
    message(FATAL_ERROR "cg-library::c target not found")
endif()

if(NOT TARGET cg-library::d)
    message(FATAL_ERROR "cg-library::d target not found")
endif()

add_executable(cg-consumer main.cpp)
target_link_libraries(cg-consumer PRIVATE cg-library::c cg-library::d)
install(TARGETS cg-consumer RUNTIME DESTINATION bin LIBRARY DESTINATION lib ARCHIVE DESTINATION lib)
