# Copyright 2025-2026 Inria

include_guard(GLOBAL)
cmake_minimum_required(VERSION 3.22)

#[============================================================================[
# `_jrl_check_var_defined`

```cpp
_jrl_check_var_defined(
    <var>
    [<message>]
)
```

**Type:** function


### Description
  Checks if a variable is defined. If not, it raises a fatal error with the provided message.


### Arguments
* `var`: The variable to check.
* `message`: Optional error message to display if the variable is not defined.


### Example
```cmake
# Will print "MY_VAR is not defined."
_jrl_check_var_defined(MY_VAR)

# Custom message
_jrl_check_var_defined(MY_VAR "MY_VAR must be set to build this project")
```
#]============================================================================]
function(_jrl_check_var_defined var)
    if(NOT DEFINED ${var})
        if(ARGC EQUAL 1)
            set(msg "Required variable '${ARGV0}' is not defined.")
        else()
            set(msg "${ARGV1}")
        endif()
        message(FATAL_ERROR "${msg}")
    endif()
endfunction()

#[============================================================================[
# `_jrl_check_dir_exists`

```cpp
_jrl_check_dir_exists(<dirpath>)
```

**Type:** function


### Description
  Check if a directory exists, otherwise raise a fatal error.


### Arguments
* `dirpath`: The directory path to check.


### Example
```cmake
_jrl_check_dir_exists(${CMAKE_CURRENT_SOURCE_DIR}/include)
```
#]============================================================================]
function(_jrl_check_dir_exists dirpath)
    if(NOT IS_DIRECTORY ${dirpath})
        message(FATAL_ERROR "Directory '${dirpath}' does not exist.")
    endif()
endfunction()

#[============================================================================[
# `_jrl_check_target_exists`

```cpp
_jrl_check_target_exists(
    <target_name>
    [<message>]
)
```

**Type:** function


### Description
  Check if a target exists, otherwise raise a fatal error.


### Arguments
* `target_name`: The target to check.
* `message`: Optional error message to display if the target does not exist.


### Example
```cmake
_jrl_check_target_exists(Python::Interpreter)
_jrl_check_target_exists(Python::Interpreter "Call find_package(Python REQUIRED COMPONENTS Interpreter) first.")
```
#]============================================================================]
function(_jrl_check_target_exists target_name)
    if(NOT TARGET ${target_name})
        if(ARGC EQUAL 1)
            set(msg "Target '${target_name}' does not exist.")
        else()
            set(msg "${ARGV1}")
        endif()
        message(FATAL_ERROR "${msg}")
    endif()
endfunction()

#[============================================================================[
# `_jrl_check_command_exists`

```cpp
_jrl_check_command_exists(
    <command_name>
    [<message>]
)
```

**Type:** function


### Description
  Check if a command exists, otherwise raise a fatal error.


### Arguments
* `command_name`: The command to check.
* `message`: Optional error message to display if the command does not exist.


### Example
```cmake
_jrl_check_command_exists(nanobind_add_stubs)
_jrl_check_command_exists(nanobind_add_stubs "nanobind_add_stubs command not found. Call find_package(nanobind 2.5.0 REQUIRED) first.")
```
#]============================================================================]
function(_jrl_check_command_exists command_name)
    if(NOT COMMAND ${command_name})
        if(ARGC EQUAL 1)
            set(msg "Command '${command_name}' does not exist.")
        else()
            set(msg "${ARGV1}")
        endif()
        message(FATAL_ERROR "${msg}")
    endif()
endfunction()

#[============================================================================[
# `_jrl_check_valid_visibility`

```cpp
_jrl_check_valid_visibility(<visibility>)
```

**Type:** function


### Description
  Check if the visibility argument is valid (PRIVATE, PUBLIC or INTERFACE).
  Otherwise raise a fatal error.


### Arguments
* `visibility`: The visibility keyword to check.


### Example
```cmake
set(visibility PRIVATE)
_jrl_check_valid_visibility(${visibility})
```
#]============================================================================]
function(_jrl_check_valid_visibility visibility)
    set(vs PRIVATE PUBLIC INTERFACE)
    if(NOT ${visibility} IN_LIST vs)
        message(
            FATAL_ERROR
            "visibility (${visibility}) must be one of PRIVATE, PUBLIC or INTERFACE"
        )
    endif()
endfunction()

#[============================================================================[
# `_jrl_check_file_exists`

```cpp
_jrl_check_file_exists(
    <filepath>
    [<message>]
)
```

**Type:** function


### Description
  Check if a file exists, otherwise raise a fatal error.


### Arguments
* `filepath`: The file path to check.
* `message`: Optional error message to display if the file does not exist.


### Example
```cmake
_jrl_check_file_exists(${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt)
```
#]============================================================================]
function(_jrl_check_file_exists filepath)
    if(NOT EXISTS ${filepath})
        if(ARGC EQUAL 1)
            set(msg "File '${filepath}' does not exist.")
        else()
            set(msg "${ARGV1}")
        endif()
        message(FATAL_ERROR "${msg}")
    endif()
endfunction()

#[============================================================================[
# `_jrl_top_dir`

```cpp
_jrl_top_dir(<output_var>)
```

**Type:** function


### Description
  Get the top-level directory of the jrl-cmakemodules v2 repository.


### Arguments
* `output_var`: Variable to store the top-level directory path.


### Example
```cmake
_jrl_top_dir(TOP_DIR)
```
#]============================================================================]
function(_jrl_top_dir output_var)
    cmake_path(CONVERT "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.." TO_CMAKE_PATH_LIST top_dir NORMALIZE)
    # remove trailing slash if any
    string(REGEX REPLACE "/$" "" top_dir "${top_dir}")
    _jrl_check_dir_exists(${top_dir})
    set(${output_var} ${top_dir} PARENT_SCOPE)
endfunction()

#[============================================================================[
# `_jrl_templates_dir`

```cpp
_jrl_templates_dir(<output_var>)
```

**Type:** function


### Description
  Get the templates directory of the jrl-cmakemodules v2 repository.


### Arguments
* `output_var`: Variable to store the templates directory path.


### Example
```cmake
_jrl_templates_dir(TEMPLATES_DIR)
```
#]============================================================================]
function(_jrl_templates_dir output_var)
    _jrl_top_dir(top_dir)
    set(templates_dir ${top_dir}/templates)
    _jrl_check_dir_exists(${templates_dir})
    set(${output_var} ${templates_dir} PARENT_SCOPE)
endfunction()

#[============================================================================[
# `_jrl_docs_dir`

```cpp
_jrl_docs_dir(<output_var>)
```

**Type:** function


### Description
  Get the docs directory of the jrl-cmakemodules v2 repository.


### Arguments
* `output_var`: Variable to store the docs directory path.


### Example
```cmake
_jrl_docs_dir(docs_dir)
```
#]============================================================================]
function(_jrl_docs_dir output_var)
    _jrl_top_dir(top_dir)
    set(docs_dir ${top_dir}/docs)
    _jrl_check_dir_exists(${docs_dir})
    set(${output_var} ${docs_dir} PARENT_SCOPE)
endfunction()

#[============================================================================[
# `_jrl_external_modules_dir`

```cpp
_jrl_external_modules_dir(<output_var>)
```

**Type:** function


### Description
  Get the external-modules directory of the jrl-cmakemodules v2 repository.


### Arguments
* `output_var`: Variable to store the external-modules directory path.


### Example
```cmake
_jrl_external_modules_dir(EXTERNAL_MODULES_DIR)
```
#]============================================================================]
function(_jrl_external_modules_dir output_var)
    _jrl_top_dir(top_dir)
    set(external_modules_dir ${top_dir}/external-modules)
    _jrl_check_dir_exists(${external_modules_dir})
    set(${output_var} ${external_modules_dir} PARENT_SCOPE)
endfunction()

#[============================================================================[
# `_jrl_find_modules_dir`

```cpp
_jrl_find_modules_dir(<output_var>)
```

**Type:** function


### Description
  Get the find-modules directory of the jrl-cmakemodules v2 repository.


### Arguments
* `output_var`: Variable to store the find-modules directory path.


### Example
```cmake
_jrl_find_modules_dir(FIND_MODULES_DIR)
```
#]============================================================================]
function(_jrl_find_modules_dir output_var)
    _jrl_top_dir(top_dir)
    set(find_modules_dir ${top_dir}/find-modules)
    _jrl_check_dir_exists(${find_modules_dir})
    set(${output_var} ${find_modules_dir} PARENT_SCOPE)
endfunction()

#[============================================================================[
# `_jrl_integrate_modules`

```cpp
_jrl_integrate_modules()
```

**Type:** function


### Description
  Internal function to integrate external modules and other logic.
  It is called automatically when the module is loaded.


### Arguments
  None


### Example
```cmake
_jrl_integrate_modules()
```
#]============================================================================]
function(_jrl_integrate_modules)
    include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/PrintSystemInfo.cmake)
endfunction()

_jrl_integrate_modules()

#[============================================================================[
# `jrl_copy_compile_commands_in_source_dir`

```cpp
jrl_copy_compile_commands_in_source_dir()
```

**Type:** function


### Description
  Copy compile_commands.json from the binary dir to the upper source directory for clangd support.
  This is only useful when the build directory is not <source_dir>/build.


### Arguments
  None


### Example
```cmake
jrl_copy_compile_commands_in_source_dir()
```
#]============================================================================]
function(jrl_copy_compile_commands_in_source_dir)
    set(source ${CMAKE_BINARY_DIR}/compile_commands.json)
    set(destination ${CMAKE_SOURCE_DIR}/compile_commands.json)

    if(CMAKE_EXPORT_COMPILE_COMMANDS AND EXISTS ${source})
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E copy_if_different ${source} ${destination}
        )
    endif()
endfunction()

#[============================================================================[
# `jrl_configure_copy_compile_commands_in_source_dir`

```cpp
jrl_configure_copy_compile_commands_in_source_dir()
```

**Type:** function


### Description
  Configure copy of compile_commands.json to source directory at end of configuration step.


### Arguments
  None


### Example
```cmake
jrl_configure_copy_compile_commands_in_source_dir()
```
#]============================================================================]
function(jrl_configure_copy_compile_commands_in_source_dir)
    cmake_language(DEFER DIRECTORY ${CMAKE_SOURCE_DIR} GET_CALL_IDS _ids)
    set(call_id 03e6a81d-6918-4da7-a4f4-a3dd74f61cef)
    if(NOT _ids OR NOT ${call_id} IN_LIST _ids)
        message(
            DEBUG
            "Configuring copy of compile_commands.json to source directory (CMAKE_SOURCE_DIR=${CMAKE_SOURCE_DIR}) at end of configuration step."
        )
        cmake_language(
            DEFER ID ${call_id} DIRECTORY ${CMAKE_SOURCE_DIR}
            CALL jrl_copy_compile_commands_in_source_dir
            ()
        )
    endif()
endfunction()

#[============================================================================[
# `_jrl_log_clear`

```cpp
_jrl_log_clear()
```

**Type:** function


### Description
  Clear the current log buffer.


### Arguments
  None


### Example
```cmake
_jrl_log_clear()
```
#]============================================================================]
function(_jrl_log_clear)
    set_property(GLOBAL PROPERTY _jrl_log_messages "")
endfunction()

#[============================================================================[
# `_jrl_log`

```cpp
_jrl_log(<msg>)
```

**Type:** function


### Description
  Log a message to the internal log buffer.
  Does not print anything to the console.


### Arguments
* `msg`: The message to log.


### Example
```cmake
_jrl_log("Something happened")
```
#]============================================================================]
function(_jrl_log msg)
    get_property(existing_msgs GLOBAL PROPERTY _jrl_log_messages)
    string(APPEND existing_msgs "${msg}\n")
    set_property(GLOBAL PROPERTY _jrl_log_messages "${existing_msgs}")
