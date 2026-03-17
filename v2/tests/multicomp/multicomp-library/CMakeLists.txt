cmake_minimum_required(VERSION 3.22)

# Export all symbols for Windows DLLs to avoid the need for explicit __declspec(dllexport) annotations.
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

project(
    multicomp-library
    VERSION 1.0.0
    DESCRIPTION "A test project for jrl-cmakemodules (multi-component)"
    HOMEPAGE_URL "https://example.com/multicomp-library"
    LANGUAGES CXX
)

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)

# Configure default binary and install directories, build type, etc.
jrl_configure_defaults()

# Component "base": base_math target
add_library(base_math src/BaseMath.cpp)
target_include_directories(
    base_math
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>
)
target_compile_features(base_math PUBLIC cxx_std_17)

# Component "extra": extra_utils target
add_library(extra_utils src/ExtraUtils.cpp)
target_include_directories(
    extra_utils
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>
)
target_compile_features(extra_utils PUBLIC cxx_std_17)

# Component "extra": extra_formatter target
add_library(extra_formatter src/ExtraFormatter.cpp)
target_include_directories(
    extra_formatter
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>
)
target_compile_features(extra_formatter PUBLIC cxx_std_17)

# Declare headers for targets
jrl_target_headers(base_math PUBLIC
    HEADERS
        include/multicomp-library/BaseMath.hpp
    BASE_DIRS
        include
)

jrl_target_headers(extra_utils PUBLIC
    HEADERS
        include/multicomp-library/ExtraUtils.hpp
    BASE_DIRS
        include
)

jrl_target_headers(extra_formatter PUBLIC
    HEADERS
        include/multicomp-library/ExtraFormatter.hpp
    BASE_DIRS
        include
)

# Declare export components (one call per component)
jrl_add_export_component(NAME base TARGETS base_math)
jrl_add_export_component(NAME extra TARGETS extra_utils extra_formatter)

# Export the package files (headers, targets, config files, etc.)
jrl_export_package()

# Print summaries
jrl_print_dependencies_summary()
jrl_print_options_summary()
