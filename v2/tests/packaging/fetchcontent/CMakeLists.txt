cmake_minimum_required(VERSION 3.22)

project(myproj VERSION 1.2.3 LANGUAGES CXX)

# TODO: Find a portable way to specify this
set(JRL_CMAKEMODULES_FETCHCONTENT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../../..)

if(NOT DEFINED JRL_CMAKEMODULES_FETCHCONTENT_SOURCE_DIR)
    message(FATAL_ERROR "JRL_CMAKEMODULES_FETCHCONTENT_SOURCE_DIR is not defined")
endif()

cmake_path(
    CONVERT "${JRL_CMAKEMODULES_FETCHCONTENT_SOURCE_DIR}"
    TO_CMAKE_PATH_LIST JRL_CMAKEMODULES_FETCHCONTENT_SOURCE_DIR
    NORMALIZE
)
message(
    STATUS
    "JRL_CMAKEMODULES_FETCHCONTENT_SOURCE_DIR: ${JRL_CMAKEMODULES_FETCHCONTENT_SOURCE_DIR}"
)

include(FetchContent)
set(JRL_CMAKEMODULES_USE_V2 ON CACHE BOOL "" FORCE)
FetchContent_Declare(jrl-cmakemodules SOURCE_DIR ${JRL_CMAKEMODULES_FETCHCONTENT_SOURCE_DIR})
FetchContent_MakeAvailable(jrl-cmakemodules)

# (recommended) Configure defaults (output dirs, install prefix, etc.)
jrl_configure_defaults()

# Create your libraries as usual
add_library(mylib src/mylib.cpp)
jrl_target_enforce_msvc_conformance(mylib PRIVATE) # recommded to enhance uniformity accross compilers
target_include_directories(
    mylib
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>
)

# Declare the headers
# They will be automatically installed with jrl_export_package()
jrl_target_headers(mylib PUBLIC
    HEADERS
        include/myproj/mylib.hpp
    BASE_DIRS
        include
)

# Declare the components
jrl_add_export_component(
    NAME mycomponent
    TARGETS mylib
)

# Export the package configuration (create <pkg>-config.cmake, install targets etc)
jrl_export_package()