endfunction()

#[============================================================================[
# `_jrl_log_get`

```cpp
_jrl_log_get(<output_var>)
```

**Type:** function


### Description
  Get the current log buffer.


### Arguments
* `output_var`: Variable to store the log buffer content.


### Example
```cmake
_jrl_log_get(LOG_MSGS)
```
#]============================================================================]
function(_jrl_log_get output_var)
    get_property(log_msgs GLOBAL PROPERTY _jrl_log_messages)
    set(${output_var} "${log_msgs}" PARENT_SCOPE)
endfunction()

#[============================================================================[
# `jrl_include_ctest`

```cpp
jrl_include_ctest()
```

**Type:** macro


### Description
  Include CTest but simply prevent adding a lot of useless targets. Useful for IDEs.


### Arguments
  None


### Example
```cmake
jrl_include_ctest()
```
#]============================================================================]
macro(jrl_include_ctest)
    set_property(GLOBAL PROPERTY CTEST_TARGETS_ADDED 1)
    include(CTest)
endmacro()

#[============================================================================[
# `jrl_cmakemodules_get_version`

```cpp
jrl_cmakemodules_get_version(<output_var>)
```

**Type:** function


### Description
  Get the version of the jrl-cmakemodules package (via the jrl-cmakemodules_VERSION variable).


### Arguments
* `output_var`: Variable to store the version string.


### Example
```cmake
jrl_cmakemodules_get_version(v)
message(STATUS "jrl-cmakemodules version: ${v}")
```
#]============================================================================]
function(jrl_cmakemodules_get_version output_var)
    _jrl_check_var_defined(jrl-cmakemodules_VERSION
        "jrl-cmakemodules_VERSION variable is not defined."
        "It is defined when adding the top-level jrl-cmakemodules project or when found via find_package."
    )
    set(${output_var} ${jrl-cmakemodules_VERSION} PARENT_SCOPE)
endfunction()

#[============================================================================[
# `jrl_cmakemodules_get_commit`

```cpp
jrl_cmakemodules_get_commit(<output_var>)
```

**Type:** function


### Description
  Get the git commit hash of the jrl-cmakemodules repository, if available.


### Arguments
* `output_var`: Variable to store the commit hash.


### Example
```cmake
jrl_cmakemodules_get_commit(commit)
message(STATUS "jrl-cmakemodules commit: ${commit}")
```
#]============================================================================]
function(jrl_cmakemodules_get_commit output_var)
    find_program(GIT git QUIET)

    if(NOT GIT)
        message(DEBUG "Git executable not found, cannot get jrl-cmakemodules commit hash.")
        return()
    endif()

    _jrl_top_dir(top_dir)

    execute_process(
        COMMAND ${GIT} rev-parse HEAD
        WORKING_DIRECTORY ${top_dir}
        OUTPUT_VARIABLE git_commit
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )

    # It might not be a git repository (e.g. downloaded zip archive)
    if(NOT git_commit)
        message(DEBUG "Could not get jrl-cmakemodules commit hash.")
        return()
    endif()

    set(${output_var} ${git_commit} PARENT_SCOPE)
endfunction()

#[============================================================================[
# `jrl_print_banner`

```cpp
jrl_print_banner()
```

**Type:** function


### Description
  Print a banner with the jrl-cmakemodules version and some info.


### Arguments
  None


### Example
```cmake
jrl_print_banner()
```
#]============================================================================]
function(jrl_print_banner)
    jrl_cmakemodules_get_version(v)
    jrl_cmakemodules_get_commit(commit)
    if(commit)
        set(commit_msg "(commit: ${commit})")
    endif()

    message(
        STATUS
        "
        🚧 Welcome to JRL CMake Modules v${v} ${commit_msg}
        🚧 Loaded from: ${CMAKE_CURRENT_FUNCTION_LIST_FILE}
        🚧 This version is still under heavy development.
        🚧 API may change without notice.
    "
    )
endfunction()

#[============================================================================[
# `jrl_configure_default_build_type`

```cpp
jrl_configure_default_build_type(<build_type>)
```

**Type:** function


### Description
  Configures the default build type if none is specified.
  Usual values for <build_type> are: Debug, Release, MinSizeRel, RelWithDebInfo.


### Arguments
* `build_type`: The default build type to set.


### Example
```cmake
jrl_configure_default_build_type(RelWithDebInfo)
```
#]============================================================================]
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

#[============================================================================[
# `jrl_configure_default_binary_dirs`

```cpp
jrl_configure_default_binary_dirs()
```

**Type:** function


### Description
  Configures the default output directory for binaries and libraries.


### Arguments
  None


### Example
```cmake
jrl_configure_default_binary_dirs()
```
#]============================================================================]
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

#[============================================================================[
# `jrl_target_set_output_directory`

```cpp
jrl_target_set_output_directory(
    <target_name>
    OUTPUT_DIRECTORY <dir>
)
```

**Type:** function


### Description
  This function configures the `ARCHIVE_OUTPUT_DIRECTORY`,
  `LIBRARY_OUTPUT_DIRECTORY`, and `RUNTIME_OUTPUT_DIRECTORY` properties
  for the specified target.
  This is useful for python modules that need to be placed in a specific directory.


### Arguments
* `target_name`: The target to configure.
* `OUTPUT_DIRECTORY`: The directory where to put the output artifacts.


### Example
```cmake
jrl_target_set_output_directory(my_python_module_target OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/site-packages)
```
#]============================================================================]
function(jrl_target_set_output_directory target_name)
    set(options)
    set(oneValueArgs OUTPUT_DIRECTORY)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    _jrl_check_target_exists(${target_name})
    _jrl_check_var_defined(arg_OUTPUT_DIRECTORY)

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

#[============================================================================[
# `jrl_configure_default_install_dirs`

```cpp
jrl_configure_default_install_dirs()
```

**Type:** function


### Description
  Configures the default install directories using GNUInstallDirs (bin, lib, include, etc.).
  Works on all platforms.


### Arguments
  None


### Example
```cmake
jrl_configure_default_install_dirs()
```
#]============================================================================]
function(jrl_configure_default_install_dirs)
    include(GNUInstallDirs)
endfunction()

#[============================================================================[
# `jrl_configure_default_install_prefix`

```cpp
jrl_configure_default_install_prefix(<default_install_prefix>)
```

**Type:** function


### Description
  If not provided by the user, set a default CMAKE_INSTALL_PREFIX. Useful for IDEs.


### Arguments
* `default_install_prefix`: The default install prefix to set.


### Example
```cmake
jrl_configure_default_install_prefix(/opt/my_project)
```
#]============================================================================]
function(jrl_configure_default_install_prefix default_install_prefix)
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        message(STATUS "Setting default install prefix to '${default_install_prefix}'")
        set(CMAKE_INSTALL_PREFIX
            ${default_install_prefix}
            CACHE PATH
            "Install path prefix, prepended onto relative install directories."
            FORCE
        )
        mark_as_advanced(CMAKE_INSTALL_PREFIX)
    endif()
endfunction()

#[============================================================================[
# `jrl_configure_uninstall_target`

```cpp
jrl_configure_uninstall_target()
```

**Type:** function


### Description
  Setup an uninstall target that can be used to uninstall the project.
  It will create a cmake_uninstall.cmake script next to the cmake_install.cmake script in the build directory.


### Arguments
  None


### Example
```cmake
jrl_configure_uninstall_target()
# And then cmake --build . --target uninstall
```
#]============================================================================]
function(jrl_configure_uninstall_target)
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

#[============================================================================[
# `jrl_configure_defaults`

```cpp
jrl_configure_defaults()
```

**Type:** function


### Description
  Setup the default options for a project (opinionated defaults).


### Arguments
  None


### Example
```cmake
jrl_configure_defaults()
```
#]============================================================================]
function(jrl_configure_defaults)
    jrl_configure_default_build_type(Release)
    jrl_configure_default_binary_dirs()
    jrl_configure_default_install_dirs()
    jrl_configure_default_install_prefix(${CMAKE_BINARY_DIR}/install)
    jrl_configure_copy_compile_commands_in_source_dir()
    jrl_configure_uninstall_target()
endfunction()

#[============================================================================[
# `jrl_get_cxx_compiler_id`

```cpp
jrl_get_cxx_compiler_id(<output_var>)
```

**Type:** function


### Description
  Get the CMAKE_CXX_COMPILER_ID variable, but also handles clang-cl and AppleClang exceptions.
  clang-cl is considered as MSVC, AppleClang as Clang.


### Arguments
* `output_var`: Variable to store the compiler ID.


