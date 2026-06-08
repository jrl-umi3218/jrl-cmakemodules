cmake_minimum_required(VERSION 3.22)
project(eh-library VERSION 1.0.0)

find_package(jrl-cmakemodules REQUIRED)

add_library(eh-library INTERFACE)
target_include_directories(
    eh-library
    INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>
)
jrl_target_headers(eh-library INTERFACE
  HEADERS
    include/eh/header.hpp
  BASE_DIRS
    include
)

jrl_configure_defaults()
jrl_add_export_component(NAME AllComponents TARGETS eh-library)
jrl_export_package()
