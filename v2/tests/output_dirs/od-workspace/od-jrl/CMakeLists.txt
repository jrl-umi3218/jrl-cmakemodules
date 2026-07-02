cmake_minimum_required(VERSION 3.22)
project(od-jrl VERSION 1.0.0 LANGUAGES CXX)

find_package(jrl-cmakemodules REQUIRED)

jrl_configure_defaults()

add_library(od_fakelib_jrl STATIC src/fake.cpp)

# Explicit per-target override must win over jrl_configure_defaults()'s default.
# Plain set_target_properties(RUNTIME_OUTPUT_DIRECTORY ...) is not enough here:
# jrl_configure_defaults() also seeds the per-config properties (e.g.
# RUNTIME_OUTPUT_DIRECTORY_RELEASE), which take precedence over the base one.
# jrl_target_set_output_directory() overrides all of them at once.
add_library(od_fakelib_jrl_explicit MODULE src/fake_explicit.cpp)
jrl_target_set_output_directory(
    od_fakelib_jrl_explicit
    OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bindings/python/${PROJECT_NAME}"
)
