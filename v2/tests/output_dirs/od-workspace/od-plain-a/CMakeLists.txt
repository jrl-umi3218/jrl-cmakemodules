cmake_minimum_required(VERSION 3.22)
project(od-plain-a VERSION 1.0.0 LANGUAGES CXX)

# Plain CMake, no jrl-cmakemodules.
add_library(od_fakelib_plain_a STATIC src/fake.cpp)

# Explicit per-target override, independent of any jrl default.
# This mimics a python binding extension.
add_library(od_fakelib_plain_explicit MODULE src/fake_explicit.cpp)
set_target_properties(
    od_fakelib_plain_explicit
    PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bindings/python/${PROJECT_NAME}"
        LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bindings/python/${PROJECT_NAME}"
)