### Example
```cmake
jrl_get_cxx_compiler_id(cxx_compiler_id)
message(STATUS "Compiler ID: ${cxx_compiler_id}")
```
#]============================================================================]
function(jrl_get_cxx_compiler_id output_var)
    _jrl_check_var_defined(CMAKE_CXX_COMPILER_ID)

    if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT)
        set(cxx_compiler_id ${CMAKE_CXX_COMPILER_FRONTEND_VARIANT})
        set(${output_var} ${cxx_compiler_id} PARENT_SCOPE)
        return()
    endif()

    if(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
        set(cxx_compiler_id "Clang")
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC")
        set(cxx_compiler_id "MSVC")
    else()
        set(cxx_compiler_id ${CMAKE_CXX_COMPILER_ID})
    endif()

    set(${output_var} ${cxx_compiler_id} PARENT_SCOPE)
endfunction()

#[============================================================================[
# `jrl_target_set_default_compile_options`

```cpp
jrl_target_set_default_compile_options(
    <target_name>
    <visibility>
)
```

**Type:** function


### Description
  Enable the most common warnings for MSVC, GCC and Clang.
  Adding some extra warning on msvc to mimic gcc/clang behavior.


### Arguments
* `target_name`: The target to modify.
* `visibility`: PRIVATE, PUBLIC or INTERFACE.


### Example
```cmake
jrl_target_set_default_compile_options(my_target INTERFACE)
```
#]============================================================================]
function(jrl_target_set_default_compile_options target_name visibility)
    _jrl_check_target_exists(${target_name})
    _jrl_check_valid_visibility(${visibility})

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

#[============================================================================[
# `jrl_target_enforce_msvc_conformance`

```cpp
jrl_target_enforce_msvc_conformance(
    <target_name>
    <visibility>
)
```

**Type:** function


### Description
  Enforce MSVC c++ conformance mode so msvc behaves more like gcc and clang.
  If the compiler id is not MSVC, this function does nothing.


### Arguments
* `target_name`: The target to modify.
* `visibility`: PRIVATE, PUBLIC or INTERFACE.


### Example
```cmake
jrl_target_enforce_msvc_conformance(my_target INTERFACE)
```
#]============================================================================]
function(jrl_target_enforce_msvc_conformance target_name visibility)
    _jrl_check_valid_visibility(${visibility})

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

#[============================================================================[
# `jrl_target_treat_all_warnings_as_errors`

```cpp
jrl_target_treat_all_warnings_as_errors(
    <target_name>
    <visibility>
)
```

**Type:** function


### Description
  Treat all warnings as errors for a targets (/WX for MSVC, -Werror for GCC/Clang).
  Can be disabled on the cmake cli with --compile-no-warning-as-error.


### Arguments
* `target_name`: The target to modify.
* `visibility`: PRIVATE, PUBLIC or INTERFACE.


### Example
```cmake
jrl_target_treat_all_warnings_as_errors(my_target PRIVATE)
```
#]============================================================================]
function(jrl_target_treat_all_warnings_as_errors target_name visibility)
    _jrl_check_valid_visibility(${visibility})

    jrl_get_cxx_compiler_id(cxx_compiler_id)

    if(cxx_compiler_id STREQUAL "MSVC")
        target_compile_options(${target_name} ${visibility} /WX)
    elseif(cxx_compiler_id STREQUAL "GNU" OR cxx_compiler_id STREQUAL "Clang")
        target_compile_options(${target_name} ${visibility} -Werror)
    else()
        message(WARNING "Unknown compiler '${cxx_compiler_id}'. No warning as error flag set.")
    endif()
endfunction()

#[============================================================================[
# `_jrl_make_valid_c_identifier`

```cpp
_jrl_make_valid_c_identifier(<input_str> <output_var>)
```

**Type:** function


### Description
  Creates a valid C identifier from an input string.
  1. Replace all non-alphanumeric and non-underscore characters with underscores.
  2. If it starts with a digit, prefix with underscore.
  3. Collapse multiple consecutive underscores.
  4. Remove trailing underscores.


### Arguments
* `input_str`: The input string.
* `output_var`: The variable to store the result.


### Example
```cmake
_jrl_make_valid_c_identifier("my-lib.v1" ID)
# ID is "my_lib_v1"
```
#]============================================================================]
function(_jrl_make_valid_c_identifier input_str output_var)
    string(REGEX REPLACE "[^A-Za-z0-9_]" "_" ci "${input_str}")

    string(REGEX MATCH "^[0-9]" STARTS_WITH_DIGIT "${ci}")
    if(STARTS_WITH_DIGIT)
        set(ci "_${ci}")
    endif()
    string(REGEX REPLACE "_+" "_" ci "${ci}")
    string(REGEX REPLACE "_$" "" ci "${ci}")

    set(${output_var} "${ci}" PARENT_SCOPE)
endfunction()

#[============================================================================[
# `_jrl_normalize_version`

```cpp
_jrl_normalize_version(
    <version_str>
    [VERSION_FULL <var>]
    [VERSION_FULL_WITH_TWEAK <var>]
    [VERSION_MAJOR <var>]
    [VERSION_MINOR <var>]
    [VERSION_PATCH <var>]
    [VERSION_TWEAK <var>]
)
```

**Type:** function


### Description
    Normalizes a version string into a 3 and 4-component version string (major.minor.patch.tweak),
    padding with zeros if necessary. It handles version strings with suffixes by extracting
    only the leading numeric part.
    Stops at the first non-numeric/non-dot character (like '-' in '-rc1').


### Arguments
    version_str: The version string to normalize.
    VERSION_FULL: Variable to store the normalized version without tweak (major.minor.patch).
    VERSION_FULL_WITH_TWEAK: Variable to store the full version with tweak (major.minor.patch.tweak).
    VERSION_MAJOR: Variable to store the major version component.
    VERSION_MINOR: Variable to store the minor version component.
    VERSION_PATCH: Variable to store the patch version component.
    VERSION_TWEAK: Variable to store the tweak version component.


### Example
```cmake
_jrl_normalize_version("1.2.3" normalized_version)
# Examples:
# 1.2.3       -> 1.2.3.0
# 1.2         -> 1.2.0.0
# 4           -> 4.0.0.0
# 1.0.5.2023  -> 1.0.5.2023
# ""          -> 0.0.0.0
# 2.5-rc1     -> 2.5.0.0
```
#]============================================================================]
function(_jrl_normalize_version version_str)
    set(options)
    set(oneValueArgs
        VERSION_FULL
        VERSION_FULL_WITH_TWEAK
        VERSION_MAJOR
        VERSION_MINOR
        VERSION_PATCH
        VERSION_TWEAK
    )
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    string(REGEX MATCH "^[0-9.]+" clean_version "${version_str}")

    string(REPLACE "." ";" version_comp "${clean_version}")

    list(LENGTH version_comp len)

    if(len GREATER 0)
        list(GET version_comp 0 major)
    else()
        set(major 0)
    endif()

    if(len GREATER 1)
        list(GET version_comp 1 minor)
    else()
        set(minor 0)
    endif()

    if(len GREATER 2)
        list(GET version_comp 2 patch)
    else()
        set(patch 0)
    endif()

    if(len GREATER 3)
        list(GET version_comp 3 tweak)
    else()
        set(tweak 0)
    endif()

    set(version_full "${major}.${minor}.${patch}")
    set(version_full_with_tweak "${major}.${minor}.${patch}.${tweak}")

    if(arg_VERSION_MAJOR)
        set(${arg_VERSION_MAJOR} ${major} PARENT_SCOPE)
    endif()

    if(arg_VERSION_MINOR)
        set(${arg_VERSION_MINOR} ${minor} PARENT_SCOPE)
    endif()

    if(arg_VERSION_PATCH)
        set(${arg_VERSION_PATCH} ${patch} PARENT_SCOPE)
    endif()

    if(arg_VERSION_TWEAK)
        set(${arg_VERSION_TWEAK} ${tweak} PARENT_SCOPE)
    endif()

    if(arg_VERSION_FULL)
        set(${arg_VERSION_FULL} ${version_full} PARENT_SCOPE)
    endif()

    if(arg_VERSION_FULL_WITH_TWEAK)
        set(${arg_VERSION_FULL_WITH_TWEAK} ${version_full_with_tweak} PARENT_SCOPE)
    endif()
endfunction()

#[============================================================================[
# `_jrl_target_generate_header`

```cpp
_jrl_target_generate_header(
    <target_name>
    <visibility>
    FILENAME <header_name>
    TEMPLATE_FILE <template_file>
    [LIBRARY_NAME <library_name>]
    [GEN_DIR <gen_dir>]
    [INSTALL_DESTINATION <install_destination>]
    [TEMPLATE_VARIABLES <var1> <var2> ...]
    [SKIP_INSTALL]
)
```

**Type:** function


### Description
    Same as configure_file, but for target-specific generated headers.
    The generated header is added to the target's include directories and scheduled for installation
    (unless SKIP_INSTALL is specified).


### Arguments
* `target_name`: The target to which the header belongs.
* `visibility`: Visibility scope (PRIVATE, PUBLIC, INTERFACE).
* `FILENAME`: The relative path/name of the generated header (e.g., "my_project/my_header.hpp").
                  Must be a relative path. This determines how the file is included (e.g., #include <FILENAME>).
                  Default: <LIBRARY_NAME>/<header_filename>.hpp
* `TEMPLATE_FILE`: Path to the template file.
* `LIBRARY_NAME`: Name of the library. Used to create valid C identifiers.
                   LIBRARY_NAME will be used to create JRL_LIBRARY_NAME and JRL_LIBRARY_NAME_UPPERCASE variables for the template.
                   Default: <target_name>.
* `GEN_DIR`: Directory where the header is generated (default: ${CMAKE_CURRENT_BINARY_DIR}/generated/include).
              GEN_DIR will be added to the target's include directories with the specified visibility.
* `INSTALL_DESTINATION`: Install destination (default: ${CMAKE_INSTALL_INCLUDEDIR}).
* `TEMPLATE_VARIABLES`: List of variables to be expanded in the template (they must be defined in the calling scope).
* `SKIP_INSTALL`: Do not install the generated header.


### Example
```cmake
_jrl_target_generate_header(mylib PUBLIC
    FILENAME my_project/my_header.hh
    TEMPLATE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/templates/my_header.hpp.in
    LIBRARY_NAME my_project
    TEMPLATE_VARIABLES "VAR1;VAR2"
    INSTALL_DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
```
#]============================================================================]
function(_jrl_target_generate_header target_name visibility)
    set(options SKIP_INSTALL)
    set(oneValueArgs
        LIBRARY_NAME
        FILENAME
        TEMPLATE_FILE
        INSTALL_DESTINATION
        GEN_DIR
    )
    set(multiValueArgs TEMPLATE_VARIABLES)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _jrl_check_target_exists(${target_name})
    _jrl_check_valid_visibility(${visibility})
    _jrl_check_var_defined(arg_TEMPLATE_FILE)
    _jrl_check_file_exists(${arg_TEMPLATE_FILE})

    if(arg_LIBRARY_NAME)
        set(library_name ${arg_LIBRARY_NAME})
    else()
        set(library_name ${target_name})
    endif()

    _jrl_make_valid_c_identifier(${library_name} JRL_LIBRARY_NAME)
    string(TOUPPER ${JRL_LIBRARY_NAME} JRL_LIBRARY_NAME_UPPERCASE)

    if(arg_TEMPLATE_VARIABLES)
        set(template_variables ${arg_TEMPLATE_VARIABLES})
    else()
        set(template_variables "")
    endif()

    list(APPEND template_variables JRL_LIBRARY_NAME)
    list(APPEND template_variables JRL_LIBRARY_NAME_UPPERCASE)

    if(arg_FILENAME)
        if(IS_ABSOLUTE ${arg_FILENAME})
            message(
                FATAL_ERROR
                "FILENAME argument must be a relative path (ex: mylib/myheader.hpp), got absolute path: ${arg_FILENAME}"
            )
        endif()
        set(header_name ${arg_FILENAME})
    else()
        # Extract header name from template filename
        # Ex: /path/to/header_filename.hpp.in -> header_filename.hpp
        # Ex: header_filename.hpp.in -> header_filename.hpp
        cmake_path(REMOVE_EXTENSION arg_TEMPLATE_FILE LAST_ONLY OUTPUT_VARIABLE header_filepath)
        cmake_path(GET header_filepath FILENAME header_filename)
        set(header_name ${library_name}/${header_filename})
    endif()

    if(arg_GEN_DIR)
        set(gen_dir ${arg_GEN_DIR})
    else()
        set(gen_dir ${CMAKE_CURRENT_BINARY_DIR}/generated/include)
    endif()

    if(arg_INSTALL_DESTINATION)
        set(install_destination ${arg_INSTALL_DESTINATION})
    else()
        _jrl_check_var_defined(CMAKE_INSTALL_INCLUDEDIR)
        set(install_destination ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(arg_TEMPLATE_VARIABLES)
        foreach(var_name IN LISTS arg_TEMPLATE_VARIABLES)
            set(${var_name} ${${var_name}})
        endforeach()
    endif()

    set(output_filepath ${gen_dir}/${header_name})

    configure_file(${arg_TEMPLATE_FILE} ${output_filepath} @ONLY)

    target_include_directories(${target_name} ${visibility} $<BUILD_INTERFACE:${gen_dir}>)

    if(arg_SKIP_INSTALL)
        return()
    endif()

    jrl_target_headers(${target_name} ${visibility}
        HEADERS ${output_filepath}
        BASE_DIRS ${gen_dir}
        INSTALL_DESTINATION ${install_destination}
    )
endfunction()

#[============================================================================[
# `jrl_target_generate_warning_header`

```cpp
jrl_target_generate_warning_header(
    [<args>...]
)
```

**Type:** function


### Description


### Arguments
    <args>... - Additional arguments passed to _jrl_target_generate_header.


### Example
```cmake
jrl_target_generate_warning_header(my_target PUBLIC
    LIBRARY_NAME mylib
    FILENAME mylib/warning.hh
)
```
#]============================================================================]
function(jrl_target_generate_warning_header)
    _jrl_templates_dir(templates_dir)
    _jrl_target_generate_header(
        ${ARGV}
        TEMPLATE_FILE ${templates_dir}/warning.hpp.in
    )
endfunction()

#[============================================================================[
# `jrl_target_generate_deprecated_header`

```cpp
jrl_target_generate_deprecated_header(
    [<args>...]
)
```

**Type:** function


### Description
    Generate a <library_name>/deprecated.hpp header for a target.


### Arguments
    <args>... - Additional arguments passed to _jrl_target_generate_header.


### Example
```cmake
jrl_target_generate_deprecated_header(my_target PUBLIC
    LIBRARY_NAME mylib
    FILENAME mylib/deprecated.hh
)
```
#]============================================================================]
function(jrl_target_generate_deprecated_header)
    _jrl_templates_dir(templates_dir)
    _jrl_target_generate_header(
        ${ARGV}
        TEMPLATE_FILE ${templates_dir}/deprecated.hpp.in
    )
endfunction()

#[============================================================================[
# `jrl_target_generate_tracy_header`

```cpp
jrl_target_generate_tracy_header(
    [<args>...]
)
```

**Type:** function


### Description
    Generate a <library_name>/tracy.hpp header for a target.


### Arguments
    <args>... - Additional arguments passed to _jrl_target_generate_header.


### Example
```cmake
jrl_target_generate_tracy_header(my_target PUBLIC
    LIBRARY_NAME mylib
    FILENAME mylib/tracy.hh
)
```
#]============================================================================]
function(jrl_target_generate_tracy_header)
    _jrl_templates_dir(templates_dir)
    _jrl_target_generate_header(
        ${ARGV}
        TEMPLATE_FILE ${templates_dir}/tracy.hpp.in
    )
endfunction()

#[============================================================================[
# `jrl_target_generate_config_header`

```cpp
jrl_target_generate_config_header(
    [VERSION <version>]
    [<args>...]
)
```

**Type:** function


### Description
    Generate a config header for a target.
    The generated header is added to the target's include directories and scheduled for installation
    (via jrl_export_package()).


### Arguments
* `VERSION`: The version string to include in the generated header. Otherwise uses the target's VERSION property, and otherwise the PROJECT_VERSION.
    <args>... - Additional arguments passed to _jrl_target_generate_header.



### Example
```cmake
jrl_target_generate_config_header(mylib PUBLIC)
# Will generate mylib/config.hpp. Use with #include "mylib/config.hpp"
# This header will be installed automatically with the mylib target (via jrl_export_package()).

jrl_target_generate_config_header(mylib PRIVATE)
# Will generate mylib/config.hpp. Use with #include "mylib/config.hpp"
# This header will NOT be installed automatically.

jrl_target_generate_config_header(mylib INTERFACE
  LIBRARY_NAME myproject
  VERSION ${PROJECT_VERSION}
)
# Will generate myproject/config.hh. Use with #include "myproject/config.hh"
# Inside you will find MYPROJECT_LIBRARY_VERSION macros (not MYLIB_LIBRARY_VERSION).
```
#]============================================================================]
function(jrl_target_generate_config_header target_name visibility)
    set(options)
    set(oneValueArgs VERSION)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _jrl_check_target_exists(${target_name})
    _jrl_check_valid_visibility(${visibility})

    if(arg_VERSION)
        set(library_version ${arg_VERSION})
    else()
        get_property(library_version TARGET ${target_name} PROPERTY VERSION)
        if(NOT library_version)
            message(
                WARNING
                "Target ${target_name} does not have a VERSION property set, using the project version instead (PROJECT_VERSION=${PROJECT_VERSION}).
            To remove this warning, set the VERSION property on the target using:

                set_target_properties(${target_name} PROPERTIES VERSION \${PROJECT_VERSION})
            "
            )
            set(library_version ${PROJECT_VERSION})
        endif()
    endif()

    _jrl_normalize_version(${library_version}
        VERSION_FULL JRL_LIBRARY_VERSION
        VERSION_MAJOR JRL_LIBRARY_VERSION_MAJOR
        VERSION_MINOR JRL_LIBRARY_VERSION_MINOR
        VERSION_PATCH JRL_LIBRARY_VERSION_PATCH
    )

    set(template_variables
        JRL_LIBRARY_VERSION
        JRL_LIBRARY_VERSION_MAJOR
        JRL_LIBRARY_VERSION_MINOR
        JRL_LIBRARY_VERSION_PATCH
    )

    _jrl_templates_dir(templates_dir)
    _jrl_target_generate_header(${target_name} ${visibility}
        ${ARGN}
        TEMPLATE_FILE ${templates_dir}/config.hpp.in
        TEMPLATE_VARIABLES ${template_variables}
    )
endfunction()

#[============================================================================[
# `_jrl_search_package_module_file`

```cpp
_jrl_search_package_module_file(
    <package_name>
    <output_filepath>
)
```

**Type:** function


### Description
  Searches for a find module named Find<package>.cmake.
  It iterates over the CMAKE_MODULE_PATH and the find-modules directory.
  This function is used to determine which module file was used by jrl_find_package.


### Arguments
* `package_name`: The package name.
* `output_filepath`: Variable to store the found path.


### Example
```cmake
_jrl_search_package_module_file(Eigen module_file)
```
#]============================================================================]
function(_jrl_search_package_module_file package_name output_filepath)
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

#[============================================================================[
# `jrl_find_package`

```cpp
jrl_find_package(
    <PackageName>
    [version]
    [COMPONENTS <comp>...]
    [REQUIRED]
    [MODULE_PATH <path_to_find_module>]
)
```

**Type:** macro


### Description
  Wrapper around CMake's find_package used for dependency tracking and logging.
  It forwards the arguments provided to the standard CMake find_package, while adding some new arguments.
  It records the find_package arguments, the variables created, the imported targets, and the module file used (if any).
  All that info is used for later introspection and analysis. It is very useful for exporting package dependencies (see jrl_export_package()).
  After the jrl_find_package calls, use jrl_print_dependencies_summary() for printing an extensive analysis.


### Arguments
    <PackageName> [<version>] [REQUIRED] [COMPONENTS <components>...] - The same as find_package.
* `MODULE_PATH`: Path to a dir containing a custom Find<PackageName>.cmake module file.


### Example
```cmake
jrl_find_package(Eigen 3.3 REQUIRED)
jrl_find_package(Boost REQUIRED COMPONENTS filesystem system)
```
#]============================================================================]
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
        _jrl_check_file_exists(${module_file}
            "Custom module file provided with MODULE_PATH does not exist: ${module_file}"
        )
    else()
        # search for the module file only if CONFIG is not in the find_package args
        if(NOT "CONFIG" IN_LIST find_package_args)
            _jrl_search_package_module_file(${package_name} module_file)
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
        message(DEBUG "   No new variables detected.")
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

    # Save the information about this package in a json object
    set(package_json "{}")
    string(REPLACE ";" " " find_package_args "${find_package_args}")
    string(JSON package_json SET "${package_json}" "package_name" "\"${package_name}\"")
    string(JSON package_json SET "${package_json}" "find_package_args" "\"${find_package_args}\"")
    string(JSON package_json SET "${package_json}" "package_variables" "\"${package_variables}\"")
    string(JSON package_json SET "${package_json}" "package_targets" "\"${package_targets}\"")
    string(JSON package_json SET "${package_json}" "module_file" "\"${module_file}\"")
    string(JSON deps_length LENGTH "${deps}" "package_dependencies")
    string(JSON deps SET "${deps}" "package_dependencies" ${deps_length} "${package_json}")

    # Save the JSON object in a global property for later use
    # See jrl_print_dependencies_summary, jrl_export_package, etc.
    set_property(GLOBAL PROPERTY _jrl_${PROJECT_NAME}_package_dependencies "${deps}")

    # Unset temporary variables
    # jrl_find_package is a macro, so temporary variables leak into the caller scope
    unset(fp_pp)
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

#[============================================================================[
# `jrl_print_dependencies_summary`

```cpp
jrl_print_dependencies_summary()
```

**Type:** function


### Description
  Print a summary of all dependencies found via jrl_find_package, and some properties of their imported targets.


### Arguments
  None


### Example
```cmake
jrl_print_dependencies_summary()
```
#]============================================================================]
function(jrl_print_dependencies_summary)
    _jrl_log_clear()

    get_property(deps GLOBAL PROPERTY _jrl_${PROJECT_NAME}_package_dependencies)
    if(NOT deps)
        message(STATUS "No dependencies found via jrl_find_package.")
        return()
    endif()

    _jrl_log("")
    _jrl_log("================= External Dependencies ======================================")
    _jrl_log("")

    string(JSON num_deps LENGTH "${deps}" "package_dependencies")
    math(EXPR max_idx "${num_deps} - 1")
    _jrl_log("${num_deps} dependencies declared jrl_find_package: ")
    foreach(i RANGE 0 ${max_idx})
        string(JSON package_name GET "${deps}" "package_dependencies" ${i} "package_name")
        string(JSON package_targets GET "${deps}" "package_dependencies" ${i} "package_targets")

        # Replace ; by , for better readability
        string(REPLACE ";" ", " package_targets_pp "${package_targets}")
        math(EXPR i "${i} + 1")
        _jrl_log("${i}/${num_deps} Package [${package_name}] imported targets [${package_targets_pp}]")

        # Print target properties
        if(package_targets STREQUAL "")
            continue()
        endif()

        set(properties_to_print
            NAME
            ALIASED_TARGET
            TYPE VERSION
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

        foreach(target IN LISTS package_targets)
            _jrl_log("")
            _jrl_log("  Properties for target [${target}]:")

            foreach(prop IN LISTS properties_to_print)
                get_property(is_property_set TARGET ${target} PROPERTY "${prop}" SET)

                if(is_property_set)
                    get_property(property TARGET ${target} PROPERTY "${prop}")

                    # Convert paths containing \ to / (Windows)
                    if(WIN32)
                        cmake_path(CONVERT "${property}" TO_CMAKE_PATH_LIST property NORMALIZE)
                    endif()

                    _jrl_pad_string("${prop}"      40 prop_padded)
                    _jrl_log("    ${prop_padded} = ${property}")
                endif()
            endforeach()
            _jrl_log("")
        endforeach()
    endforeach()

    _jrl_log_get(log_msg)
    message(STATUS "${log_msg}")
endfunction()

#[============================================================================[
# `_jrl_export_dependencies`

```cpp
_jrl_export_dependencies(
    TARGETS <target1...>
    [GEN_DIR <gen_dir>]
    [INSTALL_DESTINATION <destination>]
)
```

**Type:** function


### Description
  This function analyzes the link libraries of the provided targets,
  determines which packages are needed and generates a <export_name>-dependencies.cmake file.


### Arguments
* `TARGETS`: List of targets to analyze.
* `GEN_DIR`: Directory to generate the file.
* `INSTALL_DESTINATION`: Directory to install the file.


### Example
```cmake
_jrl_export_dependencies(TARGETS my_target)
```
#]============================================================================]
function(_jrl_export_dependencies)
    set(options)
    set(oneValueArgs INSTALL_DESTINATION GEN_DIR)
    set(multiValueArgs TARGETS)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _jrl_check_var_defined(arg_TARGETS)

    if(arg_GEN_DIR)
        set(GEN_DIR ${arg_GEN_DIR})
    else()
        set(GEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated/cmake/${PROJECT_NAME})
    endif()

    if(arg_INSTALL_DESTINATION)
        set(INSTALL_DESTINATION ${arg_INSTALL_DESTINATION})
    else()
        _jrl_check_var_defined(CMAKE_INSTALL_LIBDIR)
        set(INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})
    endif()

    # TODO: filter the buildsystems targets of the INTERFACE_LINK_LIBRARIES.
    # First, get a list of all the buildsystem targets, and filter them
    # in generate-dependencies.cmake.in (not here, because of generator expressions).
    # Note that:
    # get_property(buildsystem_targets DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY BUILDSYSTEM_TARGETS)
    # only get the buildsystems targets difined in the current directory. It's difficult to get the full complete list.
    set(all_imported_libraries "")
    foreach(target ${arg_TARGETS})
        get_target_property(interface_link_libraries ${target} INTERFACE_LINK_LIBRARIES)
        if(NOT interface_link_libraries)
            message(DEBUG "Target '${target}' has no INTERFACE_LINK_LIBRARIES.")
            continue()
        endif()
        foreach(lib ${interface_link_libraries})
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
        GENERATE OUTPUT ${GEN_DIR}/imported-libraries.cmake
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

#[============================================================================[
# `jrl_add_export_component`

```cpp
jrl_add_export_component(
    NAME <component_name>
    TARGETS <target1> <target2> ...
)
```

**Type:** function


### Description
  Add an export component with associated targets that will be exported as a CMake package component.
  Each export component will have its own <package>-component-<name>-targets.cmake
  and <package>-component-<name>-dependencies.cmake generated.
  Components are used with: find_package(<package> CONFIG REQUIRED COMPONENTS <component1> <component2> ...)


### Arguments
* `NAME`: The name of the component.
* `TARGETS`: The targets to associate with this component.


### Example
```cmake
jrl_add_export_component(NAME my_component TARGETS my_target)
```
#]============================================================================]
function(jrl_add_export_component)
    set(options)
    set(oneValueArgs NAME)
    set(multiValueArgs TARGETS)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _jrl_check_var_defined(PROJECT_NAME)
    _jrl_check_var_defined(arg_TARGETS)
    _jrl_check_var_defined(arg_NAME)

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

    set_property(GLOBAL PROPERTY _jrl_${PROJECT_NAME}_export_components ${arg_NAME} APPEND)
    set_property(GLOBAL PROPERTY _jrl_${PROJECT_NAME}_${arg_NAME}_targets ${arg_TARGETS})
endfunction()

#[============================================================================[
# `jrl_target_headers`

```cpp
jrl_target_headers(
    <target>
    <visibility>
    HEADERS <list_of_headers>
    [BASE_DIRS <list_of_base_dirs>]
)
```

**Type:** function


### Description
  Declare headers for target to be installed later.
  * This function does not target_include_directories(), only stores them for installation.
  * Only PUBLIC and INTERFACE will be installed.
  * It populates the _jrl_install_headers and _jrl_install_headers_base_dirs properties of the target.
  * In CMake 3.23, we will use FILE_SETS instead of this trick.
  cf: https://cmake.org/cmake/help/latest/command/target_sources.html#file-sets


### Arguments
* `target`: The target.
* `visibility`: Visibility scope (usually PUBLIC or INTERFACE).
* `HEADERS`: List of headers.
* `BASE_DIRS`: List of base dirs (Optional, default is empty).


### Example
```cmake
jrl_target_headers(my_target PUBLIC HEADERS my_header.hpp)
```
#]============================================================================]
function(jrl_target_headers target visibility)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs HEADERS BASE_DIRS)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _jrl_check_var_defined(arg_HEADERS)
    _jrl_check_target_exists(${target})
    _jrl_check_valid_visibility(${visibility})

    # Save the headers in a property of the target
    # NOTE: The PUBLIC_HEADER technically works, but does not support base_dirs
    # cf: https://cmake.org/cmake/help/latest/command/install.html#install
    set_property(TARGET ${target} APPEND PROPERTY _jrl_install_headers "${arg_HEADERS}")
    set_property(TARGET ${target} APPEND PROPERTY _jrl_install_headers_base_dirs "${arg_BASE_DIRS}")
endfunction()

#[============================================================================[
# `jrl_target_install_headers`

```cpp
jrl_target_install_headers(
    <target>
    [DESTINATION <destination>]
)
```

**Type:** function


### Description
  Install declared header for a given target and solve the relative path using the provided base dirs.
  It is using the _jrl_install_headers and _jrl_install_headers_base_dirs properties set via jrl_target_headers().
  For a whole project, use jrl_install_headers() instead (which calls this function for each component, that contains targets).


### Arguments
* `target`: The target.
* `DESTINATION`: Install destination (Optional, default is CMAKE_INSTALL_INCLUDEDIR).


### Example
```cmake
jrl_target_install_headers(my_target)
```
#]============================================================================]
function(jrl_target_install_headers target)
    set(options)
    set(oneValueArgs DESTINATION)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _jrl_check_target_exists(${target})

    if(arg_DESTINATION)
        set(install_destination ${arg_DESTINATION})
    else()
        _jrl_check_var_defined(CMAKE_INSTALL_INCLUDEDIR)
        set(install_destination ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    get_target_property(headers ${target} _jrl_install_headers)
    get_target_property(base_dirs ${target} _jrl_install_headers_base_dirs)

    if(NOT headers)
        message(DEBUG "No headers declared for target '${target}'. Skipping installation.")
        return()
    endif()

    install(
        CODE
            "
# Generated file - do not edit
# This file contains the list of headers declared for target '${target}' with visibility '${visibility}'
set(headers \"${headers}\")
set(base_dirs \"${base_dirs}\")
foreach(header \${headers})
    foreach(base_dir \${base_dirs})
        string(FIND \${header} \${base_dir} pos)
        if(pos EQUAL 0)
            string(REPLACE \${base_dir} \"\" relative_header_path \${header})
            string(REGEX REPLACE \"^/\" \"\" relative_header_path \${relative_header_path})
            break()
        endif()
    endforeach()

    if(IS_ABSOLUTE \${header})
        set(header_path \${header})
    else()
        set(header_path ${CMAKE_CURRENT_SOURCE_DIR}/\${header})
    endif()

    if(relative_header_path)
        cmake_path(GET relative_header_path PARENT_PATH header_dir)
    endif()

    if(IS_ABSOLUTE ${install_destination})
        if(header_dir)
            file(INSTALL DESTINATION \"${install_destination}/\${header_dir}\" TYPE FILE FILES \${header_path})
        else()
            file(INSTALL DESTINATION \"${install_destination}\" TYPE FILE FILES \${header_path})
        endif()
    else()
        if(header_dir)
            file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/${install_destination}/\${header_dir}\" TYPE FILE FILES \${header_path})
        else()
            file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/${install_destination}\" TYPE FILE FILES \${header_path})
        endif()
    endif()
endforeach()
"
    )
endfunction()

#[============================================================================[
# `jrl_install_headers`

```cpp
jrl_install_headers(
    [DESTINATION <destination>]
    [COMPONENTS <component1> <component2> ...]
)
```

**Type:** function


### Description
  For each component, install declared headers for all targets.
  See jrl_target_headers() to declare headers for a target.


### Arguments
* `DESTINATION`: Install destination (Optional, default is CMAKE_INSTALL_INCLUDEDIR).
* `COMPONENTS`: List of components (Optional, default is all declared components).


### Example
```cmake
jrl_install_headers()
```
#]============================================================================]
function(jrl_install_headers)
    set(options)
    set(oneValueArgs DESTINATION)
    set(multiValueArgs COMPONENTS)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _jrl_check_var_defined(PROJECT_NAME)

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

#[============================================================================[
# `jrl_export_package`

```cpp
jrl_export_package(
    [PACKAGE_CONFIG_TEMPLATE <template>]
    [CMAKE_FILES_INSTALL_DIR <dir>]
    [PACKAGE_CONFIG_EXTRA_CONTENT <content>]
)
```

**Type:** function


### Description
  Export the CMake package with all its components (targets, headers, package modules, etc.)
  Generates and installs CMake package configuration files:
   - <INSTALL_DIR>/<package>/<package>-config.cmake
   - <INSTALL_DIR>/<package>/<package>-config-version.cmake
   - <INSTALL_DIR>/<package>/<package>/<componentA>/targets.cmake
   - <INSTALL_DIR>/<package>/<package>/<componentA>/dependencies.cmake
   - <INSTALL_DIR>/<package>/<package>/<componentB>/targets.cmake
   - <INSTALL_DIR>/<package>/<package>/<componentB>/dependencies.cmake
  NOTE: This is for CMake package export only. Python bindings are handled separately.


### Arguments
* `PACKAGE_CONFIG_TEMPLATE`: Custom template for the config file.
* `CMAKE_FILES_INSTALL_DIR`: Directory to install the cmake files.
* `PACKAGE_CONFIG_EXTRA_CONTENT`: Extra content to append to the config file.


### Example
```cmake
jrl_export_package()
```
#]============================================================================]
function(jrl_export_package)
    set(options)
    set(oneValueArgs PACKAGE_CONFIG_TEMPLATE CMAKE_FILES_INSTALL_DIR PACKAGE_CONFIG_EXTRA_CONTENT)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    message(STATUS "[${PROJECT_NAME}] Exporting package (${CMAKE_CURRENT_FUNCTION})")

    include(CMakePackageConfigHelpers)
    _jrl_check_var_defined(PROJECT_NAME)
    _jrl_check_var_defined(PROJECT_VERSION)
    _jrl_check_var_defined(CMAKE_INSTALL_BINDIR)
    _jrl_check_var_defined(CMAKE_INSTALL_LIBDIR)
    _jrl_check_var_defined(CMAKE_INSTALL_INCLUDEDIR)

    if(arg_PACKAGE_CONFIG_TEMPLATE)
        set(package_config_template ${arg_PACKAGE_CONFIG_TEMPLATE})
    else()
        _jrl_templates_dir(templates_dir)
        set(package_config_template ${templates_dir}/config-components.cmake.in)
        set(using_default_template True)
    endif()

    if(arg_CMAKE_FILES_INSTALL_DIR)
        set(cmake_files_install_dir ${arg_CMAKE_FILES_INSTALL_DIR})
    else()
        set(cmake_files_install_dir ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})
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
    set(JRL_PACKAGE_CONFIG_EXTRA_CONTENT ${arg_PACKAGE_CONFIG_EXTRA_CONTENT})
    set(JRL_PROJECT_COMPONENTS ${declared_components})
    configure_package_config_file(
        ${package_config_template}
        ${GEN_DIR}/${PACKAGE_CONFIG_FILENAME}
        INSTALL_DESTINATION ${cmake_files_install_dir}
        ${NO_SET_AND_CHECK_MACRO}
        ${NO_CHECK_REQUIRED_COMPONENTS_MACRO}
    )
    install(FILES ${GEN_DIR}/${PACKAGE_CONFIG_FILENAME} DESTINATION ${cmake_files_install_dir})

    # <package>-config-version.cmake
    write_basic_package_version_file(
        ${GEN_DIR}/${PACKAGE_VERSION_FILENAME}
        VERSION ${PACKAGE_VERSION}
        COMPATIBILITY ${PACKAGE_VERSION_COMPATIBILITY}
        ${PACKAGE_VERSION_ARCH_INDEPENDENT}
    )
    install(FILES ${GEN_DIR}/${PACKAGE_VERSION_FILENAME} DESTINATION ${cmake_files_install_dir})

    foreach(component ${declared_components})
        message(STATUS "Generating cmake module files for component '${component}'")

        get_property(targets GLOBAL PROPERTY _jrl_${PROJECT_NAME}_${component}_targets)

        jrl_target_install_headers(${targets} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

        # <package>/<component>/dependencies.cmake
        _jrl_export_dependencies(
            TARGETS ${targets}
            GEN_DIR ${GEN_DIR}/${component}
            INSTALL_DESTINATION ${cmake_files_install_dir}/${component}
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
            DESTINATION ${cmake_files_install_dir}/${component}
        )
    endforeach()
endfunction()

#[============================================================================[
# `jrl_dump_package_dependencies_json`

```cpp
jrl_dump_package_dependencies_json(<output>)
```

**Type:** function


### Description
  Internal function to dump the package dependencies recorded with jrl_find_package()
  It is called at the end of the configuration step via cmake_language(DEFER CALL ...)
  In the function jrl_export_package().


### Arguments
* `output`: The output file path.


### Example
```cmake
jrl_dump_package_dependencies_json(my_deps.json)
```
#]============================================================================]
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

#[============================================================================[
# `jrl_option`

```cpp
jrl_option(
    <option_name>
    <description>
    <default_value>
    [COMPATIBILITY_OPTION <compat_opt>]
)
```

**Type:** function


### Description
  Override cmake option() to get a nice summary at the end of the configuration step


### Arguments
* `option_name`: The option name.
* `description`: The description.
* `default_value`: The default value (ON/OFF).
* `COMPATIBILITY_OPTION`: An old option name for compatibility.


### Example
```cmake
jrl_option(BUILD_TESTING "Build the tests" ON)
```
#]============================================================================]
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

#[============================================================================[
# `jrl_cmake_dependent_option`

```cpp
jrl_cmake_dependent_option(
    <option_name>
    <description>
    <default_value>
    <condition>
    <else_value>
)
```

**Type:** function


### Description
  Same as cmake_dependent_option(), but store default value and option name for the jrl_print_options_summary()
  See official documentation: https://cmake.org/cmake/help/latest/module/CMakeDependentOption.html


### Arguments
* `option_name`: The option name.
* `description`: The description.
* `default_value`: The default value.
* `condition`: The condition.
* `else_value`: The value if condition is false.


### Example
```cmake
jrl_cmake_dependent_option(USE_FOO "Use Foo" ON "USE_BAR;NOT USE_ZOT" OFF)
```
#]============================================================================]
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

#[============================================================================[
# `_jrl_pad_string`

```cpp
_jrl_pad_string(
    <input>
    <width>
    <output_var>
)
```

**Type:** function


### Description
  Helper function: pad or truncate a string to a fixed width.


### Arguments
* `input`: The input string.
* `width`: The target width.
* `output_var`: The variable to store the result.


### Example
```cmake
_jrl_pad_string("foo" 10 padded_foo)
```
#]============================================================================]
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

#[============================================================================[
# `jrl_print_options_summary`

```cpp
jrl_print_options_summary()
```

**Type:** function


### Description
  Print all options defined via jrl_option() in a nice table.


### Arguments
  None


### Example
```cmake
jrl_print_options_summary()
```
#]============================================================================]
function(jrl_print_options_summary)
    _jrl_log_clear()

    get_property(option_names GLOBAL PROPERTY _jrl_${PROJECT_NAME}_option_names)
    if(NOT option_names)
        message(STATUS "No options defined via jrl_option.")
        return()
    endif()

    _jrl_log("")
    _jrl_log("================= Configuration Summary ==========================================================")
    _jrl_log("")

    _jrl_pad_string("Option"      40 _menu_option)
    _jrl_pad_string("Type"        8  _menu_type)
    _jrl_pad_string("Value"       5  _menu_value)
    _jrl_pad_string("Default"     5  _menu_default)
    _jrl_pad_string("Description (default)" 25 _menu_description)
    _jrl_log("${_menu_option} | ${_menu_type} | ${_menu_value} | ${_menu_description}")
    _jrl_log("--------------------------------------------------------------------------------------------------")

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

        _jrl_log("${_name} | ${_type} | ${_val} | ${_help} (${_default})")
        if(_compat_option)
            _jrl_log("  (Compatibility option: ${_compat_option})")
        endif()
    endforeach()

    _jrl_log("--------------------------------------------------------------------------------------------------")
    _jrl_log("")

    _jrl_log_get(log_msgs)
    message(STATUS "${log_msgs}")
endfunction()

#[============================================================================[
# `jrl_find_python`

```cpp
jrl_find_python(
    [version]
    [REQUIRED]
    [COMPONENTS ...]
)
```

**Type:** macro


### Description
  Shortcut to find Python package and check main variables.


### Arguments
* `version`: Python version.
* `REQUIRED`: If set, the package is required.
* `COMPONENTS`: List of components.


### Example
```cmake
jrl_find_python(3.8 REQUIRED COMPONENTS Interpreter Development.Module)
```
#]============================================================================]
macro(jrl_find_python)
    jrl_find_package(Python ${ARGN})

    # On Windows, Python_SITELIB returns \. Let's convert it to /.
    cmake_path(CONVERT "${Python_SITELIB}" TO_CMAKE_PATH_LIST Python_SITELIB NORMALIZE)

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

#[============================================================================[
# `jrl_find_nanobind`

```cpp
jrl_find_nanobind([<args>...])
```

**Type:** macro


### Description
  Shortcut to find the nanobind package.
  It forwards all arguments to find_package(nanobind ...).


### Arguments
* `args`: Arguments forwarded to find_package(nanobind ...).


### Example
```cmake
jrl_find_nanobind(CONFIG REQUIRED)
jrl_find_nanobind(3.8 CONFIG REQUIRED)
```
#]============================================================================]
macro(jrl_find_nanobind)
    string(REPLACE ";" " " args_pp "${ARGN}")
    _jrl_check_var_defined(Python_EXECUTABLE "Python executable not found (variable Python_EXECUTABLE).

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

#[============================================================================[
# `jrl_python_get_interpreter`

```cpp
jrl_python_get_interpreter(<output_var>)
```

**Type:** function


### Description
  Get the python interpreter path from the Python::Interpreter target.


### Arguments
* `output_var`: The variable to store the path.


### Example
```cmake
jrl_python_get_interpreter(python_interpreter)
execute_process(COMMAND ${python_interpreter} -c "print('Hello from Python!')")
```
#]============================================================================]
function(jrl_python_get_interpreter output_var)
    _jrl_check_target_exists(Python::Interpreter
    "
        Python::Interpreter target not found.
        Call (jrl_)find_package(Python REQUIRED COMPONENTS Interpreter) first.
    "
    )
    get_target_property(python_interpreter Python::Interpreter LOCATION)
    if(WIN32)
        cmake_path(CONVERT "${python_interpreter}" TO_CMAKE_PATH_LIST python_interpreter NORMALIZE)
    endif()
    set(${output_var} ${python_interpreter} PARENT_SCOPE)
endfunction()

#[============================================================================[
# `jrl_python_compile_all`

```cpp
jrl_python_compile_all(
    DIRECTORY <directory>
    [VERBOSE]
)
```

**Type:** function


### Description
  Compiles all the python files recursively in a given directory, via the compileall module.
  It creates the corresponding .pyc files in __pycache__ folders.


### Arguments
* `DIRECTORY`: The directory to compile.
* `VERBOSE`: If set, print more info.


### Example
```cmake
jrl_python_compile_all(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/my_python_package)
```
#]============================================================================]
function(jrl_python_compile_all)
    set(options VERBOSE)
    set(oneValueArgs DIRECTORY)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _jrl_check_var_defined(arg_DIRECTORY)
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

#[============================================================================[
# `jrl_python_generate_init_py`

```cpp
jrl_python_generate_init_py(
    <module_target_name>
    OUTPUT_PATH <output_path>
    [TEMPLATE_FILE <template_file>]
)
```

**Type:** function


### Description
  Generates a __init__.py file for a given python module target.
  It computes all the relative paths to dlls it needs to add to os.add_dll_directory based on the target's LINK_LIBRARIES.
  The generated __init__.py will call the os.add_dll_directory(<relative_path/to/coal.dll>).


### Arguments
* `module_target_name`: The python module target name.
* `OUTPUT_PATH`: Path where to generate the init file.
* `TEMPLATE_FILE`: Custom template file.


### Example
```cmake
nanobind_add_module(coal_pywrap_nb module.cpp)
# Link the python module with the main pure c++ shared library 'coal'
target_link_libraries(coal_pywrap_nb PRIVATE coal)
jrl_target_set_output_directory(coal_pywrap_nb OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/site-packages/coal)

jrl_python_generate_init_py(
    coal_pywrap_nb
    OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib/site-packages/coal/__init__.py
)
```
#]============================================================================]
function(jrl_python_generate_init_py name)
    set(options)
    set(oneValueArgs OUTPUT_PATH TEMPLATE_FILE)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _jrl_check_target_exists(${name})
    _jrl_check_var_defined(arg_OUTPUT_PATH)

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
        _jrl_check_var_defined(python_module_dir "LIBRARY_OUTPUT_DIRECTORY not set for target '${name}', add it using 'set_target_properties(<target> PROPERTIES LIBRARY_OUTPUT_DIRECTORY <dir>)'")

        get_target_property(dll_dir ${dll_name} RUNTIME_OUTPUT_DIRECTORY)
        _jrl_check_var_defined(dll_dir)

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

#[============================================================================[
# `jrl_check_python_module`

```cpp
jrl_check_python_module(
    <module_name>
    [REQUIRED]
    [QUIET]
)
```

**Type:** function


### Description
  Find if a python module is available, fills <module_name>_FOUND variable.
  Also fills <module_name>_VERSION variable if the module has a __version__ attribute.
  Displays messages based on REQUIRED and QUIET options.


### Arguments
* `module_name`: The python module name.
* `REQUIRED`: If set, the package is required.
* `QUIET`: If set, do not print messages.


### Example
```cmake
jrl_check_python_module(numpy REQUIRED)
```
#]============================================================================]
function(jrl_check_python_module module_name)
    set(options REQUIRED QUIET)
    set(oneValueArgs)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    jrl_python_get_interpreter(python)

    execute_process(
        COMMAND
            ${python} -c
            "import ${module_name}; print(getattr(${module_name}, '__version__', ''), end='')"
        RESULT_VARIABLE module_found
        OUTPUT_VARIABLE module_version
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(module_found STREQUAL 0)
        set(${module_name}_FOUND true PARENT_SCOPE)
        if(module_version)
            set(${module_name}_VERSION "${module_version}" PARENT_SCOPE)
            if(NOT arg_QUIET)
                message(STATUS "Python module '${module_name}' found (version: ${module_version}).")
            endif()
        else()
            if(NOT arg_QUIET)
                message(STATUS "Python module '${module_name}' found.")
            endif()
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

#[============================================================================[
# `jrl_python_relative_site_packages`

```cpp
jrl_python_relative_site_packages(<output>)
```

**Type:** function


### Description
  Compute the relative path of the Python site-packages directory with respect to
  the Python data directory. It is the result of:
  ```python
    sysconfig.get_path('purelib')).relative_to(sysconfig.get_path('data')
  ```

  This function is used to compute the installation directory for Python bindings in
  in jrl_python_compute_install_dir(<output>), and for ros2 package files.

  NOTE: For installing Python bindings, use jrl_python_compute_install_dir() instead.


### Arguments
  <output> - Name of the variable to store the result.


### Example
```cmake
    jrl_python_relative_site_packages(python_relative_site_packages)
    message(STATUS "Python relative site-packages: ${python_relative_site_packages}")
```

#]============================================================================]
function(jrl_python_relative_site_packages output)
    jrl_python_get_interpreter(python)

    execute_process(
        COMMAND
            ${python} -c
            "
import sysconfig
from pathlib import Path
print(Path(sysconfig.get_path('purelib')).relative_to(sysconfig.get_path('data')))
            "
        OUTPUT_VARIABLE python_relative_site_packages
        ERROR_VARIABLE error
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(error)
        message(
            FATAL_ERROR
            "Error while trying to compute the python relative site-packages: ${error}"
        )
    endif()

    # On Windows, convert to CMake path list (backslashes to slashes)
    if(WIN32)
        cmake_path(
            CONVERT "${python_relative_site_packages}"
            TO_CMAKE_PATH_LIST python_relative_site_packages
        )
    endif()

    set(${output} "${python_relative_site_packages}" PARENT_SCOPE)
endfunction()

#[============================================================================[
# `jrl_python_absolute_site_packages`

```cpp
jrl_python_absolute_site_packages(<output>)
```

**Type:** function


### Description
  Compute the absolute path of the Python site-packages directory with respect to
  the Python data directory. It is the result of:
  ```python
    sysconfig.get_path('purelib')
  ```

  This function is used to compute the installation directory for Python bindings in
  in jrl_python_compute_install_dir(<output>).

  NOTE: For installing Python bindings, use jrl_python_compute_install_dir() instead.


### Arguments
  <output> - Name of the variable to store the result.


### Example
```cmake
    jrl_python_absolute_site_packages(python_absolute_site_packages)
    message(STATUS "Python absolute site-packages: ${python_absolute_site_packages}")
```

#]============================================================================]
function(jrl_python_absolute_site_packages output)
    jrl_python_get_interpreter(python)

    execute_process(
        COMMAND
            ${python} -c
            "
import sysconfig
from pathlib import Path
print(Path(sysconfig.get_path('purelib')))
            "
        OUTPUT_VARIABLE python_absolute_site_packages
        ERROR_VARIABLE error
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(error)
        message(
            FATAL_ERROR
            "Error while trying to compute the python absolute site-packages: ${error}"
        )
    endif()

    # On Windows, convert to CMake path list (backslashes to slashes)
    if(WIN32)
        cmake_path(
            CONVERT "${python_absolute_site_packages}"
            TO_CMAKE_PATH_LIST python_absolute_site_packages
        )
    endif()

    set(${output} "${python_absolute_site_packages}" PARENT_SCOPE)
endfunction()

#[============================================================================[
# `jrl_python_compute_install_dir`

```cpp
jrl_python_compute_install_dir(<output>)
```

**Type:** function


### Description
    Compute the installation directory for Python libraries.
    It chooses the installation based using the following priority:
 1. If ${PROJECT_NAME}_PYTHON_INSTALL_DIR is defined, its value is used.
    Usually passed via CMake command line: -D${PROJECT_NAME}_PYTHON_INSTALL_DIR=<path>
    It is usually an absolute path to a specific site-packages folder.
 2. If ${PROJECT_NAME}_PYTHON_INSTALL_DIR **environment** variable is defined, its value is used.
 3. If running inside a Conda environment, on Windows, the absolute path to site-packages is used.
    It is the return value of: `sysconfig.get_path('purelib')`.
    Example: `C:/Users/You/Miniconda3/envs/myenv/Lib/site-packages`
 4. The relative path to site-packages is used.
    It is the result of: `sysconfig.get_path('purelib')).relative_to(sysconfig.get_path('data')`
    Example: `lib/python3.11/site-packages`

#### Conda Windows Layout

On Conda Windows, the site-packages is located in the `Lib\site-packages` folder,
but the Conda native libraries (DLLs) are located in the `Library\bin` folder.
CMAKE_INSTALL_PREFIX is set to CMAKE_INSTALL_PREFIX=%PREFIX%\Library.
But the python libraries are installed in %PREFIX%\Lib\site-packages.

```
C:\Users\You\Miniconda3\envs\myenv\
├── python.exe                  # The Python Interpreter
├── pythonw.exe
├── DLLs\                       # Standard Python DLLs
├── Lib\
│   └── site-packages\          # <--- PURELIB IS HERE
│       ├── pandas\
│       ├── requests\
│       └── ...
├── Scripts\                    # Python Entry points (pip.exe, jupyter.exe)
├── Library\                    # <--- CONDA SPECIFIC FOLDER
│   ├── bin\                    # Native DLLs (libssl-1_1-x64.dll, mkl.dll)
│   ├── include\                # C Headers (.h files)
│   └── lib\                    # Link libraries (.lib)
└── ...
```

#### Conda Linux & macOS Layout (Unix)

On Unix Conda environments, the site-packages is located in the `lib/pythonX.Y/site-packages` folder,
and the Conda native libraries are located in the `lib/` folder, just like a standard installation.

```
/home/user/miniconda3/envs/myenv/
├── bin/                        # Executables (python, pip, jupyter)
├── include/                    # C Headers
├── lib/
│   ├── libssl.so               # Native shared libraries
│   └── python3.11/
│       └── site-packages/      # <--- PURELIB IS HERE
│           ├── pandas/
│           └── ...
└── ...
```


### Arguments
  <output> - Name of the variable to store the result.


### Example
```cmake
  jrl_python_compute_install_dir(python_install_dir)
  install(TARGETS my_python_module DESTINATION ${python_install_dir} ...)
```
#]============================================================================]
function(jrl_python_compute_install_dir output)
    # Case 1: override via the <PROJECT_NAME>_PYTHON_INSTALL_DIR CMake variable
    if(DEFINED ${PROJECT_NAME}_PYTHON_INSTALL_DIR)
        set(pyinstall_dir "${${PROJECT_NAME}_PYTHON_INSTALL_DIR}")

        # On Windows, convert to CMake path list (backslashes to slashes)
        if(WIN32)
            cmake_path(CONVERT "${pyinstall_dir}" TO_CMAKE_PATH_LIST pyinstall_dir NORMALIZE)
        endif()

        message(
            STATUS
            "Variable ${PROJECT_NAME}_PYTHON_INSTALL_DIR is defined, using its value as python install dir.
    ${PROJECT_NAME}_PYTHON_INSTALL_DIR : ${pyinstall_dir}
    Python install dir                 : ${pyinstall_dir}
            "
        )

        set(${output} ${pyinstall_dir} PARENT_SCOPE)
        return()
    endif()

    # Case 1b: override via the <PROJECT_NAME>_PYTHON_INSTALL_DIR environment variable
    if(DEFINED ENV{${PROJECT_NAME}_PYTHON_INSTALL_DIR})
        set(pyinstall_dir "$ENV{${PROJECT_NAME}_PYTHON_INSTALL_DIR}")

        if(WIN32)
            cmake_path(CONVERT "${pyinstall_dir}" TO_CMAKE_PATH_LIST pyinstall_dir NORMALIZE)
        endif()
        message(
            STATUS
            "Environnement variable ${PROJECT_NAME}_PYTHON_INSTALL_DIR is defined, using its value as python install dir.
    ${PROJECT_NAME}_PYTHON_INSTALL_DIR : ${pyinstall_dir}
    Python install dir                 : ${pyinstall_dir}
            "
        )

        set(${output} ${pyinstall_dir} PARENT_SCOPE)
        return()
    endif()

    # Case 2: Conda environment on Windows specific case
    if(WIN32 AND DEFINED ENV{CONDA_PREFIX})
        jrl_python_absolute_site_packages(python_absolute_site_packages)
        message(
            STATUS
            "Detected Conda environment on Windows, using absolute python site-packages as python install dir.
    CONDA_PREFIX               : $ENV{CONDA_PREFIX}
    Python site-packages (abs) : ${python_absolute_site_packages}
    Python install dir         : ${python_absolute_site_packages}

    You can override this behavior with the ${PROJECT_NAME}_PYTHON_INSTALL_DIR variable (CMake or env variable).
            "
        )

        set(${output} "${python_absolute_site_packages}" PARENT_SCOPE)
        return()
    endif()

    # Case 3: Default case, use the relative site-packages path
    jrl_python_relative_site_packages(python_relative_site_packages)

    message(
        STATUS
        "Using default relative python site-packages as python install dir.
    Python site-packages (rel) : ${python_relative_site_packages}
    Python install dir         : ${python_relative_site_packages}

    You can override this behavior with the ${PROJECT_NAME}_PYTHON_INSTALL_DIR variable (CMake or env variable).
    "
    )

    set(${output} "${python_relative_site_packages}" PARENT_SCOPE)
endfunction()

#[============================================================================[
# `jrl_check_python_module_name`

```cpp
jrl_check_python_module_name(<module_target>)
```

**Type:** function


### Description
  Check that the python module defined with NB_MODULE(<module_name>)
  or BOOST_PYTHON_MODULE(<module_name>) has the same name as the target: <module_name>.cpython-XY.so.
  Otherwise the module will fail to load in Python.
  NOTE: It verifies that the symbol PyInit_<module_name> exists in the built module.


### Arguments
* `module_target`: The python module target.


### Example
```cmake
jrl_check_python_module_name(my_module)
```
#]============================================================================]
function(jrl_check_python_module_name target)
    _jrl_check_target_exists(${target})
    set(script ${CMAKE_BINARY_DIR}/generated/cmake/${PROJECT_NAME}/check-python-module-name.cmake)
    file(
        CONFIGURE
        OUTPUT ${script}
        @ONLY
        CONTENT
            [[
if(NOT CMAKE_SCRIPT_MODE_FILE)
    message(FATAL_ERROR "This script is intended to be run in script mode only. Use -P <script>.")
endif()

if(NOT DEFINED MODULE_FILE)
    message(
        FATAL_ERROR
        "MODULE_FILE variable is not defined, please pass -DMODULE_FILE=<path_to_module_file> to the script"
    )
endif()

if(NOT DEFINED EXPECTED_MODULE_NAME)
    message(FATAL_ERROR "MODULE_FILE variable is not defined.")
endif()

file(STRINGS "${MODULE_FILE}" target_content REGEX "PyInit_([a-zA-Z0-9_]+)" LIMIT_COUNT 1)
string(REGEX MATCH "PyInit_([a-zA-Z0-9_]+)" _ "${target_content}")

if(NOT CMAKE_MATCH_1)
    message(
        FATAL_ERROR
        "Could not find PyInit function in module file: '${MODULE_FILE}'. Is this a valid Python module?"
    )
endif()

if(NOT CMAKE_MATCH_1 STREQUAL EXPECTED_MODULE_NAME)
    message(
        FATAL_ERROR
        "Module name mismatch for module file: '${MODULE_FILE}'. "
        "Expected: '${EXPECTED_MODULE_NAME}', Detected: '${CMAKE_MATCH_1}'"
    )
endif()

message(
    DEBUG
    "Python module name check passed for '${MODULE_FILE}'. Detected module name: '${CMAKE_MATCH_1}'"
)
]]
    )

    add_custom_command(
        TARGET ${target}
        POST_BUILD
        COMMAND
            ${CMAKE_COMMAND} -DMODULE_FILE=$<TARGET_FILE:${target}> -DEXPECTED_MODULE_NAME=${target}
            -P ${script}
        COMMENT "Checking 'PyInit_${target}' exists"
        VERBATIM
    )
endfunction()

#[============================================================================[
# `jrl_boostpy_add_module`

```cpp
jrl_boostpy_add_module(
    <name>
    [sources...]
)
```

**Type:** function


### Description
  Creates a Boost.Python module with the given name and sources.
  The library name will be in the form <name>-<SOABI>.so, where <SOABI> is the
  Python SOABI tag (e.g., cp39-cp39m-linux_x86_64).


### Arguments
* `name`: The name of the module.
* `sources`: Source files.


### Example
```cmake
jrl_boostpy_add_module(my_module module.cpp)
```
#]============================================================================]
function(jrl_boostpy_add_module name)
    _jrl_check_command_exists(python_add_library
        "
    python_add_library(<name>) command not found.
    It is available in the FindPython module shipped with CMake.
    Use (jrl_)find_package(Python REQUIRED) before calling jrl_boostpy_add_module.
    Doc: https://cmake.org/cmake/help/latest/module/FindPython.html
    "
    )

    _jrl_check_target_exists(Boost::python
        "
    Boost::python target not found.
    Make sure you have Boost.Python using (jrl_)find_package(Boost REQUIRED COMPONENTS python).
    "
    )

    python_add_library(${name} MODULE WITH_SOABI ${ARGN})
    target_link_libraries(${name} PRIVATE Boost::python)
endfunction()

#[============================================================================[
# `jrl_boostpy_add_stubs`

```cpp
jrl_boostpy_add_stubs(
    <name>
    MODULE <module_path>
    OUTPUT_PATH <output_path>
    [PYTHON_PATH <python_path>]
    [DEPENDS <dep1> <dep2> ...]
    [VERBOSE]
)
```

**Type:** function


### Description
  Generates Boost.Python stubs for the given module using the pybind11-stubgen fork included in this repo.


### Arguments
* `name`: The target name.
* `MODULE`: The module to generate stubs for.
* `OUTPUT_PATH`: Output path.
* `PYTHON_PATH`: PYTHONPATH to use (optional).
* `DEPENDS`: Dependencies (optional).
* `VERBOSE`: Verbose output (optional).


### Example
```cmake
jrl_boostpy_add_stubs(my_stubs MODULE my_module OUTPUT_PATH ${CMAKE_BINARY_DIR})
```
#]============================================================================]
function(jrl_boostpy_add_stubs name)
    set(options VERBOSE)
    set(oneValueArgs MODULE OUTPUT_PATH PYTHON_PATH DEPENDS)
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _jrl_check_var_defined(arg_MODULE)
    _jrl_check_var_defined(arg_OUTPUT_PATH)

    if(NOT arg_PYTHON_PATH)
        set(pythonpath "")
    else()
        set(pythonpath "PYTHONPATH=${arg_PYTHON_PATH}")
    endif()

    if(arg_VERBOSE)
        set(loglevel "--log-level=DEBUG")
    endif()

    _jrl_external_modules_dir(external_modules_dir)
    set(stubgen_py ${external_modules_dir}/pybind11-stubgen-e48d1f1/pybind11_stubgen.py)
    cmake_path(CONVERT ${stubgen_py} TO_CMAKE_PATH_LIST stubgen_py NORMALIZE)
    _jrl_check_file_exists(${stubgen_py})

    jrl_python_get_interpreter(python)

    string(REPLACE "." "/" module_subpath ${arg_MODULE})
    # The stubs will be generated in <arg_OUTPUT_PATH>/<module_subpath>/__init__.pyi
    # Example: for module 'coal.coal_pywrap', the stubs will be in <arg_OUTPUT_PATH>/coal/coal_pywrap/__init__.pyi
    set(stub_output ${arg_OUTPUT_PATH}/${module_subpath}/__init__.pyi)

    add_custom_command(
        OUTPUT ${stub_output}
        COMMAND
            ${CMAKE_COMMAND} -E env ${pythonpath} ${python} ${stubgen_py} --output-dir
            ${arg_OUTPUT_PATH} ${arg_MODULE} ${loglevel} --boost-python --ignore-invalid=signature
            --no-setup-py --no-root-module-suffix
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        DEPENDS ${arg_DEPENDS}
        VERBATIM
        COMMENT "Generating Boost.Python stubs for module '${arg_MODULE}'"
    )
    add_custom_target(${name} ALL DEPENDS ${stub_output})
    if(arg_DEPENDS)
        add_dependencies(${name} ${arg_DEPENDS})
    endif()
endfunction()

#[============================================================================[
# `jrl_generate_ros2_package_files`

```cpp
jrl_generate_ros2_package_files(
    [INSTALL_CPP_PACKAGE_FILES <ON|OFF>]
    [INSTALL_PYTHON_PACKAGE_FILES <ON|OFF>]
    [PACKAGE_XML_PATH <path>]
    [DESTINATION <install destination>]
    [GEN_DIR <gen_dir>]
    [SKIP_INSTALL]
)
```

**Type:** function


### Description
  Generates the necessary files for a ROS 2 package to be discoverable by ament.
  It creates the following files:
   - ${GEN_DIR}/share/ament_index/resource_index/packages/<PROJECT_NAME>
   - ${GEN_DIR}/share/<PROJECT_NAME>/hook/ament_prefix_path.dsv
   - ${GEN_DIR}/share/<PROJECT_NAME>/hook/python_path.dsv

  By default, it installs all generated files to the CMAKE_INSTALL_DATAROOTDIR directory.
  You can override the installation destination using the DESTINATION argument.


### Arguments
* `INSTALL_CPP_PACKAGE_FILES`: Whether to install the C++ package files (default: ON).
* `INSTALL_PYTHON_PACKAGE_FILES`: Whether to install the Python package files (default: ON).
* `PACKAGE_XML_PATH`: Path to the package.xml file (default: ${CMAKE_CURRENT_SOURCE_DIR}/package.xml).
* `DESTINATION`: Installation destination for the generated files (default: CMAKE_INSTALL_DATAROOTDIR).
* `GEN_DIR`: Directory where to generate the files (default: ${CMAKE_BINARY_DIR}/generated/ros2/${PROJECT_NAME}/ros2).
* `SKIP_INSTALL`: If set, skips the installation of the generated files.


### Example
```cmake
jrl_generate_ros2_package_files()

jrl_generate_ros2_package_files(
    INSTALL_CPP_PACKAGE_FILES "NOT BUILD_STANDALONE_PYTHON_BINDINGS"
)
```
#]============================================================================]
function(jrl_generate_ros2_package_files)
    set(options SKIP_INSTALL)
    set(oneValueArgs
        INSTALL_CPP_PACKAGE_FILES
        INSTALL_PYTHON_PACKAGE_FILES
        PACKAGE_XML_PATH
        DESTINATION
        GEN_DIR
    )
    set(multiValueArgs)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    message(STATUS "[${PROJECT_NAME}] Generating files for ament (ROS 2)")

    if(DEFINED arg_INSTALL_CPP_PACKAGE_FILES)
        cmake_language(
            EVAL CODE
                "
            if(${arg_INSTALL_CPP_PACKAGE_FILES})
                set(install_cpp_package_files True)
            else()
                set(install_cpp_package_files False)
            endif()
        "
        )
    else()
        set(install_cpp_package_files True)
    endif()

    if(DEFINED arg_INSTALL_PYTHON_PACKAGE_FILES)
        cmake_language(
            EVAL CODE
                "
            if(${arg_INSTALL_PYTHON_PACKAGE_FILES})
                set(install_python_package_files True)
            else()
                set(install_python_package_files False)
            endif()
        "
        )
    else()
        set(install_python_package_files True)
    endif()

    if(install_cpp_package_files)
        if(arg_PACKAGE_XML_PATH)
            _jrl_check_file_exists(${CMAKE_CURRENT_SOURCE_DIR}/${arg_PACKAGE_XML_PATH}
                "
            PACKAGE_XML_PATH file '${arg_PACKAGE_XML_PATH}' does not exist.
            Please provide a valid path to the package.xml file of your ROS 2 package.
            "
            )
            set(package_xml_path ${CMAKE_CURRENT_SOURCE_DIR}/${arg_PACKAGE_XML_PATH})
        else()
            set(package_xml_path ${CMAKE_CURRENT_SOURCE_DIR}/package.xml)
            _jrl_check_file_exists(${package_xml_path}
                "
                package.xml file not found at default location: '${package_xml_path}'.
                Please provide a valid path to the package.xml file of your ROS 2 package
                using the PACKAGE_XML_PATH argument.
                "
            )
        endif()
    endif()

    if(arg_GEN_DIR)
        set(GEN_DIR ${arg_GEN_DIR})
    else()
        set(GEN_DIR ${CMAKE_BINARY_DIR}/generated/ros2)
    endif()

    if(arg_DESTINATION)
        set(install_destination ${arg_DESTINATION})
    else()
        _jrl_check_var_defined(CMAKE_INSTALL_DATAROOTDIR
        "
        CMAKE_INSTALL_DATAROOTDIR is not defined.
        Did you call either jrl_configure_defaults(), or jrl_configure_default_install_dirs(), or include(GNUInstallDirs) ?
        "
        )
        set(install_destination ${CMAKE_INSTALL_DATAROOTDIR})
    endif()

    if(install_cpp_package_files)
        file(
            GENERATE OUTPUT ${GEN_DIR}/share/ament_index/resource_index/packages/${PROJECT_NAME}
            CONTENT ""
        )

        file(
            GENERATE OUTPUT ${GEN_DIR}/share/${PROJECT_NAME}/hook/ament_prefix_path.dsv
            CONTENT "prepend-non-duplicate;AMENT_PREFIX_PATH;"
        )
        configure_file(${package_xml_path} ${GEN_DIR}/share/${PROJECT_NAME}/package.xml COPYONLY)
    endif()

    if(install_python_package_files)
        jrl_python_relative_site_packages(python_relative_site_packages)
        file(
            GENERATE OUTPUT ${GEN_DIR}/share/${PROJECT_NAME}/hook/python_path.dsv
            CONTENT "prepend-non-duplicate;PYTHONPATH;${python_relative_site_packages}"
        )
    endif()

    if(arg_SKIP_INSTALL)
        message(
            STATUS
            "[${PROJECT_NAME}] Skipping installation of ROS 2 package files as SKIP_INSTALL is set."
        )
        return()
    endif()

    if(install_cpp_package_files)
        install(
            FILES ${GEN_DIR}/share/ament_index/resource_index/packages/${PROJECT_NAME}
            DESTINATION ${install_destination}/ament_index/resource_index/packages
        )
        install(
            FILES ${GEN_DIR}/share/${PROJECT_NAME}/hook/ament_prefix_path.dsv
            DESTINATION ${install_destination}/${PROJECT_NAME}/hook
        )
        install(
            FILES ${GEN_DIR}/share/${PROJECT_NAME}/package.xml
            DESTINATION ${install_destination}/${PROJECT_NAME}
        )
    endif()

    if(install_python_package_files)
        install(
            FILES ${GEN_DIR}/share/${PROJECT_NAME}/hook/python_path.dsv
            DESTINATION ${install_destination}/${PROJECT_NAME}/hook
        )
    endif()
endfunction()

#[============================================================================[
# `_jrl_generate_api_doc`

```cpp
_jrl_generate_api_doc(
    <input_file>
    <output_file>
)
```

**Type:** function


### Description
  Parses the input CMake file for documentations block and
  generates a Markdown file with their content.


### Arguments
* `input_file`: The CMake file to parse.
* `output_file`: The Markdown file to generate.


### Example
```cmake
_jrl_generate_api_doc(${CMAKE_CURRENT_LIST_FILE} "API.md")
# or using the command line:
cmake -DGENERATE_API_DOC=ON -P v2/modules/jrl.cmake
```
#]============================================================================]
function(_jrl_generate_api_doc input_file output_file)
    _jrl_check_file_exists(${input_file})

    file(STRINGS "${input_file}" content)

    set(markdown_content "")
    set(regex_start "^#\\[=+\\[")
    set(regex_end "#\\]=+\\]$")

    foreach(line IN LISTS content)
        if(line MATCHES "${regex_start}" AND line MATCHES "${regex_end}")
            # remove first and last element on the string (the comment delimiters)
            string(REGEX REPLACE "${regex_start}" "" line "${line}")
            string(REGEX REPLACE "${regex_end}" "" line "${line}")

            string(REPLACE ";" "\n" doc_block "${line}")
            string(REGEX MATCH "# `([^`]+)`" _ "${doc_block}")
            if(CMAKE_MATCH_1)
                set(doc_name "${CMAKE_MATCH_1}")
                if(doc_name MATCHES "^_")
                    message(STATUS "Skipping internal documentation for ${doc_name}")
                else()
                    message(STATUS "Processing documentation for ${doc_name}")
                    string(APPEND markdown_content "${doc_block}\n")
                endif()
            endif()
        endif()
    endforeach()

    set(JRL_API_DOCUMENTATION "${markdown_content}")

    _jrl_templates_dir(templates_dir)
    configure_file(${templates_dir}/api.md.in ${output_file} @ONLY)
    message(STATUS "API documentation generated at '${output_file}'")
endfunction()

if(GENERATE_API_DOC)
    _jrl_docs_dir(docs_dir)
    _jrl_generate_api_doc(${CMAKE_CURRENT_LIST_FILE} ${docs_dir}/api.md)
endif()
