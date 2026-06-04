cmake_minimum_required(VERSION 3.22)

project(expected_targets_ok VERSION 1.0.0)

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)
jrl_configure_defaults()

# EXPECTED_TARGETS specified, so no warning should be printed
jrl_find_package(Eigen3 CONFIG REQUIRED EXPECTED_TARGETS Eigen3::Eigen)

add_library(t INTERFACE)
target_link_libraries(t INTERFACE Eigen3::Eigen)

jrl_add_export_component(NAME t TARGETS t)
jrl_export_package()
