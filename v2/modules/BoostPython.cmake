# Copyright 2025-2026 Inria

cmake_minimum_required(VERSION 3.22)

# Usage: jrl_boostpy_add_module(name [sources...])
# Creates a Boost.Python module with the given name and sources.
# The library name will be in the form <name>-<SOABI>.so, where <SOABI> is the
# Python SOABI tag (e.g., cp39-cp39m-linux_x86_64).
function(jrl_boostpy_add_module name)
    if(NOT COMMAND python_add_library)
        message(
            FATAL_ERROR
            "
        python_add_library(<name>) command not found.
            It is available in the FindPython module shipped with CMake.
            Please use (jrl_)find_package(Python REQUIRED) before calling jrl_boostpy_add_module.
            Doc: https://cmake.org/cmake/help/latest/module/FindPython.html
        "
        )
    endif()

    if(NOT TARGET Boost::python)
        message(
            FATAL_ERROR
            "
        Boost::python target not found.
            Make sure you have Boost.Python using (jrl_)find_package(Boost REQUIRED COMPONENTS python).
        "
        )
    endif()

    python_add_library(${name} MODULE WITH_SOABI ${ARGN})
    target_link_libraries(${name} PRIVATE Boost::python)
endfunction()

# jrl_boostpy_add_stubs(stubs_target_name MODULE module_name PYTHON_PATH path DEPENDS target [VERBOSE])
function(jrl_boostpy_add_stubs name)
    set(options VERBOSE)
    set(oneValueArgs MODULE OUTPUT PYTHON_PATH DEPENDS)
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 1 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")

    if(NOT arg_MODULE)
        message(FATAL_ERROR "MODULE argument is required")
    endif()

    if(NOT arg_OUTPUT)
        message(FATAL_ERROR "OUTPUT argument is required")
    endif()

    if(NOT arg_PYTHON_PATH)
        set(pythonpath "")
    else()
        set(pythonpath "PYTHONPATH=${arg_PYTHON_PATH}")
    endif()

    if(arg_VERBOSE)
        set(loglevel "--log-level=DEBUG")
    endif()

    set(stubgen_py
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../external-modules/pybind11-stubgen-e48d1f1/pybind11_stubgen.py
    )
    if(NOT EXISTS ${stubgen_py})
        message(
            FATAL_ERROR
            "Could not find 'pybind11_stubgen.py' at expected location: ${stubgen_py}"
        )
    endif()
    cmake_path(CONVERT ${stubgen_py} TO_CMAKE_PATH_LIST stubgen_py NORMALIZE)

    add_custom_command(
        OUTPUT ${arg_OUTPUT}
        COMMAND
            ${CMAKE_COMMAND} -E env ${pythonpath} $<TARGET_FILE:Python::Interpreter> ${stubgen_py}
            --output-dir ${arg_OUTPUT} ${arg_MODULE} ${loglevel} --boost-python
            --ignore-invalid=signature --no-setup-py --no-root-module-suffix
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        DEPENDS ${arg_DEPENDS}
        VERBATIM
        COMMENT "Generating boost python stubs for module '${arg_MODULE}'"
    )
    add_custom_target(${name} ALL DEPENDS ${arg_OUTPUT})
    if(arg_DEPENDS)
        add_dependencies(${name} ${arg_DEPENDS})
    endif()
endfunction()
