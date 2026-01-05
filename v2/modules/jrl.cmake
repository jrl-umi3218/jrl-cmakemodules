# Copyright 2025-2026 Inria

cmake_minimum_required(VERSION 3.22)

# Usage: jrl_check_var_defined(<var> [<message>])
# Example: jrl_check_var_defined(MY_VAR "MY_VAR must be set to build this project")
# Example: jrl_check_var_defined(MY_VAR) # Will print "MY_VAR is not defined."
function(jrl_check_var_defined var)
    if(NOT DEFINED ${var})
        if(ARGC EQUAL 1)
            set(msg "Required variable '${ARGV0}' is not defined.")
        else()
            set(msg "${ARGV1}")
        endif()
        message(FATAL_ERROR "${msg}")
    endif()
endfunction()

# Check if a directory exists, otherwise raise a fatal error
function(jrl_check_dir_exists dirpath)
    if(NOT IS_DIRECTORY ${dirpath})
        message(FATAL_ERROR "Directory '${dirpath}' does not exist.")
    endif()
endfunction()

# Check if a target exists, otherwise raise a fatal error
# Usage: jrl_check_target_exists(<target_name> [<message>])
# Example:
# ```cmake
# jrl_check_target_exists(Python::Interpreter)
# jrl_check_target_exists(Python::Interpreter "Call find_package(Python REQUIRED COMPONENTS Interpreter) first.")
# ```
function(jrl_check_target_exists target_name)
    if(NOT TARGET ${target_name})
        if(ARGC EQUAL 1)
            set(msg "Target '${target_name}' does not exist.")
        else()
            set(msg "${ARGV1}")
        endif()
        message(FATAL_ERROR "${msg}")
    endif()
endfunction()

# Check if a command exists, otherwise raise a fatal error
# Usage: jrl_check_command_exists(<command_name> [<message>])
# Example:
# ```cmake
# jrl_check_command_exists(nanobind_add_stubs)
# jrl_check_command_exists(nanobind_add_stubs "nanobind_add_stubs command not found. Call find_package(nanobind 2.5.0 REQUIRED) first.")
# ```
function(jrl_check_command_exists command_name)
    if(NOT COMMAND ${command_name})
        if(ARGC EQUAL 1)
            set(msg "Command '${command_name}' does not exist.")
        else()
            set(msg "${ARGV1}")
        endif()
        message(FATAL_ERROR "${msg}")
    endif()
endfunction()

# Check if the visibility argument is valid (PRIVATE, PUBLIC or INTERFACE)
# Otherwise raise a fatal error
# Usage: jrl_check_valid_visibility(<visibility>)
# Example:
# ```cmake
# set(visibility PRIVATE)
# jrl_check_valid_visibility(${visibility})
# ```
function(jrl_check_valid_visibility visibility)
    set(vs PRIVATE PUBLIC INTERFACE)
    if(NOT ${visibility} IN_LIST vs)
        message(
            FATAL_ERROR
            "visibility (${visibility}) must be one of PRIVATE, PUBLIC or INTERFACE"
        )
    endif()
endfunction()

# Check if a file exists, otherwise raise a fatal error
# Usage: jrl_check_file_exists(<filepath>)
# Example:
# ```cmake
# jrl_check_file_exists(${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt)
# ```
function(jrl_check_file_exists filepath)
    if(NOT EXISTS ${filepath})
        message(FATAL_ERROR "File '${filepath}' does not exist.")
    endif()
endfunction()

# Get the top-level directory of the jrl-cmakemodules v2 repository
# Usage: _jrl_top_dir(<output_var>)
# Example:
# ```cmake
# _jrl_top_dir(TOP_DIR)
# ```
function(_jrl_top_dir output_var)
    cmake_path(CONVERT "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.." TO_CMAKE_PATH_LIST top_dir NORMALIZE)
    jrl_check_dir_exists(${top_dir})
    set(${output_var} ${top_dir} PARENT_SCOPE)
endfunction()

# Get the templates directory of the jrl-cmakemodules v2 repository
# Usage: _jrl_templates_dir(<output_var>)
# Example:
# ```cmake
# _jrl_templates_dir(TEMPLATES_DIR)
# ```
function(_jrl_templates_dir output_var)
    _jrl_top_dir(top_dir)
    set(templates_dir ${top_dir}/templates)
    jrl_check_dir_exists(${templates_dir})
    set(${output_var} ${templates_dir} PARENT_SCOPE)
endfunction()

# Get the external-modules directory of the jrl-cmakemodules v2 repository
# Usage: _jrl_external_modules_dir(<output_var>)
# Example:
# ```cmake
# _jrl_external_modules_dir(EXTERNAL_MODULES_DIR)
# ```
function(_jrl_external_modules_dir output_var)
    _jrl_top_dir(top_dir)
    set(external_modules_dir ${top_dir}/external-modules)
    jrl_check_dir_exists(${external_modules_dir})
    set(${output_var} ${external_modules_dir} PARENT_SCOPE)
endfunction()

# Get the find-modules directory of the jrl-cmakemodules v2 repository
# Usage: _jrl_find_modules_dir(<output_var>)
# Example:
# ```cmake
# _jrl_find_modules_dir(FIND_MODULES_DIR)
# ```
function(_jrl_find_modules_dir output_var)
    _jrl_top_dir(top_dir)
    set(find_modules_dir ${top_dir}/find-modules)
    jrl_check_dir_exists(${find_modules_dir})
    set(${output_var} ${find_modules_dir} PARENT_SCOPE)
endfunction()

function(_jrl_integrate_modules)
    _jrl_external_modules_dir(external_modules_dir)

    # Adding the pytest_discover_tests function for pytest
    # repo: https://github.com/python-cmake/pytest-cmake
    include(${external_modules_dir}/pytest-cmake/PytestDiscoverTests.cmake)
    # Adding the boosttest_discover_tests function for Boost Unit Testing
    # repo: https://github.com/DenizThatMenace/cmake-modules
    include(${external_modules_dir}/boost-test/BoostTestDiscoverTests.cmake)

    # jrl_boostpy_add_module and jrl_boostpy_add_stubs
    include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/BoostPython.cmake)

    include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/PrintSystemInfo.cmake)
endfunction()

_jrl_integrate_modules()

# Copy compile_commands.json from the binary dir to the upper source directory for clangd support
# NOTE: This is only useful when the build directory is not <source_dir>/build
function(jrl_copy_compile_commands_in_source_dir)
    set(source ${CMAKE_BINARY_DIR}/compile_commands.json)
    set(destination ${CMAKE_SOURCE_DIR}/compile_commands.json)

    if(CMAKE_EXPORT_COMPILE_COMMANDS AND EXISTS ${source})
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E copy_if_different ${source} ${destination}
        )
    endif()
endfunction()

# Launch the copy at the end of the configuration step
function(jrl_configure_copy_compile_commands_in_source_dir)
    cmake_language(DEFER DIRECTORY ${CMAKE_SOURCE_DIR} GET_CALL_IDS _ids)
    set(call_id 03e6a81d-6918-4da7-a4f4-a3dd74f61cef)
    if(NOT _ids OR NOT ${call_id} IN_LIST _ids)
        message(
            DEBUG
            "Configuring copy of compile_commands.json to source directory (CMAKE_SOURCE_DIR=${CMAKE_SOURCE_DIR}) at end of configuration step."
        )
        cmake_language(
            DEFER
            ID ${call_id}
            DIRECTORY ${CMAKE_SOURCE_DIR}
            CALL jrl_copy_compile_commands_in_source_dir ()
        )
    endif()
endfunction()

# Include CTest but simply prevent adding a lot of useless targets. Useful for IDEs.
# Usage: jrl_include_ctest()
macro(jrl_include_ctest)
    set_property(GLOBAL PROPERTY CTEST_TARGETS_ADDED 1)
    include(CTest)
endmacro()

# Get the version of the jrl-cmakemodules package (via the jrl-cmakemodules_VERSION variable)
# Usage: jrl_cmakemodules_get_version(<output_var>)
# Example:
# ```cmake
# jrl_cmakemodules_get_version(v)
# message(STATUS "jrl-cmakemodules version: ${v}")
# ```
function(jrl_cmakemodules_get_version output_var)
    jrl_check_var_defined(jrl-cmakemodules_VERSION
        "jrl-cmakemodules_VERSION variable is not defined."
        "It is defined when adding the top-level jrl-cmakemodules project or when found via find_package."
    )
    set(${output_var} ${jrl-cmakemodules_VERSION} PARENT_SCOPE)
endfunction()

# Print a banner with the jrl-cmakemodules version and some info
# Usage: jrl_print_banner()
function(jrl_print_banner)
    jrl_cmakemodules_get_version(v)
    message(
        STATUS
        "
        🚧 Welcome to JRL CMake Modules v${v}.
        🚧 Loaded from: ${CMAKE_CURRENT_FUNCTION_LIST_FILE}
        🚧 This version is still under heavy development.
        🚧 API may change without notice.
    "
    )
endfunction()

# Usage: jrl_configure_default_build_type(<build_type>)
# Usual values for <build_type> are: Debug, Release, MinSizeRel, RelWithDebInfo
# Example: jrl_configure_default_build_type(RelWithDebInfo)
function(jrl_configure_default_build_type build_type)
    set(standard_build_types Debug Release MinSizeRel RelWithDebInfo)
    if(NOT build_type IN_LIST standard_build_types)
        message(
            AUTHOR_WARNING
            "Unusual build type provided: ${build_type}, standard values are: ${standard_build_types}"
        )
    endif()

    if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
        message(STATUS "Setting build type to '${build_type}' as none was specified.")
        set(CMAKE_BUILD_TYPE ${build_type} CACHE STRING "Choose the type of build." FORCE)
        # set the possible values of build type for cmake-gui
        set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${allowed_build_types})
    endif()
endfunction()

