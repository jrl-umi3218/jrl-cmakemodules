cmake_minimum_required(VERSION 3.22)

# The project above is importing Eigen
find_package(Eigen3 CONFIG REQUIRED)

project(expected_targets_skip VERSION 1.0.0)

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)
jrl_configure_defaults()

# EXPECTED_TARGETS specified, find_package should be skipped
jrl_find_package(Eigen3 CONFIG REQUIRED EXPECTED_TARGETS Eigen3::Eigen)

add_library(t INTERFACE)
target_link_libraries(t INTERFACE Eigen3::Eigen)

# Also we make sure that the export still works with the "simulated" import ot Eigen3::Eigen
jrl_add_export_component(NAME t TARGETS t)
jrl_export_package()
