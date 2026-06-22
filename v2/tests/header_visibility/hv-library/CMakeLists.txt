cmake_minimum_required(VERSION 3.22)
project(hv-library VERSION 1.0.0)

find_package(jrl-cmakemodules REQUIRED)

jrl_configure_defaults()

add_library(mylib INTERFACE)

# INTERFACE headers: should be installed
jrl_target_headers(mylib INTERFACE
    HEADERS
        include/mylib/public_header.hpp
    BASE_DIRS
        include
)

# PRIVATE headers: should NOT be installed
jrl_target_headers(mylib PRIVATE
    HEADERS
        include/mylib/private_header.hpp
    BASE_DIRS
        include
)

jrl_add_export_component(NAME AllComponents TARGETS mylib)
jrl_export_package()

########## TESTS ##########

if(NOT DEFINED CMAKE_INSTALL_PREFIX)
    message(FATAL_ERROR "CMAKE_INSTALL_PREFIX must be defined for the tests to work")
endif()

jrl_include_ctest()
enable_testing()

# Check that the INTERFACE header is installed
add_test(
    NAME "header_visibility: INTERFACE header is installed"
    COMMAND ${CMAKE_COMMAND} -E cat "${CMAKE_INSTALL_PREFIX}/include/mylib/public_header.hpp"
)

# Check that the PRIVATE header is NOT installed
add_test(
    NAME "header_visibility: PRIVATE header is not installed"
    COMMAND ${CMAKE_COMMAND} -E cat "${CMAKE_INSTALL_PREFIX}/include/mylib/private_header.hpp"
)
set_tests_properties("header_visibility: PRIVATE header is not installed" PROPERTIES WILL_FAIL TRUE)