# Configures the default output directory for binaries and libraries
function(jrl_configure_default_binary_dirs)
    # doc: https://cmake.org/cmake/help/v3.22/manual/cmake-buildsystem.7.html#id47
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin CACHE PATH "") # For Unix/MacOS executables, Windows: .exe, .dll, .pyd
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib CACHE PATH "") # for Unix/MacOS shared libraries .so/.dylib and Windows: .lib (import libraries for shared libraries)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib CACHE PATH "") # For static libraries add_library(STATIC ...) .a and Windows: .lib

    # /!\ MODULE libraries are dynamic libraries. On Windows, python modules are MODULE libraries, with pyd extension.
    #     They should be placed explicitely in lib/site-packages when building python extensions.
    foreach(config Debug Release MinSizeRel RelWithDebInfo)
        string(TOUPPER ${config} config)
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${config} ${CMAKE_BINARY_DIR}/bin CACHE PATH "")
        set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${config} ${CMAKE_BINARY_DIR}/lib CACHE PATH "")
        set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${config} ${CMAKE_BINARY_DIR}/lib CACHE PATH "")
    endforeach()
endfunction()

# jrl_target_set_output_directory(<target_name> OUTPUT_DIRECTORY <dir>)
# This function configures the `ARCHIVE_OUTPUT_DIRECTORY`,
# `LIBRARY_OUTPUT_DIRECTORY`, and `RUNTIME_OUTPUT_DIRECTORY` properties
# for the specified target.
# This is useful for python modules that need to be placed in a specific directory.
# In this module we use it to place python modules in ${CMAKE_BINARY_DIR}/lib/site-packages
# To mimic the installation layout.
# Otherwise, the python modules being a RUMTIME target, would be placed in ${CMAKE_BINARY_DIR}/bin
# Example:
# ```cmake
#   jrl_target_set_output_directory(my_python_module_target OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/site-packages)
# ```
function(jrl_target_set_output_directory target_name)
    set(options)
    set(oneValueArgs OUTPUT_DIRECTORY)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    jrl_check_target_exists(${target_name})
    jrl_check_var_defined(arg_OUTPUT_DIRECTORY)

    set(dir ${arg_OUTPUT_DIRECTORY})

    set_target_properties(
        ${target_name}
        PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY ${dir}
            LIBRARY_OUTPUT_DIRECTORY ${dir}
            ARCHIVE_OUTPUT_DIRECTORY ${dir}
    )

    foreach(config Debug Release MinSizeRel RelWithDebInfo)
        string(TOUPPER ${config} config)
        set_target_properties(
            ${target_name}
            PROPERTIES
                RUNTIME_OUTPUT_DIRECTORY_${config} ${dir}
                LIBRARY_OUTPUT_DIRECTORY_${config} ${dir}
                ARCHIVE_OUTPUT_DIRECTORY_${config} ${dir}
        )
    endforeach()
endfunction()

# Configures the default install directories using GNUInstallDirs (bin, lib, include, etc.)
# Works on all platforms
function(jrl_configure_default_install_dirs)
    include(GNUInstallDirs)
endfunction()

# If not provided by the user, set a default CMAKE_INSTALL_PREFIX. Useful for IDEs.
function(jrl_configure_default_install_prefix default_install_prefix)
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        message(STATUS "Setting default install prefix to '${default_install_prefix}'")
        set(CMAKE_INSTALL_PREFIX
            ${default_install_prefix}
            CACHE PATH
            "Install path prefix, prepended onto install directories."
            FORCE
        )
        mark_as_advanced(CMAKE_INSTALL_PREFIX)
    endif()
endfunction()

# jrl_setup_uninstall_target()
# Setup an uninstall target that can be used to uninstall the project.
# It will create a cmake_uninstall.cmake script next to the cmake_install.cmake script in the build directory.
# Usage: jrl_setup_uninstall_target()
# And then cmake --build . --target uninstall
function(jrl_setup_uninstall_target)
    if(TARGET uninstall)
        return()
    endif()

    _jrl_templates_dir(templates_dir)

    configure_file(
        "${templates_dir}/cmake_uninstall.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
        @ONLY
    )

    add_custom_target(
        uninstall
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
    )
endfunction()

# Setup the default options for a project (opinionated defaults)
# Usage : jrl_configure_defaults()
function(jrl_configure_defaults)
    jrl_configure_default_build_type(Release)
    jrl_configure_default_binary_dirs()
    jrl_configure_default_install_dirs()
    jrl_configure_default_install_prefix(${CMAKE_BINARY_DIR}/install)
    jrl_configure_copy_compile_commands_in_source_dir()
    jrl_setup_uninstall_target()
endfunction()

# jrl_get_cxx_compiler_id(output_var)
# Get the CMAKE_CXX_COMPILER_ID variable, but also handles clang-cl and AppleClang exceptions.
# clang-cl is considered as MSVC, AppleClang as Clang.
# In CMake >= 3.26, use CMAKE_CXX_COMPILER_FRONTEND_VARIANT
# ref: https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_FRONTEND_VARIANT.html
# ref: https://gitlab.kitware.com/cmake/cmake/-/issues/19724
function(jrl_get_cxx_compiler_id output_var)
    jrl_check_var_defined(CMAKE_CXX_COMPILER_ID)

    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC")
        set(cxx_compiler_id "MSVC")
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
        set(cxx_compiler_id "Clang")
    else()
        set(cxx_compiler_id ${CMAKE_CXX_COMPILER_ID})
    endif()

    set(${output_var} ${cxx_compiler_id} PARENT_SCOPE)
endfunction()

# Enable the most common warnings for MSVC, GCC and Clang
# Adding some extra warning on msvc to mimic gcc/clang behavior
# Usage: jrl_target_set_default_compile_options(<target_name> <visibility>)
# visibility is either PRIVATE, PUBLIC or INTERFACE
# Example: jrl_target_set_default_compile_options(my_target INTERFACE)
function(jrl_target_set_default_compile_options target_name visibility)
    jrl_check_target_exists(${target_name})
    jrl_check_valid_visibility(${visibility})

    jrl_get_cxx_compiler_id(cxx_compiler_id)

    if(cxx_compiler_id STREQUAL "MSVC")
        target_compile_options(
            ${target_name}
            ${visibility}
            /W4 # Enable most warnings
            /wd4250 # "Inherits via dominance" - happens with diamond inheritance, not really an issue
            /wd4706 # assignment within conditional expression
            /wd5030 # pointer or reference to potentially throwing function used in noexcept context
            /wd4996 # function may be unsafe
            /we4834 # discarding return value of function with 'nodiscard' attribute
            /we4062 # enumerator 'xyz' in switch of enum 'abc' is not handled
        )
    elseif(cxx_compiler_id STREQUAL "GNU" OR cxx_compiler_id STREQUAL "Clang")
        target_compile_options(
            ${target_name}
            ${visibility}
            -Wall # Enable most warnings
            -Wextra # Enable extra warnings
            -Wconversion # Warn on type conversions that may lose information
            -Wpedantic # Warn on non-standard C++ usage
        )
    else()
        message(WARNING "Unknown compiler '${cxx_compiler_id}'. No default compile options set.")
    endif()
endfunction()

# Description: Enforce MSVC c++ conformance mode so msvc behaves more like gcc and clang
# If the compiler id is not MSVC, this function does nothing.
# Usage: jrl_target_enforce_msvc_conformance(<target_name> <visibility>)
# visibility is either PRIVATE, PUBLIC or INTERFACE
# Example: jrl_target_enforce_msvc_conformance(my_target INTERFACE)
function(jrl_target_enforce_msvc_conformance target_name visibility)
    jrl_check_valid_visibility(${visibility})

    jrl_get_cxx_compiler_id(cxx_compiler_id)
    if(NOT cxx_compiler_id STREQUAL "MSVC")
        return()
    endif()

    target_compile_options(
        ${target_name}
        ${visibility}
        /permissive- # Standards conformance
        /Zc:__cplusplus # Needed to have __cplusplus set correctly
        /EHsc # Enable C++ exceptions standard conformance
        /bigobj # To avoid "fatal error C1128: number of sections exceeded object file format limit"
    )
endfunction()

# Description: Treat all warnings as errors for a targets (/WX for MSVC, -Werror for GCC/Clang)
# Can be disabled on the cmake cli with --compile-no-warning-as-error
# ref: https://cmake.org/cmake/help/latest/manual/cmake.1.html#cmdoption-cmake-compile-no-warning-as-error
# Usage: jrl_target_treat_all_warnings_as_errors(<target_name> <visibility>)
# visibility is either PRIVATE, PUBLIC or INTERFACE
# Example: jrl_target_treat_all_warnings_as_errors(my_target PRIVATE)
# NOTE: in CMake 3.24, we have the new CMAKE_COMPILE_WARNING_AS_ERROR option, but for the whole project and subprojects
function(jrl_target_treat_all_warnings_as_errors target_name visibility)
    jrl_check_valid_visibility(${visibility})

    jrl_get_cxx_compiler_id(cxx_compiler_id)

    if(cxx_compiler_id STREQUAL "MSVC")
        target_compile_options(${target_name} ${visibility} /WX)
    elseif(cxx_compiler_id STREQUAL "GNU" OR cxx_compiler_id STREQUAL "Clang")
        target_compile_options(${target_name} ${visibility} -Werror)
    else()
        message(WARNING "Unknown compiler '${cxx_compiler_id}'. No warning as error flag set.")
    endif()
endfunction()

function(jrl_make_valid_c_identifier INPUT OUTPUT_VAR)
    # 1. Replace all non-alphanumeric and non-underscore characters with underscores
    # 2. If it starts with a digit, prefix with underscore
    # 3. Optionally collapse multiple consecutive underscores
    # 4. Remove trailing underscores (optional cosmetic cleanup)
    # 5. Return result to caller

    string(REGEX REPLACE "[^A-Za-z0-9_]" "_" CLEAN "${INPUT}")

    string(REGEX MATCH "^[0-9]" STARTS_WITH_DIGIT "${CLEAN}")
    if(STARTS_WITH_DIGIT)
        set(CLEAN "_${CLEAN}")
    endif()
    string(REGEX REPLACE "_+" "_" CLEAN "${CLEAN}")
    string(REGEX REPLACE "_$" "" CLEAN "${CLEAN}")
    set(${OUTPUT_VAR} "${CLEAN}" PARENT_SCOPE)
endfunction()

