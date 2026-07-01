cmake_minimum_required(VERSION 3.22)
project(thr-library VERSION 1.0.0)

find_package(jrl-cmakemodules REQUIRED)

jrl_configure_defaults()

# Define an interface library target
add_library(mylib INTERFACE)
target_include_directories(
    mylib
    INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/my_subdir> $<INSTALL_INTERFACE:include>
)

# Add the subdirectory where target headers are defined with relative paths
add_subdirectory(my_subdir)

jrl_add_export_component(NAME AllComponents TARGETS mylib)
jrl_export_package()
