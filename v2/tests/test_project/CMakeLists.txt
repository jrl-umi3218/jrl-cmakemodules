cmake_minimum_required(VERSION 3.22...4.1)

find_package(jrl-cmakemodules CONFIG REQUIRED)

project(
    test_project
    VERSION 1.0.0
    DESCRIPTION "A test project for jrl-cmakemodules"
    HOMEPAGE_URL "https://example.com/test_project"
    LANGUAGES CXX
)

# Configure default binary and install directories, build type, etc.
jrl_configure_defaults()

# Declare options
jrl_option(TEST_PROJECT_BUILD_PYTHON_BINDINGS "Build Python bindings" ON)
jrl_option(TEST_PROJECT_BUILD_TESTS "Build tests" ON)

# Find dependencies
if(TEST_PROJECT_BUILD_PYTHON_BINDINGS)
    jrl_find_python(3.8 REQUIRED COMPONENTS Interpreter Development.Module)
    jrl_find_nanobind(2.4.0 CONFIG REQUIRED)

    jrl_find_python(3.8 REQUIRED COMPONENTS Development.Module NumPy)
    jrl_find_package(Boost CONFIG REQUIRED COMPONENTS python)
endif()

if(TEST_PROJECT_BUILD_PYTHON_BINDINGS AND TEST_PROJECT_BUILD_TESTS)
    jrl_find_package(Pytest 8.0.0 REQUIRED)
endif()

if(TEST_PROJECT_BUILD_TESTS)
    jrl_find_package(Catch2 3.4.0 CONFIG REQUIRED)
    include(Catch)
endif()

# Create libraries
add_library(test_project SHARED)
target_sources(test_project PRIVATE src/Math.cpp src/StringUtils.cpp)
target_include_directories(
    test_project
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>
)
target_compile_features(test_project PUBLIC cxx_std_17)

# Set compile options
jrl_target_set_default_compile_options(test_project PRIVATE)
jrl_target_enforce_msvc_conformance(test_project PRIVATE)
jrl_target_treat_all_warnings_as_errors(test_project PRIVATE)

# Generate utility headers
set_target_properties(test_project PROPERTIES VERSION ${PROJECT_VERSION})
jrl_target_generate_config_header(test_project PUBLIC)
jrl_target_generate_warning_header(test_project PUBLIC)
jrl_target_generate_deprecated_header(test_project PUBLIC)

# Python bindings
if(TEST_PROJECT_BUILD_PYTHON_BINDINGS)
    message(STATUS "[${PROJECT_NAME}] Building Python bindings")
    add_subdirectory(bindings/nanobind-bindings)
    add_subdirectory(bindings/boostpy-bindings)
endif()

# Tests
if(TEST_PROJECT_BUILD_TESTS)
    message(STATUS "[${PROJECT_NAME}] Building tests")
    enable_testing()
    add_subdirectory(tests)
endif()

# Declare headers for target
jrl_target_headers(test_project PUBLIC
    HEADERS
        include/test_project/Math.hpp
    BASE_DIRS
        include
)

# Declare export components
jrl_add_export_component(NAME test_project TARGETS test_project)

# Export the package files (headers, targets, config files, etc.)
jrl_export_package()

# Print summaries
jrl_print_dependencies_summary()
jrl_print_options_summary()