function(jrl_target_generate_header target_name visibility)
    set(options SKIP_INSTALL)
    set(oneValueArgs
        FILENAME
        HEADER_DIR
        TEMPLATE_FILE
        INSTALL_DESTINATION
        VERSION
    )
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    jrl_check_var_defined(PROJECT_NAME)
    jrl_check_var_defined(CMAKE_INSTALL_INCLUDEDIR)
    jrl_check_target_exists(${target_name})
    jrl_check_valid_visibility(${visibility})

    jrl_check_var_defined(arg_FILENAME)
    jrl_check_var_defined(arg_HEADER_DIR)
    jrl_check_var_defined(arg_TEMPLATE_FILE)
    jrl_check_var_defined(arg_INSTALL_DESTINATION)

    if(NOT EXISTS ${arg_TEMPLATE_FILE})
        message(FATAL_ERROR "Input file ${arg_TEMPLATE_FILE} does not exist.")
    endif()

    set(output_file ${arg_HEADER_DIR}/${arg_FILENAME})

    jrl_make_valid_c_identifier(${target_name} LIBRARY_NAME)

    # We need to define LIBRARY_NAME_UPPERCASE, TARGET_NAME, TARGET_VERSION, TARGET_VERSION_MAJOR, TARGET_VERSION_MINOR, TARGET_VERSION_PATCH
    string(TOUPPER ${LIBRARY_NAME} LIBRARY_NAME_UPPERCASE)

    if(arg_VERSION)
        set(LIBRARY_VERSION ${arg_VERSION})
    else()
        # Retrieve version from target
        get_property(LIBRARY_VERSION TARGET ${target_name} PROPERTY VERSION)
        if(NOT LIBRARY_VERSION)
            message(
                WARNING
                "Target ${target_name} does not have a VERSION property set, using the project version instead (PROJECT_VERSION=${PROJECT_VERSION}).
            To remove this warning, set the VERSION property on the target using:

                set_target_properties(${target_name} PROPERTIES VERSION \${PROJECT_VERSION})
            "
            )
            set(LIBRARY_VERSION ${PROJECT_VERSION})
        endif()
    endif()

    string(REPLACE "." ";" version_parts ${LIBRARY_VERSION})
    list(GET version_parts 0 LIBRARY_VERSION_MAJOR)
    list(GET version_parts 1 LIBRARY_VERSION_MINOR)
    list(GET version_parts 2 LIBRARY_VERSION_PATCH)

    configure_file(${arg_TEMPLATE_FILE} ${output_file} @ONLY)

    target_include_directories(${target_name} ${visibility} $<BUILD_INTERFACE:${arg_HEADER_DIR}>)

    if(arg_SKIP_INSTALL)
        return()
    endif()

    jrl_target_headers(${target_name} ${visibility} HEADERS ${output_file} BASE_DIRS ${arg_HEADER_DIR})
endfunction()

function(jrl_target_generate_warning_header target_name visibility)
    set(options SKIP_INSTALL)
    set(oneValueArgs FILENAME HEADER_DIR INSTALL_DESTINATION)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    jrl_check_var_defined(CMAKE_INSTALL_INCLUDEDIR)

    set(filename ${target_name}/warning.hpp)
    if(arg_FILENAME)
        set(filename ${arg_FILENAME})
    endif()

    set(header_dir ${CMAKE_CURRENT_BINARY_DIR}/generated/include)
    if(arg_HEADER_DIR)
        set(header_dir ${arg_HEADER_DIR})
    endif()

    set(install_destination ${CMAKE_INSTALL_INCLUDEDIR}/${target_name})
    if(arg_INSTALL_DESTINATION)
        set(install_destination ${arg_INSTALL_DESTINATION})
    endif()

    set(skip_install "")
    if(arg_SKIP_INSTALL)
        set(skip_install SKIP_INSTALL)
    endif()

    _jrl_templates_dir(templates_dir)
    jrl_target_generate_header(${target_name} ${visibility}
        FILENAME ${filename}
        HEADER_DIR ${header_dir}
        TEMPLATE_FILE ${templates_dir}/warning.hpp.in
        INSTALL_DESTINATION ${install_destination}
        VERSION ${PROJECT_VERSION}
        ${skip_install}
    )
endfunction()

function(jrl_target_generate_deprecated_header target_name visibility)
    set(options SKIP_INSTALL)
    set(oneValueArgs FILENAME HEADER_DIR INSTALL_DESTINATION)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    jrl_check_var_defined(CMAKE_INSTALL_INCLUDEDIR)

    set(filename ${target_name}/deprecated.hpp)
    if(arg_FILENAME)
        set(filename ${arg_FILENAME})
    endif()

    set(header_dir ${CMAKE_CURRENT_BINARY_DIR}/generated/include)
    if(arg_HEADER_DIR)
        set(header_dir ${arg_HEADER_DIR})
    endif()

    set(install_destination ${CMAKE_INSTALL_INCLUDEDIR}/${target_name})
    if(arg_INSTALL_DESTINATION)
        set(install_destination ${arg_INSTALL_DESTINATION})
    endif()

    set(skip_install "")
    if(arg_SKIP_INSTALL)
        set(skip_install SKIP_INSTALL)
    endif()

    _jrl_templates_dir(templates_dir)
    jrl_target_generate_header(${target_name} ${visibility}
        FILENAME ${filename}
        HEADER_DIR ${header_dir}
        TEMPLATE_FILE ${templates_dir}/deprecated.hpp.in
        INSTALL_DESTINATION ${install_destination}
        VERSION ${PROJECT_VERSION}
        ${skip_install}
    )
endfunction()

function(jrl_target_generate_config_header target_name visibility)
    set(options SKIP_INSTALL)
    set(oneValueArgs FILENAME HEADER_DIR INSTALL_DESTINATION VERSION)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    jrl_check_var_defined(CMAKE_INSTALL_INCLUDEDIR)
    jrl_check_var_defined(PROJECT_VERSION)
    jrl_check_var_defined(PROJECT_VERSION_MAJOR)
    jrl_check_var_defined(PROJECT_VERSION_MINOR)
    jrl_check_var_defined(PROJECT_VERSION_PATCH)

    set(filename ${target_name}/config.hpp)
    if(arg_FILENAME)
        set(filename ${arg_FILENAME})
    endif()

    set(header_dir ${CMAKE_CURRENT_BINARY_DIR}/generated/include)
    if(arg_HEADER_DIR)
        set(header_dir ${arg_HEADER_DIR})
    endif()

    set(install_destination ${CMAKE_INSTALL_INCLUDEDIR}/${target_name})
    if(arg_INSTALL_DESTINATION)
        set(install_destination ${arg_INSTALL_DESTINATION})
    endif()

    set(skip_install "")
    if(arg_SKIP_INSTALL)
        set(skip_install SKIP_INSTALL)
    endif()

    _jrl_templates_dir(templates_dir)
    jrl_target_generate_header(${target_name} ${visibility}
        FILENAME ${filename}
        HEADER_DIR ${header_dir}
        TEMPLATE_FILE ${templates_dir}/config.hpp.in
        INSTALL_DESTINATION ${install_destination}
        VERSION ${arg_VERSION}
        ${skip_install}
    )
endfunction()

function(jrl_target_generate_tracy_header target_name visibility)
    set(options SKIP_INSTALL)
    set(oneValueArgs FILENAME HEADER_DIR INSTALL_DESTINATION)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    jrl_check_var_defined(CMAKE_INSTALL_INCLUDEDIR)
    jrl_check_var_defined(PROJECT_VERSION)
    jrl_check_var_defined(PROJECT_VERSION_MAJOR)
    jrl_check_var_defined(PROJECT_VERSION_MINOR)
    jrl_check_var_defined(PROJECT_VERSION_PATCH)

    set(filename ${target_name}/tracy.hpp)
    if(arg_FILENAME)
        set(filename ${arg_FILENAME})
    endif()

    set(header_dir ${CMAKE_CURRENT_BINARY_DIR}/generated/include)
    if(arg_HEADER_DIR)
        set(header_dir ${arg_HEADER_DIR})
    endif()

    set(install_destination ${CMAKE_INSTALL_INCLUDEDIR}/${target_name})
    if(arg_INSTALL_DESTINATION)
        set(install_destination ${arg_INSTALL_DESTINATION})
    endif()

    set(skip_install "")
    if(arg_SKIP_INSTALL)
        set(skip_install SKIP_INSTALL)
    endif()

    _jrl_templates_dir(templates_dir)
    jrl_target_generate_header(${target_name} ${visibility}
        FILENAME ${filename}
        HEADER_DIR ${header_dir}
        TEMPLATE_FILE ${templates_dir}/tracy.hpp.in
        INSTALL_DESTINATION ${install_destination}
        VERSION ${PROJECT_VERSION}
        ${skip_install}
    )
endfunction()

# This function searches for a find module named Find<package>.cmake).
# It iterates over the CMAKE_MODULE_PATH and the find-modules directory.
# This function is used to determine which module file was used by jrl_find_package.
# Usage: jrl_search_package_module_file(<package_name> <output_filepath>)
# Example: jrl_search_package_module_file(Eigen module_file)
function(jrl_search_package_module_file package_name output_filepath)
    set(module_filename "Find${package_name}.cmake")
    set(found_module_file "")
    # QUESTION: Should we look into cmake builtin modules?
    # set(cmake_builtin_modules_path "${CMAKE_ROOT}/Modules")
    _jrl_find_modules_dir(find_modules_dir)

    foreach(module_path IN LISTS CMAKE_MODULE_PATH find_modules_dir)
        set(candidate_filepath "${module_path}/${module_filename}")
        message(DEBUG "        Searching for package module file at: ${candidate_filepath}")
        if(EXISTS ${candidate_filepath})
            set(found_module_file ${candidate_filepath})
            break()
        endif()
    endforeach()

    set(${output_filepath} ${found_module_file} PARENT_SCOPE)
endfunction()

