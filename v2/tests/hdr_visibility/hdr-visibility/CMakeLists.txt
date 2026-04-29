cmake_minimum_required(VERSION 3.22)
project(hdr-visibility VERSION 1.0.0)

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
