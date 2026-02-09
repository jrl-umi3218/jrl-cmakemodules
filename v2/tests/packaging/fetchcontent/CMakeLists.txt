cmake_minimum_required(VERSION 3.22)

include(FetchContent)
FetchContent_Declare(
    jrl-cmakemodules-v2
    GIT_REPOSITORY https://github.com/ahoarau/jrl-cmakemodules-v2.git
    GIT_TAG main
    GIT_SHALLOW True
)
FetchContent_MakeAvailable(jrl-cmakemodules-v2)

project(myproj VERSION 1.2.3 LANGUAGES CXX)

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