# jrl_find_package(<PackageName> [version] [COMPONENTS <comp>...] [REQUIRED] MODULE_PATH <path_to_find_module>)
#
# Wrapper around CMake's find_package used for dependency tracking and logging.
# It delegates the arguments provided to the standard CMake find_package, while recording everything in a global property for later introspection.
# It record, the find_package arguments, the variables and imported targets created by the package, and the module file used (if any).
# After the jrl_find_package calls, use jrl_print_dependencies_summary() for printing an extensive analysis.
#
# Parameters:
#   <PackageName>  - Name of the package to locate (forwarded to find_package).
#   version        - Optional version requirement forwarded to find_package.
#   COMPONENTS ... - Optional list of components forwarded to find_package.
#   MODULE_PATH    - Optional path to a custom Find<PackageName>.cmake module file.
#                    If specified, only this path is used, and the file must be at <path_to_find_module>/Find<PackageName>.cmake
#   All other options are forwarded to find_package as-is.
#
# Examples:
# ```cmake
#   jrl_find_package(Eigen 3.3 REQUIRED)
#   jrl_find_package(Boost REQUIRED COMPONENTS filesystem system)
# ```
#
# Notes:
#   * This macro is a convenience wrapper and does not change the fundamental semantics of find_package.
#   * Prefer using REQUIRED to ensure missing packages are caught early. Don't react to missing packages manually.
#   * This needs to be a macro so find_package can leak variables (like Python_SITELIB)
# See also: jrl_dump_package_dependencies_json(), jrl_export_package()
macro(jrl_find_package)
    set(options)
    set(oneValueArgs MODULE_PATH)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    message(STATUS "[${ARGV0}]")
    message(DEBUG "Executing jrl_find_package with args ${ARGV}")

    # Pkg name is the first argument of find_package(<pkg_name> ...)
    set(package_name ${ARGV0})
    set(find_package_args "${arg_UNPARSED_ARGUMENTS}")

    # Handle custom module file
    if(arg_MODULE_PATH)
        set(module_file "${arg_MODULE_PATH}/Find${package_name}.cmake")
        if(NOT EXISTS ${module_file})
            message(
                FATAL_ERROR
                "Custom module file provided with MODULE_PATH ${module_file} does not exist."
            )
        endif()
    else()
        # search for the module file only is CONFIG is not in the find_package args
        if(NOT "CONFIG" IN_LIST find_package_args)
            jrl_search_package_module_file(${package_name} module_file)
        endif()
    endif()

    if(module_file)
        cmake_path(CONVERT "${module_file}" TO_CMAKE_PATH_LIST module_file NORMALIZE)
        # Add the parent path to the CMAKE_MODULE_PATH
        cmake_path(GET module_file PARENT_PATH module_dir)
        list(APPEND CMAKE_MODULE_PATH ${module_dir})
        message(STATUS "   Using custom module file: ${module_file}")
    endif()

    # Call find_package with the provided arguments
    string(REPLACE ";" " " fp_pp "${find_package_args}")
    message(STATUS "   Executing find_package(${fp_pp})")
    unset(fp_pp)

    # Saving the list of imported targets and variables BEFORE the call to find_package
    get_property(
        imported_targets_before
        DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        PROPERTY IMPORTED_TARGETS
    )
    get_property(variables_before DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VARIABLES)

    find_package(${find_package_args}) # TODO: handle QUIET properly

    if(${package_name}_FOUND)
        message(STATUS "   Executing find_package()...✅")
    else()
        message(STATUS "   Executing find_package()...❌")
    endif()

    # Put back CMAKE_MODULE_PATH to its previous value
    if(module_dir)
        list(REMOVE_ITEM CMAKE_MODULE_PATH ${module_dir})
    endif()

    # Getting the list of imported targets and variables AFTER the call to find_package
    get_property(package_variables DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VARIABLES)
    get_property(package_targets DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY IMPORTED_TARGETS)
    list(REMOVE_ITEM package_variables ${variables_before} variables_before)
    list(REMOVE_ITEM package_targets ${imported_targets_before})

    if(${package_name}_VERSION)
        message(STATUS "   Version found: ${${package_name}_VERSION}")
    endif()

    string(REPLACE ";" ", " package_variables_pp "${package_variables}")
    if(package_variables)
        message(DEBUG "   New variables detected: ${package_variables_pp}")
    else()
        message(STATUS "   No new variables detected.")
    endif()

    string(REPLACE ";" ", " package_targets_pp "${package_targets}")
    if(package_targets)
        message(STATUS "   Imported targets detected: ${package_targets_pp}")
    else()
        message(STATUS "   No imported targets detected.")
    endif()

    get_property(deps GLOBAL PROPERTY _jrl_${PROJECT_NAME}_package_dependencies)
    if(NOT deps)
        string(JSON deps SET "{}" "package_dependencies" "[]")
    endif()

    set(package_json "{}")
    string(REPLACE ";" " " find_package_args "${find_package_args}")
    string(JSON package_json SET "${package_json}" "package_name" "\"${package_name}\"")
    string(JSON package_json SET "${package_json}" "find_package_args" "\"${find_package_args}\"")
    string(JSON package_json SET "${package_json}" "package_variables" "\"${package_variables}\"")
    string(JSON package_json SET "${package_json}" "package_targets" "\"${package_targets}\"")
    string(JSON package_json SET "${package_json}" "module_file" "\"${module_file}\"")
    string(JSON deps_length LENGTH "${deps}" "package_dependencies")
    string(JSON deps SET "${deps}" "package_dependencies" ${deps_length} "${package_json}")

    set_property(GLOBAL PROPERTY _jrl_${PROJECT_NAME}_package_dependencies "${deps}")

    unset(package_targets)
    unset(package_targets_pp)
    unset(package_variables)
    unset(package_variables_pp)
    unset(variables_before)
    unset(imported_targets_before)
    unset(deps)
    unset(module_file)
    unset(package_json)
    unset(deps_length)
endmacro()

# jrl_print_dependencies_summary()
# Print a summary of all dependencies found via jrl_find_package, and some properties of their imported targets.
function(jrl_print_dependencies_summary)
    set(log_msg "")

    macro(_log msg)
        string(APPEND log_msg "${msg}\n")
    endmacro()

    get_property(deps GLOBAL PROPERTY _jrl_${PROJECT_NAME}_package_dependencies)
    if(NOT deps)
        message(STATUS "No dependencies found via jrl_find_package.")
        return()
    endif()

    _log("")
    _log("================= External Dependencies ======================================")
    _log("")

    string(JSON num_deps LENGTH "${deps}" "package_dependencies")
    math(EXPR max_idx "${num_deps} - 1")
    _log("${num_deps} dependencies declared jrl_find_package: ")
    foreach(i RANGE 0 ${max_idx})
        string(JSON package_name GET "${deps}" "package_dependencies" ${i} "package_name")
        string(JSON package_targets GET "${deps}" "package_dependencies" ${i} "package_targets")

        # Replace ; by , for better readability
        string(REPLACE ";" ", " package_targets_pp "${package_targets}")
        math(EXPR i "${i} + 1")
        _log("${i}/${num_deps} Package [${package_name}] imported targets [${package_targets_pp}]")

        # Print target properties
        if(package_targets STREQUAL "")
            continue()
        endif()
        jrl_cmake_print_properties(
            TARGETS ${package_targets}
            OUTPUT_VARIABLE props_msg
            PROPERTIES
                NAME
                ALIASED_TARGET
                TYPE
                VERSION
                LOCATION
                INCLUDE_DIRECTORIES
                COMPILE_DEFINITIONS
                COMPILE_OPTIONS
                COMPILE_FEATURES
                COMPILE_FLAGS
                COMPILE_OPTIONS
                LINK_LIBRARIES
                LINK_OPTIONS
                INTERFACE_INCLUDE_DIRECTORIES
                INTERFACE_COMPILE_DEFINITIONS
                INTERFACE_COMPILE_OPTIONS
                INTERFACE_LINK_LIBRARIES
                INTERFACE_LINK_OPTIONS
                CXX_STANDARD
                CXX_EXTENSIONS
                CXX_STANDARD_REQUIRED
        )
        _log("${props_msg}")
    endforeach()
    message(STATUS "${log_msg}")
endfunction()

