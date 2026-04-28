cmake_minimum_required(VERSION 3.22)
project(ExpHdr-library VERSION 1.0.0)

find_package(jrl-cmakemodules REQUIRED)

add_library(ExpHdr-library INTERFACE)
target_include_directories(
    ExpHdr-library
    INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>
)
jrl_target_headers(ExpHdr-library INTERFACE
  HEADERS
    include/expHdr/header.hpp
  BASE_DIRS
    include
)

jrl_configure_defaults()
jrl_add_export_component(NAME AllComponents TARGETS ExpHdr-library)
jrl_export_package()
