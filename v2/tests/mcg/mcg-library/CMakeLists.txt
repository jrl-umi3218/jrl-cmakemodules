cmake_minimum_required(VERSION 3.22)

project(
    mcg-library
    VERSION 1.0.0
    DESCRIPTION "A test project for jrl-cmakemodules (multi-component-with-generator-expressions)"
    HOMEPAGE_URL "https://example.com/mcg-library"
    LANGUAGES CXX
)

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)
jrl_configure_defaults()

jrl_option(MCG_BUILD_WITH_EXTRA "Build with something" ON)

add_library(a INTERFACE)
jrl_target_headers(a INTERFACE
    HEADERS
        $<$<BOOL:ON>:include/mcg-library/Base/a.hpp>
        $<$<BOOL:OFF>:that-header-will-not-be-installed.hpp>
    BASE_DIRS
        include
)

add_library(b INTERFACE)

add_library(c INTERFACE)
target_include_directories(
    c
    INTERFACE
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<$<BOOL:OFF>:that-include-dir-does-not-exist>
)
target_link_libraries(
    c
    INTERFACE
        # Follwing lines are equivalent to just set 'a'.
        # This is just for the exercice.
        $<BUILD_INTERFACE:$<$<BOOL:ON>:a>>
        $<INSTALL_INTERFACE:mcg-library::a>
        $<$<BOOL:OFF>:that-library-does-not-exist>
)
jrl_target_headers(c INTERFACE
    HEADERS
        $<$<BOOL:${MCG_BUILD_WITH_EXTRA}>:include/mcg-library/Extra/c.hpp>
        $<$<BOOL:OFF>:that-header-does-not-exist.hpp>
    BASE_DIRS
        include
)
target_compile_definitions(
    c
    INTERFACE
        $<$<BOOL:${MCG_BUILD_WITH_EXTRA}>:MCG_HAS_EXTRA>
        $<$<BOOL:OFF>:that-compile-definition-will-not-be-defined>
)

add_library(d INTERFACE)
target_link_libraries(d INTERFACE b)

jrl_add_export_component(NAME Base TARGETS a)
jrl_add_export_component(NAME Extra TARGETS b c d)
jrl_export_package()