# jrl_cmake_print_properties
# Usage: jrl_cmake_print_properties(<mode> <items> PROPERTIES <property1> <property2> ... [VERBOSITY <verbosity_level>] [OUTPUT_VARIABLE <var_name>])
# This is taken and adapted from cmake's own cmake_print_properties function to add verbosity control and print only found properties.
# If OUTPUT_VARIABLE is provided, the output will be stored in the variable instead of printed to the console.
function(jrl_cmake_print_properties)
    set(options)
    set(oneValueArgs VERBOSITY OUTPUT_VARIABLE)
    set(cpp_multiValueArgs PROPERTIES)
    set(cppmode_multiValueArgs
        TARGETS
        SOURCES
        TESTS
        DIRECTORIES
        CACHE_ENTRIES
    )

    string(JOIN " " _mode_names ${cppmode_multiValueArgs})
    set(_missing_mode_message
        "Mode keyword missing in jrl_cmake_print_properties() call, there must be exactly one of ${_mode_names}"
    )

    cmake_parse_arguments(CPP "${options}" "${oneValueArgs}" "${cpp_multiValueArgs}" ${ARGN})

    if(NOT CPP_PROPERTIES)
        message(
            FATAL_ERROR
            "Required argument PROPERTIES missing in jrl_cmake_print_properties() call"
        )
        return()
    endif()

    set(verbosity STATUS)
    if(CPP_VERBOSITY)
        set(verbosity ${CPP_VERBOSITY})
    endif()

    if(NOT CPP_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${_missing_mode_message}")
        return()
    endif()

    cmake_parse_arguments(
        CPPMODE
        "${options}"
        "${oneValueArgs}"
        "${cppmode_multiValueArgs}"
        ${CPP_UNPARSED_ARGUMENTS}
    )

    if(CPPMODE_UNPARSED_ARGUMENTS)
        message(
            FATAL_ERROR
            "Unknown keywords given to cmake_print_properties(): \"${CPPMODE_UNPARSED_ARGUMENTS}\""
        )
        return()
    endif()

    set(mode)
    set(items)
    set(keyword)

    if(CPPMODE_TARGETS)
        set(items ${CPPMODE_TARGETS})
        set(mode ${mode} TARGETS)
        set(keyword TARGET)
    endif()

    if(CPPMODE_SOURCES)
        set(items ${CPPMODE_SOURCES})
        set(mode ${mode} SOURCES)
        set(keyword SOURCE)
    endif()

    if(CPPMODE_TESTS)
        set(items ${CPPMODE_TESTS})
        set(mode ${mode} TESTS)
        set(keyword TEST)
    endif()

    if(CPPMODE_DIRECTORIES)
        set(items ${CPPMODE_DIRECTORIES})
        set(mode ${mode} DIRECTORIES)
        set(keyword DIRECTORY)
    endif()

    if(CPPMODE_CACHE_ENTRIES)
        set(items ${CPPMODE_CACHE_ENTRIES})
        set(mode ${mode} CACHE_ENTRIES)
        # This is a workaround for the fact that passing `CACHE` as an argument to
        # set() causes a cache variable to be set.
        set(keyword "")
        string(APPEND keyword CACHE)
    endif()

    if(NOT mode)
        message(FATAL_ERROR "${_missing_mode_message}")
        return()
    endif()

    list(LENGTH mode modeLength)
    if("${modeLength}" GREATER 1)
        message(
            FATAL_ERROR
            "Multiple mode keywords used in cmake_print_properties() call, there must be exactly one of ${_mode_names}."
        )
        return()
    endif()

    set(msg "\n")
    foreach(item ${items})
        set(itemExists TRUE)
        if(keyword STREQUAL "TARGET")
            if(NOT TARGET ${item})
                set(itemExists FALSE)
                string(APPEND msg "\n No such TARGET \"${item}\" !\n\n")
            endif()
        endif()

        if(itemExists)
            string(APPEND msg " Properties for ${keyword} ${item}:\n")
            foreach(prop ${CPP_PROPERTIES})
                get_property(propertySet ${keyword} ${item} PROPERTY "${prop}" SET)

                if(propertySet)
                    get_property(property ${keyword} ${item} PROPERTY "${prop}")
                    # Convert paths containing \ to / (Windows)
                    if(WIN32)
                        cmake_path(CONVERT "${property}" TO_CMAKE_PATH_LIST property)
                    endif()
                    #   string(APPEND msg "   ${item}.${prop} = \"${property}\"\n")
                    _jrl_pad_string("${prop}"      40 _prop)
                    string(APPEND msg "   ${_prop} = ${property}\n")
                else()
                    # EDIT: Do not print unset properties
                    # string(APPEND msg "   ${item}.${prop} = <NOTFOUND>\n")
                endif()
            endforeach()
        endif()
    endforeach()

    if(CPP_OUTPUT_VARIABLE)
        set(${CPP_OUTPUT_VARIABLE} "${msg}" PARENT_SCOPE)
    else()
        message(${verbosity} "${msg}")
    endif()
endfunction()

# Usage: jrl_export_dependencies(TARGETS [target1...] GEN_DIR <gen_dir> INSTALL_DESTINATION <destination>)
# This function analyzes the link libraries of the provided targets,
# determines which packages are needed and generates a <export_name>-dependencies.cmake file
function(jrl_export_dependencies)
    set(options)
    set(oneValueArgs INSTALL_DESTINATION GEN_DIR)
    set(multiValueArgs TARGETS)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    jrl_check_var_defined(arg_TARGETS)

    if(arg_GEN_DIR)
        set(GEN_DIR ${arg_GEN_DIR})
    else()
        set(GEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated/cmake/${PROJECT_NAME})
    endif()

    if(arg_INSTALL_DESTINATION)
        set(INSTALL_DESTINATION ${arg_INSTALL_DESTINATION})
    else()
        set(INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})
    endif()

    if(arg_FILENAME)
        set(FILENAME ${arg_FILENAME})
    else()
        set(FILENAME ${PROJECT_NAME}-dependencies.cmake)
    endif()

    # Get all BUILDSYSTEM_TARGETS of the current project (i.e. added via add_library/add_executable)
    # We need this to filter out internal targets when analyzing link libraries
    get_property(
        buildsystem_targets
        DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        PROPERTY BUILDSYSTEM_TARGETS
    )
    foreach(target ${arg_TARGETS})
        if(NOT target IN_LIST buildsystem_targets)
            message(
                FATAL_ERROR
                "Target '${target}' is not a buildsystem target of the current project. Cannot export dependencies for it."
            )
        endif()
    endforeach()

    set(all_imported_libraries "")
    foreach(target ${arg_TARGETS})
        get_target_property(interface_link_libraries ${target} INTERFACE_LINK_LIBRARIES)
        if(NOT interface_link_libraries)
            message(DEBUG "Target '${target}' has no INTERFACE_LINK_LIBRARIES.")
            continue()
        endif()
        foreach(lib ${interface_link_libraries})
            if(lib IN_LIST buildsystem_targets)
                continue()
            endif()

            if(lib IN_LIST all_imported_libraries)
                continue()
            endif()

            list(APPEND all_imported_libraries ${lib})
        endforeach()
    endforeach()

    message(DEBUG "All link libraries for targets '${arg_TARGETS}': ${all_imported_libraries}")

    get_property(
        package_dependencies_json_content
        GLOBAL
        PROPERTY _jrl_${PROJECT_NAME}_package_dependencies
    )
    if(all_imported_libraries AND NOT package_dependencies_json_content)
        message(
            FATAL_ERROR
            "Imported libraries found, but no package dependencies recorded with jrl_find_package()"
        )
    endif()

    if(NOT package_dependencies_json_content)
        message(DEBUG "No package dependencies recorded with jrl_find_package()")
    endif()

    file(
        GENERATE OUTPUT
        ${GEN_DIR}/imported-libraries.cmake
        CONTENT
            "
# Generated file - do not edit
# This file contains the list of imported libraries that needs to be exported
set(imported_libraries [[${all_imported_libraries}]])
set(package_dependencies_json_content [[${package_dependencies_json_content}]])

# For debugging purposes
set(targets [[${arg_TARGETS}]])
set(buildsystem_targets [[${buildsystem_targets}]])
"
    )
    # needs @INSTALL_DESTINATION@
    _jrl_templates_dir(templates_dir)
    configure_file(
        ${templates_dir}/generate-dependencies.cmake.in
        ${GEN_DIR}/generate-dependencies.cmake
        @ONLY
    )
    install(SCRIPT ${GEN_DIR}/generate-dependencies.cmake)
endfunction()

# jrl_add_export_component(NAME <component_name> TARGETS <target1> <target2> ...)
# Add an export component with associated targets that will be exported as a CMake package component.
# Each export component will have its own <package>-component-<name>-targets.cmake
# and <package>-component-<name>-dependencies.cmake generated.
# Components are used with: find_package(<package> CONFIG REQUIRED COMPONENTS <component1> <component2> ...)
function(jrl_add_export_component)
    set(options)
    set(oneValueArgs NAME)
    set(multiValueArgs TARGETS)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    jrl_check_var_defined(PROJECT_NAME)
    jrl_check_var_defined(arg_TARGETS)
    jrl_check_var_defined(arg_NAME)

    # Check export component is not already declared
    get_property(existing_components GLOBAL PROPERTY _jrl_${PROJECT_NAME}_export_components)
    if(${arg_NAME} IN_LIST existing_components)
        message(
            FATAL_ERROR
            "Export component '${arg_NAME}' is already declared for project '${PROJECT_NAME}'."
        )
    endif()

    # Check if target is already in an export component
    foreach(component ${existing_components})
        get_property(component_targets GLOBAL PROPERTY _jrl_${PROJECT_NAME}_${component}_targets)
        foreach(target ${arg_TARGETS})
            if(${target} IN_LIST component_targets)
                message(
                    FATAL_ERROR
                    "Target '${target}' is already part of export component '${component}'. Cannot add it to export component '${arg_NAME}'."
                )
            endif()
        endforeach()
    endforeach()

    message(
        STATUS
        "Adding export component '${arg_NAME}' with targets: ${arg_TARGETS} (export name: ${PROJECT_NAME}::${arg_NAME})
        It makes this component available via: find_package(${PROJECT_NAME} CONFIG REQUIRED COMPONENTS ${arg_NAME})
        "
    )

    # Despite its signature, the following commented line associates the installed target files with an export, without installing anything.
    # install(TARGETS ${arg_TARGETS} EXPORT ${PROJECT_NAME}-${arg_NAME})
    # TODO: Declare exports first like that, then split the jrl_export_package() with a generation and an install step.

    set_property(GLOBAL PROPERTY _jrl_${PROJECT_NAME}_export_components ${arg_NAME} APPEND)
    set_property(GLOBAL PROPERTY _jrl_${PROJECT_NAME}_${arg_NAME}_targets ${arg_TARGETS})
endfunction()

# jrl_contains_generator_expressions(<input_string> <output_var>)
# Check if the provided string contains generator expressions.
# Sets output_var to True or False.
function(jrl_contains_generator_expressions input_string output_var)
    string(GENEX_STRIP "${input_string}" stripped_string)
    if(stripped_string STREQUAL input_string)
        set(${output_var} False PARENT_SCOPE)
    else()
        set(${output_var} True PARENT_SCOPE)
    endif()
endfunction()

# jrl_target_headers(<target>
#   HEADERS <list_of_headers>
#   BASE_DIRS <list_of_base_dirs> # Optional, default is empty
# )
# Declare headers for target to be installed later.
# * This function does not target_include_directories(), only stores them for installation.
# * Only PUBLIC and INTERFACE will be installed.
# * It populates the _jrl_install_headers and _jrl_install_headers_base_dirs properties of the target.
# * In CMake 3.23, we will use FILE_SETS instead of this trick.
# cf: https://cmake.org/cmake/help/latest/command/target_sources.html#file-sets
function(jrl_target_headers target visibility)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs HEADERS BASE_DIRS)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    jrl_check_var_defined(arg_HEADERS)
    jrl_check_target_exists(${target})
    jrl_check_valid_visibility(${visibility})

    if(NOT arg_BASE_DIRS)
        set(arg_BASE_DIRS "")
    endif()

    # Save the headers in a property of the target
    # NOTE: The PUBLIC_HEADER technically works, but does not support base_dirs
    # cf: https://cmake.org/cmake/help/latest/command/install.html#install
    set_property(TARGET ${target} APPEND PROPERTY _jrl_install_headers "${arg_HEADERS}")
    set_property(TARGET ${target} APPEND PROPERTY _jrl_install_headers_base_dirs "${arg_BASE_DIRS}")
endfunction()

