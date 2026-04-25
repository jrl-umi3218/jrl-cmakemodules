cmake_minimum_required(VERSION 3.22)

project(
    pb-library
    VERSION 1.0.0
    DESCRIPTION "A test project for jrl-cmakemodules"
    HOMEPAGE_URL "https://example.com/pb-library"
    LANGUAGES CXX
)

# Require macOS >=11.0 SDK on Intel (fixes build issues on macos-15-intel)
# ref: https://github.com/wjakob/nanobind_example/blob/master/pyproject.toml#L43
if(APPLE AND CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0" CACHE STRING "Minimum macOS version" FORCE)
endif()

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)
# Configure default binary and install directories, build type, etc.
jrl_configure_defaults()

# Declare options
jrl_option(PB_BUILD_PYTHON_BINDINGS "Build Python bindings" ON)
jrl_option(PB_BUILD_TESTS "Build tests" ON)

# Find dependencies
if(PB_BUILD_PYTHON_BINDINGS)
    # nanobind (Python bindings)
    # NOTE: We have to keep the FetchContent support because:
    # - Ubuntu 24.04 ships an incompatible 1.9.2 version of nanobind via apt-get.
    # - Ubuntu 22.04 does not ship nanobind at all via apt-get.

    jrl_find_python(3.10 REQUIRED COMPONENTS Interpreter Development.Module)
    jrl_find_nanobind(2.5.0 CONFIG QUIET)
    if(NOT nanobind_FOUND)
        message(
            WARNING
            "[${PROJECT_NAME}] nanobind library not found. Falling back to FetchContent to get nanobind v2.11.0"
        )
        include(FetchContent)
        FetchContent_Declare(
            nanobind
            GIT_REPOSITORY https://github.com/wjakob/nanobind.git
            GIT_TAG v2.11.0
            EXCLUDE_FROM_ALL
        )
        FetchContent_MakeAvailable(nanobind)
    endif()

    jrl_find_python(3.10 REQUIRED COMPONENTS Development.Module NumPy)
    jrl_find_package(Boost CONFIG REQUIRED COMPONENTS python)
endif()

if(PB_BUILD_PYTHON_BINDINGS AND PB_BUILD_TESTS)
    jrl_find_package(Pytest REQUIRED)
endif()

if(PB_BUILD_TESTS)
    jrl_find_package(Catch2 3.0 CONFIG QUIET)
    if(Catch2_FOUND)
        message(STATUS "[${PROJECT_NAME}] Found Catch2: ${Catch2_DIR}")
        include(Catch)
    else()
        set(catch2_URL https://github.com/catchorg/Catch2/archive/refs/tags/v3.12.0.zip)
        set(catch2_URL_HASH MD5=f04aa334408d47e37aac534e34d1c861)
        message(STATUS "[${PROJECT_NAME}] Catch2 not found, fetching from ${catch2_URL}")
        include(FetchContent)
        FetchContent_Declare(catch2 URL ${catch2_URL} URL_HASH ${catch2_URL_HASH} EXCLUDE_FROM_ALL)
        FetchContent_MakeAvailable(catch2)
        include(${catch2_SOURCE_DIR}/extras/Catch.cmake)
    endif()
endif()

# Create libraries
add_library(pb SHARED)
target_sources(pb PRIVATE src/Math.cpp src/StringUtils.cpp)
target_include_directories(
    pb
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>
)
target_compile_features(pb PUBLIC cxx_std_17)

# Set compile options
jrl_target_set_default_compile_options(pb PRIVATE)
jrl_target_enforce_msvc_conformance(pb PRIVATE)
jrl_target_treat_all_warnings_as_errors(pb PRIVATE)

# Generate utility headers
set_target_properties(pb PROPERTIES VERSION ${PROJECT_VERSION})
jrl_target_generate_config_header(pb PUBLIC)
jrl_target_generate_warning_header(pb PUBLIC)
jrl_target_generate_deprecated_header(pb PUBLIC)

# Python bindings
if(PB_BUILD_PYTHON_BINDINGS)
    message(STATUS "[${PROJECT_NAME}] Building Python bindings")
    add_subdirectory(bindings/nanobind-bindings)
    add_subdirectory(bindings/boostpy-bindings)
endif()

# Tests
if(PB_BUILD_TESTS)
    message(STATUS "[${PROJECT_NAME}] Building tests")
    enable_testing()
    add_subdirectory(tests)
endif()

# Declare headers for target
jrl_target_headers(pb PUBLIC
    HEADERS
        include/pb/Math.hpp
    BASE_DIRS
        include
)

# Declare export components
jrl_add_export_component(NAME pb TARGETS pb)

# Export the package files (headers, targets, config files, etc.)
jrl_export_package()

# Print summaries
jrl_print_dependencies_summary()
jrl_print_options_summary()
