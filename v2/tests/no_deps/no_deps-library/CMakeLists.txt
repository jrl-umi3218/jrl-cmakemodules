cmake_minimum_required(VERSION 3.22)

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

project(no_deps-library VERSION 1.0.0 LANGUAGES CXX)

find_package(jrl-cmakemodules CONFIG REQUIRED)
jrl_configure_defaults()

add_library(mylib src/mylib.cpp)
jrl_target_enforce_msvc_conformance(mylib PRIVATE)
target_include_directories(
    mylib
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>
)

jrl_target_headers(mylib PUBLIC
    HEADERS
        include/no_deps-library/mylib.hpp
    BASE_DIRS
        include
)

jrl_add_export_component(NAME mycomponent TARGETS mylib)
jrl_export_package()