# jrl_target_install_headers(<target>
#   DESTINATION <destination> # Optional, default is CMAKE_INSTALL_INCLUDEDIR
# )
# Install declared header for a given target and solve the relative path using the provided base dirs.
# It is using the _jrl_install_headers and _jrl_install_headers_base_dirs properties set via jrl_target_headers().
# For a whole project, use jrl_install_headers() instead (which calls this function for each component, that contains targets).
function(jrl_target_install_headers target)
    set(options)
    set(oneValueArgs DESTINATION)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    jrl_check_target_exists(${target})

    if(NOT arg_DESTINATION)
        set(install_destination ${CMAKE_INSTALL_INCLUDEDIR})
    else()
        set(install_destination ${arg_DESTINATION})
    endif()

    get_target_property(headers ${target} _jrl_install_headers)
    get_target_property(base_dirs ${target} _jrl_install_headers_base_dirs)

    if(NOT headers)
        message(DEBUG "No headers declared for target '${target}'. Skipping installation.")
        return()
    endif()

    file(
        GENERATE OUTPUT
        ${CMAKE_CURRENT_BINARY_DIR}/generated/cmake/${PROJECT_NAME}/${target}-install-headers.cmake
        CONTENT
            "
# Generated file - do not edit
# This file contains the list of headers declared for target '${target}' with visibility '${visibility}'
set(headers \"${headers}\")
set(base_dirs \"${base_dirs}\")
foreach(header \${headers})
    foreach(base_dir \${base_dirs})
        string(FIND \${header} \${base_dir} pos)
        if(pos EQUAL 0)
            string(REPLACE \${base_dir} \"\" relative_path \${header})
            string(REGEX REPLACE \"^/\" \"\" relative_path \${relative_path})
            break()
        endif()
    endforeach()

    if(IS_ABSOLUTE \${header})
        set(header_path \${header})
    else()
        set(header_path ${CMAKE_CURRENT_SOURCE_DIR}/\${header})
    endif()

    if(relative_path)
        cmake_path(GET relative_path PARENT_PATH header_dir)
        file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/${install_destination}/\${header_dir}\" TYPE FILE FILES \${header_path})
    else()
        # No base directory matched, install without subdirectory
        file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/${install_destination}\" TYPE FILE FILES \${header_path})
    endif()
endforeach()
"
    )
    install(
        SCRIPT
            ${CMAKE_CURRENT_BINARY_DIR}/generated/cmake/${PROJECT_NAME}/${target}-install-headers.cmake
    )
endfunction()

# jrl_install_headers(
#   DESTINATION <destination> # Optional, default is CMAKE_INSTALL_INCLUDEDIR
#   COMPONENTS <component1> <component2> ... # Optional, default is all declared components
# )
# For each component, install declared headers for all targets.
# See jrl_target_headers() to declare headers for a target.
function(jrl_install_headers)
    set(options)
    set(oneValueArgs DESTINATION)
    set(multiValueArgs COMPONENTS)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    jrl_check_var_defined(PROJECT_NAME)

    if(arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unrecognized arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT arg_DESTINATION)
        set(install_destination ${CMAKE_INSTALL_INCLUDEDIR})
    else()
        set(install_destination ${arg_DESTINATION})
    endif()

    get_property(declared_components GLOBAL PROPERTY _jrl_${PROJECT_NAME}_export_components)

    set(components "")
    if(arg_COMPONENTS)
        set(components ${arg_COMPONENTS})
    else()
        if(NOT declared_components)
            message(
                FATAL_ERROR
                "No export components declared for project '${PROJECT_NAME}'. Cannot install headers. Use jrl_add_export_component() first."
            )
        endif()
        set(components ${declared_components})
        message(
            STATUS
            "Installing headers for all declared components. Declared components: [${declared_components}]"
        )
    endif()

    foreach(component ${components})
        if(NOT component IN_LIST declared_components)
            message(
                FATAL_ERROR
                "Component '${component}' is not declared for project '${PROJECT_NAME}'."
            )
        endif()

        get_property(targets GLOBAL PROPERTY _jrl_${PROJECT_NAME}_${component}_targets)
        if(NOT targets)
            message(WARNING "No targets found for component '${component}'. Skipping.")
            continue()
        endif()

        foreach(target ${targets})
            message(
                STATUS
                "Installing headers for target '${target}' of component '${component}' to '${install_destination}'"
            )
            jrl_target_install_headers(${target} DESTINATION ${install_destination})
        endforeach()
    endforeach()
endfunction()

# jrl_export_package()
# Export the CMake package with all its components (targets, headers, package modules, etc.)
# Generates and installs CMake package configuration files:
#  - <INSTALL_DIR>/<package>/<package>-config.cmake
#  - <INSTALL_DIR>/<package>/<package>-config-version.cmake
#  - <INSTALL_DIR>/<package>/<package>/<componentA>/targets.cmake
#  - <INSTALL_DIR>/<package>/<package>/<componentA>/dependencies.cmake
#  - <INSTALL_DIR>/<package>/<package>/<componentB>/targets.cmake
#  - <INSTALL_DIR>/<package>/<package>/<componentB>/dependencies.cmake
# NOTE: This is for CMake package export only. Python bindings are handled separately.
function(jrl_export_package)
    set(options)
    set(oneValueArgs PACKAGE_CONFIG_TEMPLATE CMAKE_FILES_INSTALL_DIR PACKAGE_CONFIG_EXTRA_CONTENT)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    message(STATUS "[${PROJECT_NAME}] Exporting package (${CMAKE_CURRENT_FUNCTION})")

    include(CMakePackageConfigHelpers)
    jrl_check_var_defined(PROJECT_NAME)
    jrl_check_var_defined(PROJECT_VERSION)
    jrl_check_var_defined(CMAKE_INSTALL_BINDIR)
    jrl_check_var_defined(CMAKE_INSTALL_LIBDIR)
    jrl_check_var_defined(CMAKE_INSTALL_INCLUDEDIR)

    if(arg_PACKAGE_CONFIG_TEMPLATE)
        set(PACKAGE_CONFIG_TEMPLATE ${arg_PACKAGE_CONFIG_TEMPLATE})
    else()
        _jrl_templates_dir(templates_dir)
        set(PACKAGE_CONFIG_TEMPLATE ${templates_dir}/config-components.cmake.in)
        set(using_default_template True)
    endif()

    if(arg_CMAKE_FILES_INSTALL_DIR)
        set(CMAKE_FILES_INSTALL_DIR ${arg_CMAKE_FILES_INSTALL_DIR})
    else()
        set(CMAKE_FILES_INSTALL_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})
    endif()

    # NOTE: Expose as options if needed
    set(GEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated/cmake/${PROJECT_NAME})
    set(PACKAGE_NAME ${PROJECT_NAME})
    set(PACKAGE_NAMESPACE "${PACKAGE_NAME}::")
    set(PACKAGE_CONFIG_FILENAME ${PACKAGE_NAME}-config.cmake)
    set(PACKAGE_VERSION ${PROJECT_VERSION})
    set(PACKAGE_VERSION_FILENAME ${PACKAGE_NAME}-config-version.cmake) # Note: This needs to be config-version.cmake or ConfigVersion.cmake to work.
    set(PACKAGE_VERSION_COMPATIBILITY AnyNewerVersion)
    set(PACKAGE_VERSION_ARCH_INDEPENDENT "")
    set(NO_SET_AND_CHECK_MACRO "NO_SET_AND_CHECK_MACRO")
    set(NO_CHECK_REQUIRED_COMPONENTS_MACRO "NO_CHECK_REQUIRED_COMPONENTS_MACRO")

    # Dump package dependencies recorded with jrl_find_package()
    jrl_dump_package_dependencies_json(${GEN_DIR}/${PROJECT_NAME}-package-dependencies.json)

    # Get declared export components
    get_property(declared_components GLOBAL PROPERTY _jrl_${PROJECT_NAME}_export_components)
    if(using_default_template AND NOT declared_components)
        message(
            FATAL_ERROR
            "No export component declared for project '${PROJECT_NAME}'.
        The default config-components.cmake.in template requires at least one export component.
        Either add export-components via:
            jrl_add_export_component(NAME <comp_name> TARGETS [target1...])
        Or provide your own config template:
            jrl_export_package(PACKAGE_CONFIG_TEMPLATE <config-template.cmake.in>)
        "
        )
    endif()

    # <package>-config.cmake
    # The multi-component needs the variable PROJECT_COMPONENTS
    set(PACKAGE_CONFIG_EXTRA_CONTENT ${arg_PACKAGE_CONFIG_EXTRA_CONTENT})
    set(PROJECT_COMPONENTS ${declared_components})
    configure_package_config_file(
        ${PACKAGE_CONFIG_TEMPLATE}
        ${GEN_DIR}/${PACKAGE_CONFIG_FILENAME}
        INSTALL_DESTINATION ${CMAKE_FILES_INSTALL_DIR}
        ${NO_SET_AND_CHECK_MACRO}
        ${NO_CHECK_REQUIRED_COMPONENTS_MACRO}
    )
    install(FILES ${GEN_DIR}/${PACKAGE_CONFIG_FILENAME} DESTINATION ${CMAKE_FILES_INSTALL_DIR})

    # <package>-config-version.cmake
    write_basic_package_version_file(
        ${GEN_DIR}/${PACKAGE_VERSION_FILENAME}
        VERSION ${PACKAGE_VERSION}
        COMPATIBILITY ${PACKAGE_VERSION_COMPATIBILITY}
        ${PACKAGE_VERSION_ARCH_INDEPENDENT}
    )
    install(FILES ${GEN_DIR}/${PACKAGE_VERSION_FILENAME} DESTINATION ${CMAKE_FILES_INSTALL_DIR})

    foreach(component ${declared_components})
        message(STATUS "Generating cmake module files for component '${component}'")

        get_property(targets GLOBAL PROPERTY _jrl_${PROJECT_NAME}_${component}_targets)

        jrl_target_install_headers(${targets} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

        # <package>/<component>/dependencies.cmake
        jrl_export_dependencies(
            TARGETS ${targets}
            GEN_DIR ${GEN_DIR}/${component}
            INSTALL_DESTINATION ${CMAKE_FILES_INSTALL_DIR}/${component}
        )
        # Create the export for the component targets
        # AND the install rules for the targets (see jrl_add_export_component() comment)
        install(
            TARGETS ${targets}
            EXPORT ${PROJECT_NAME}-${component}
            RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
            LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
            ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        )
        # <package>/<component>/targets.cmake
        install(
            EXPORT ${PROJECT_NAME}-${component}
            FILE targets.cmake
            NAMESPACE ${PACKAGE_NAMESPACE}
            DESTINATION ${CMAKE_FILES_INSTALL_DIR}/${component}
        )
    endforeach()
endfunction()

# jrl_dump_package_dependencies_json()
# Internal function to dump the package dependencies recorded with jrl_find_package()
# It is called at the end of the configuration step via cmake_language(DEFER CALL ...)
# In the function jrl_export_package().
function(jrl_dump_package_dependencies_json output)
    get_property(
        package_dependencies_json
        GLOBAL
        PROPERTY _jrl_${PROJECT_NAME}_package_dependencies
    )
    if(NOT package_dependencies_json)
        message(STATUS "No package dependencies recorded with jrl_find_package()")
        return()
    endif()
    message(STATUS "[${PROJECT_NAME}] Dumping package dependencies JSON to ${output}")
    file(WRITE ${output} "${package_dependencies_json}")
endfunction()

# jrl_option(<option_name> <description> <default_value>)
# Example: jrl_option(BUILD_TESTING "Build the tests" ON)
# Override cmake option() to get a nice summary at the end of the configuration step
function(jrl_option option_name description default_value)
    set(options)
    set(oneValueArgs COMPATIBILITY_OPTION)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    option(${option_name} "${description}" ${default_value})

    if(arg_COMPATIBILITY_OPTION)
        set_property(
            GLOBAL
            PROPERTY
                _jrl_${PROJECT_NAME}_option_${option_name}_compat_option ${arg_COMPATIBILITY_OPTION}
        )
        if(DEFINED ${arg_COMPATIBILITY_OPTION})
            message(
                WARNING
                "Option ${arg_COMPATIBILITY_OPTION} is deprecated. Please use ${option_name} instead."
            )
            set(${option_name} ${${arg_COMPATIBILITY_OPTION}} CACHE BOOL "${description}" FORCE)
        endif()
    endif()

    set_property(
        GLOBAL
        PROPERTY _jrl_${PROJECT_NAME}_option_${option_name}_default_value ${default_value}
    )
    set_property(GLOBAL PROPERTY _jrl_${PROJECT_NAME}_option_names ${option_name} APPEND)
endfunction()

# Same as cmake_dependent_option(), but store default value and option name for the jrl_print_options_summary()
# Usage: jrl_cmake_dependent_option(<option_name> <description> <default_value> <condition> <else_value>)
# See official documentation: https://cmake.org/cmake/help/latest/module/CMakeDependentOption.html
function(
    jrl_cmake_dependent_option
    option_name
    description
    default_value
    condition
    else_value
)
    include(CMakeDependentOption)
    cmake_dependent_option(${ARGV})

    set_property(
        GLOBAL
        PROPERTY _jrl_${PROJECT_NAME}_option_${option_name}_default_value ${default_value}
    )
    set_property(GLOBAL PROPERTY _jrl_${PROJECT_NAME}_option_names ${option_name} APPEND)
endfunction()

# Helper function: pad or truncate a string to a fixed width
function(_jrl_pad_string input width output_var)
    string(LENGTH "${input}" _len)
    if(_len GREATER width)
        # Truncate if too long
        string(SUBSTRING "${input}" 0 ${width} _padded)
    else()
        # Pad with spaces until desired width
        math(EXPR _pad "${width} - ${_len}")
        set(_spaces "")
        while(_pad GREATER 0)
            string(APPEND _spaces " ")
            math(EXPR _pad "${_pad} - 1")
        endwhile()
        set(_padded "${input}${_spaces}")
    endif()
    set(${output_var} "${_padded}" PARENT_SCOPE)
endfunction()

# Print all options defined via jrl_option() in a nice table
# Usage: jrl_print_options_summary()
function(jrl_print_options_summary)
    set(log_msg "")

    macro(_log msg)
        string(APPEND log_msg "${msg}\n")
    endmacro()

    get_property(option_names GLOBAL PROPERTY _jrl_${PROJECT_NAME}_option_names)
    if(NOT option_names)
        message(STATUS "No options defined via jrl_option.")
        return()
    endif()

    _log("")
    _log("================= Configuration Summary ==========================================================")
    _log("")

    _jrl_pad_string("Option"      40 _menu_option)
    _jrl_pad_string("Type"        8  _menu_type)
    _jrl_pad_string("Value"       5  _menu_value)
    _jrl_pad_string("Default"     5  _menu_default)
    _jrl_pad_string("Description (default)" 25 _menu_description)
    _log("${_menu_option} | ${_menu_type} | ${_menu_value} | ${_menu_description}")
    _log("--------------------------------------------------------------------------------------------------")

    foreach(option_name ${option_names})
        get_property(_type CACHE ${option_name} PROPERTY TYPE)
        get_property(_val CACHE ${option_name} PROPERTY VALUE)
        get_property(
            _default
            GLOBAL
            PROPERTY _jrl_${PROJECT_NAME}_option_${option_name}_default_value
        )
        get_property(_help CACHE ${option_name} PROPERTY HELPSTRING)
        get_property(
            _compat_option
            GLOBAL
            PROPERTY _jrl_${PROJECT_NAME}_option_${option_name}_compat_option
        )

        _jrl_pad_string("${option_name}"      40 _name)
        _jrl_pad_string("${_type}"     8 _type)
        _jrl_pad_string("${_val}"      5 _val)
        _jrl_pad_string("${_help}"     30 _help)
        _jrl_pad_string("${_default}"  3 _default)

        _log("${_name} | ${_type} | ${_val} | ${_help} (${_default})")
        if(_compat_option)
            _log("  (Compatibility option: ${_compat_option})")
        endif()
    endforeach()

    _log("--------------------------------------------------------------------------------------------------")
    _log("")
    message(STATUS "${log_msg}")
endfunction()

# Shortcut to find Python package and check main variables
# Usage: jrl_find_python([version] [REQUIRED] [COMPONENTS ...])
# Example: jrl_find_python(3.8 REQUIRED COMPONENTS Interpreter Development.Module)
macro(jrl_find_python)
    jrl_find_package(Python ${ARGN})

    # On Windows, Python_SITELIB returns \. Let's convert it to /.
    cmake_path(CONVERT ${Python_SITELIB} TO_CMAKE_PATH_LIST Python_SITELIB NORMALIZE)

    message(STATUS "   Python_FOUND             : ${Python_FOUND}")
    message(STATUS "   Python_EXECUTABLE        : ${Python_EXECUTABLE}")
    message(STATUS "   Python_VERSION           : ${Python_VERSION}")
    message(STATUS "   Python_SITELIB           : ${Python_SITELIB}")
    message(STATUS "   Python_INCLUDE_DIRS      : ${Python_INCLUDE_DIRS}")
    message(STATUS "   Python_LIBRARIES         : ${Python_LIBRARIES}")
    message(STATUS "   Python_SOABI             : ${Python_SOABI}")
    message(STATUS "   Python_NumPy_FOUND       : ${Python_NumPy_FOUND}")
    message(STATUS "   Python_NumPy_VERSION     : ${Python_NumPy_VERSION}")
    message(STATUS "   Python_NumPy_INCLUDE_DIRS: ${Python_NumPy_INCLUDE_DIRS}")
endmacro()

# Shortcut to find the nanobind package
# Usage: jrl_find_nanobind()
macro(jrl_find_nanobind)
    string(REPLACE ";" " " args_pp "${ARGN}")
    jrl_check_var_defined(Python_EXECUTABLE "Python executable not found (variable Python_EXECUTABLE).

    Please call jrl_find_python(<args>) first, e.g.:

        jrl_find_python(3.8 REQUIRED COMPONENTS Interpreter Development.Module)
        jrl_find_package(nanobind ${args_pp})
    "
    )
    unset(args_pp)

    if("REQUIRED" IN_LIST ARGN)
        set(is_required True)
    endif()

    # Detect the installed nanobind package and import it into CMake
    # ref: https://nanobind.readthedocs.io/en/latest/building.html#finding-nanobind
    execute_process(
        COMMAND ${Python_EXECUTABLE} -m nanobind --cmake_dir
        OUTPUT_STRIP_TRAILING_WHITESPACE
        OUTPUT_VARIABLE nanobind_ROOT
        ERROR_VARIABLE nanobind_error
    )

    if(nanobind_error)
        unset(nanobind_ROOT)
    endif()

    if(NOT nanobind_ROOT AND is_required)
        message(
            SEND_ERROR
            "Failed to find nanobind package via 'python -m nanobind --cmake_dir': ${nanobind_error}"
        )
    endif()

    jrl_find_package(nanobind ${ARGN})

    if(nanobind_FOUND)
        if(nanobind_ROOT)
            message(STATUS "   Nanobind CMake Root: ${nanobind_ROOT}")
        endif()

        if(nanobind_DIR)
            # Installed via homebrew on macOS, brew install nanobind
            # This will give /opt/homebrew/share/nanobind/cmake
            message(STATUS "   Nanobind CMake dir: ${nanobind_DIR}")
        endif()
        # If you install nanobind with pip, it will include tsl-robin-map in <nanobind>/ext/robin_map
        # On macOS, brew install nanobind will not include tsl-robin-map, we need to install it via: brew install robin-map
        # Naturally, find_package(nanobind CONFIG REQUIRED) will succeed (nanobind_FOUND -> True), but the tsl-robin-map dependency will be missing, causing build errors.
        # So let's check if the headers are available, otherwise require tsl-robin-map explicitly.
        # UPDATE: fixed in https://github.com/Homebrew/homebrew-core/commit/bf0095fdd7e03bd3239afda4584951ee9305dc40
        # brew install nanobind now includes robin-map as a dependency.
        if(EXISTS "${nanobind_ROOT}/../ext/robin_map/include/tsl/robin_map.h")
            message(
                STATUS
                "   Nanobind's tsl-robin-map dependency found in '${nanobind_ROOT}/ext/robin_map'."
            )
        else()
            jrl_find_package(tsl-robin-map CONFIG REQUIRED)
        endif()
    endif()
endmacro()

# Get the python interpreter path from the Python::Interpreter target
# Usage: jrl_python_get_interpreter(<output_var>)
# Example:
# ```cmake
# jrl_python_get_interpreter(python_interpreter)
# execute_process(COMMAND ${python_interpreter} -c "print('Hello from Python!')")
# ```
function(jrl_python_get_interpreter output_var)
    jrl_check_target_exists(Python::Interpreter
    "
        Python::Interpreter target not found.
        Call (jrl_)find_package(Python REQUIRED COMPONENTS Interpreter) first.
    "
    )
    get_target_property(python_interpreter Python::Interpreter LOCATION)
    set(${output_var} ${python_interpreter} PARENT_SCOPE)
endfunction()

# Compiles all the python files recursively in a given directory, via the compileall module.
# It creates the corresponding .pyc files in __pycache__ folders.
# Usage: jrl_python_compile_all(DIRECTORY <directory> [VERBOSE])
# Example:
# ```cmake
# jrl_python_compile_all(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/my_python_package)
# ```
function(jrl_python_compile_all)
    set(options VERBOSE)
    set(oneValueArgs DIRECTORY)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    jrl_check_var_defined(arg_DIRECTORY)
    jrl_python_get_interpreter(python)

    if(arg_VERBOSE)
        message(STATUS "Compiling all Python files in directory '${arg_DIRECTORY}'")
        # If quiet is False or 0 (the default), the filenames and other information are printed to standard out.
        # Set to 1, only errors are printed. Set to 2, all output is suppressed.
        set(quiet_flag "0")
    else()
        set(quiet_flag "1")
    endif()

    execute_process(
        COMMAND
            ${python} -c
            "import compileall; compileall.compile_dir(r'${arg_DIRECTORY}', workers=0, quiet=${quiet_flag})"
        RESULT_VARIABLE result
        ERROR_VARIABLE error
        OUTPUT_STRIP_TRAILING_WHITESPACE
        WORKING_DIRECTORY ${arg_DIRECTORY}
    )
    if(error)
        message(
            FATAL_ERROR
            "Failed to compile Python files in directory '${arg_DIRECTORY}': ${error}"
        )
    endif()

    if(arg_VERBOSE)
        message(STATUS "Compiling all Python files in directory '${arg_DIRECTORY}'... OK.")
    endif()
endfunction()

# Generates a __init__.py file for a given python module target
# It computes all the relative paths to dlls it needs to add to os.add_dll_directory based on the target's LINK_LIBRARIES
# Usage: jrl_python_generate_init_py(<module_target_name> OUTPUT_PATH <output_path> [TEMPLATE_FILE <template_file>])
# Example:
# ```cmake
# nanobind_add_module(coal_pywrap_nb module.cpp)
# # Link the python module with the main pure c++ shared library 'coal'
# target_link_libraries(coal_pywrap_nb PRIVATE coal)
# jrl_target_set_output_directory(coal_pywrap_nb OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/site-packages/coal)

# jrl_python_generate_init_py(
#     coal_pywrap_nb
#     OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib/site-packages/coal/__init__.py
# )
# ```
# The generated __init__.py will call the os.add_dll_directory(<relative_path/to/coal.dll>)
function(jrl_python_generate_init_py name)
    set(options)
    set(oneValueArgs OUTPUT_PATH TEMPLATE_FILE)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    jrl_check_target_exists(${name})
    jrl_check_var_defined(arg_OUTPUT_PATH)

    if(arg_TEMPLATE_FILE)
        set(template_file ${arg_TEMPLATE_FILE})
    else()
        _jrl_templates_dir(templates_dir)
        set(template_file ${templates_dir}/__init__.py.in)
    endif()

    get_target_property(python_module_link_libraries ${name} LINK_LIBRARIES)
    message(DEBUG "Python module '${name}' link libraries: [${python_module_link_libraries}]")

    set(dlls_to_link "")
    list(REMOVE_DUPLICATES python_module_link_libraries)
    foreach(target IN LISTS python_module_link_libraries)
        get_target_property(target_type ${target} TYPE)
        get_target_property(is_imported ${target} IMPORTED)
        message(
            DEBUG
            "Checking target '${target}' of type '${target_type}' for dll linking. Imported: '${is_imported}'"
        )

        if(
            target_type STREQUAL "SHARED_LIBRARY"
            OR target_type STREQUAL "MODULE_LIBRARY"
            AND NOT ${is_imported}
        )
            message(
                DEBUG
                "    => Adding target '${target}' to dlls to link for python module '${name}'"
            )
            list(APPEND dlls_to_link ${target})
        endif()
    endforeach()

    message(
        DEBUG
        "Python module '${name}' depends on the following buildsystem dlls: [${dlls_to_link}]"
    )

    # Get the relative paths between the python module and each dll
    set(all_rel_paths "")
    foreach(dll_name IN LISTS dlls_to_link)
        get_target_property(python_module_dir ${name} LIBRARY_OUTPUT_DIRECTORY)
        jrl_check_var_defined(python_module_dir "LIBRARY_OUTPUT_DIRECTORY not set for target '${name}', add it using 'set_target_properties(<target> PROPERTIES LIBRARY_OUTPUT_DIRECTORY <dir>)'")

        get_target_property(dll_dir ${dll_name} RUNTIME_OUTPUT_DIRECTORY)
        jrl_check_var_defined(dll_dir)

        file(RELATIVE_PATH rel_path ${python_module_dir} ${dll_dir})
        list(APPEND all_rel_paths ${rel_path})
    endforeach()

    # Final formatting to a Python list
    set(dll_dirs "[")
    foreach(rel_path IN LISTS all_rel_paths)
        string(APPEND dll_dirs "'${rel_path}',")
    endforeach()
    string(REGEX REPLACE ",$" "" dll_dirs "${dll_dirs}")
    string(APPEND dll_dirs "]")

    # Configure the __init__.py with PYTHON_MODULE_NAME and optional dll_dirs
    set(__MODULE_NAME__ "${name}")
    set(__DLL_DIRS__ "${dll_dirs}")
    _jrl_templates_dir(templates_dir)
    configure_file(${templates_dir}/__init__.py.in ${arg_OUTPUT_PATH} @ONLY)
endfunction()

# Find if a python module is available, fills <module_name>_FOUND variable
# Displays messages based on REQUIRED and QUIET options
# Usage: jrl_check_python_module(<module_name> [REQUIRED] [QUIET])
# Example: jrl_check_python_module(numpy REQUIRED)
function(jrl_check_python_module module_name)
    set(options REQUIRED QUIET)
    set(oneValueArgs)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    jrl_python_get_interpreter(python)

    execute_process(
        COMMAND ${python} -c "import ${module_name}"
        RESULT_VARIABLE module_found
        ERROR_QUIET
    )
    if(module_found STREQUAL 0)
        set(${module_name}_FOUND true PARENT_SCOPE)
        if(NOT arg_QUIET)
            message(STATUS "Python module '${module_name}' found.")
        endif()
    else()
        set(${module_name}_FOUND false PARENT_SCOPE)
        if(arg_REQUIRED)
            message(FATAL_ERROR "Required Python module '${module_name}' not found.")
        elseif(NOT arg_QUIET)
            message(WARNING "Python module '${module_name}' not found.")
        endif()
    endif()
endfunction()

# jrl_python_compute_install_dir(<output>)
#
# Compute the installation directory for Python bindings.
#  * If ${PROJECT_NAME}_PYTHON_INSTALL_DIR is defined, its value is used.
#  * Otherwise, if running inside a Conda environment on Windows, an
#    absolute path to `sysconfig.get_path('purelib')` is returned.
#  * In all other cases, the relative path of `purelib` with respect to
#    `sysconfig.get_path('data')` is returned.
#
# Example:
# ```cmake
#   jrl_python_compute_install_dir(python_install_dir)
#   install(TARGETS my_python_module DESTINATION ${python_install_dir} ...)
# ```
function(jrl_python_compute_install_dir output)
    if(DEFINED ${PROJECT_NAME}_PYTHON_INSTALL_DIR)
        message(
            STATUS
            "${PROJECT_NAME}_PYTHON_INSTALL_DIR is defined, using its value: ${${PROJECT_NAME}_PYTHON_INSTALL_DIR} as python install dir"
        )
        set(${output} ${${PROJECT_NAME}_PYTHON_INSTALL_DIR} PARENT_SCOPE)
        return()
    endif()

    jrl_python_get_interpreter(python)

    execute_process(
        COMMAND
            ${python} -c
            "
import sys, os, sysconfig
from pathlib import Path

is_conda = os.path.exists(os.path.join(sys.prefix, 'conda-meta'))
is_windows = sys.platform.startswith('win')

if is_conda and is_windows:
    print(sysconfig.get_path('purelib'))
else:
    print(Path(sysconfig.get_path('purelib')).relative_to(sysconfig.get_path('data')))
"
        OUTPUT_VARIABLE python_install_dir
        ERROR_VARIABLE error
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(error)
        message(
            FATAL_ERROR
            "Error while trying to compute the python binding install dir: ${error}"
        )
    endif()

    # On Windows, convert to CMake path list (backslashes to slashes)
    if(WIN32)
        cmake_path(CONVERT "${python_install_dir}" TO_CMAKE_PATH_LIST python_install_dir)
    endif()

    set(${output} "${python_install_dir}" PARENT_SCOPE)
    message(
        STATUS
        "Computed python install destination ${python_install_dir} (Use install(DESTINATION \${${output}} ...))"
    )
endfunction()

# Check that the python module defined with NB_MODULE(<module_name>)
# or BOOST_PYTHON_MODULE(<module_name>) has the same name as the target: <module_name>.cpython-XY.so
# Otherwise the module will fail to load in Python.
# NOTE: It verifies that the symbol PyInit_<module_name> exists in the built module.
# Usage: jrl_check_python_module_name(<module_target>)
function(jrl_check_python_module_name target)
    jrl_check_target_exists(${target})

    add_custom_command(
        TARGET ${target}
        POST_BUILD
        COMMAND
            ${CMAKE_COMMAND} -DMODULE_FILE=$<TARGET_FILE:${target}> -DEXPECTED_MODULE_NAME=${target}
            -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CheckPythonModuleNameScript.cmake
        COMMENT "Checking 'PyInit_${target}' exists"
        VERBATIM
    )
endfunction()
