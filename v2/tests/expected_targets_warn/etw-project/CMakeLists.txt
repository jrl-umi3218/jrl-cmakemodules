cmake_minimum_required(VERSION 3.22)

project(expected_targets_warn VERSION 1.0.0)

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)
jrl_configure_defaults()

# Provide a local package with two imported targets.
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Intentionally omit EXPECTED_TARGETS: jrl_export_package() should emit a single
# warning that aggregates both missing targets.
jrl_find_package(Dummy REQUIRED)

# Here we forget to import Dummy::B, so we expect a warning about the missing target.
jrl_find_package(Yummy REQUIRED EXPECTED_TARGETS Yummy::A)

add_library(t INTERFACE)
target_link_libraries(t INTERFACE Dummy::A Dummy::B Yummy::A Yummy::B)

jrl_add_export_component(NAME t TARGETS t)
jrl_export_package()
