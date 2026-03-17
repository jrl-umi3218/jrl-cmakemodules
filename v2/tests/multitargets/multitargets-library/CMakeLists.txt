cmake_minimum_required(VERSION 3.22)

# Export all symbols for Windows DLLs to avoid the need for explicit __declspec(dllexport) annotations.
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

project(
    multitargets-library
    VERSION 1.0.0
    DESCRIPTION "A test project for jrl-cmakemodules"
    HOMEPAGE_URL "https://example.com/multitargets-library"
    LANGUAGES CXX
)

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)

# Configure default binary and install directories, build type, etc.
jrl_configure_defaults()

# Library 1: math
add_library(math src/Math.cpp)
target_include_directories(
    math
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>
)
target_compile_features(math PUBLIC cxx_std_17)

# Library 2: string_utils
add_library(string_utils src/StringUtils.cpp)
target_include_directories(
    string_utils
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>
)
target_compile_features(string_utils PUBLIC cxx_std_17)

# Declare headers for targets
jrl_target_headers(math PUBLIC
    HEADERS
        include/multitargets-library/Math.hpp
    BASE_DIRS
        include
)

jrl_target_headers(string_utils PUBLIC
    HEADERS
        include/multitargets-library/StringUtils.hpp
    BASE_DIRS
        include
)

# Declare export components
jrl_add_export_component(NAME multitargets-library TARGETS math string_utils)

# Export the package files (headers, targets, config files, etc.)
jrl_export_package()

# Print summaries
jrl_print_dependencies_summary()
jrl_print_options_summary()
