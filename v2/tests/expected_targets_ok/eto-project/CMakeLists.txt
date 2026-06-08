cmake_minimum_required(VERSION 3.22)

project(expected_targets_ok VERSION 1.0.0)

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)
jrl_configure_defaults()

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# EXPECTED_TARGETS specified and all present: no warning should be emitted.
jrl_find_package(Dummy REQUIRED EXPECTED_TARGETS Dummy::A Dummy::B)

add_library(t INTERFACE)
target_link_libraries(t INTERFACE Dummy::A Dummy::B)

jrl_add_export_component(NAME t TARGETS t)
jrl_export_package()
