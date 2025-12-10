# Part of pytest-cmake

function(pytest_discover_tests NAME)
    if(NOT TARGET Pytest::Pytest)
        message(FATAL_ERROR "Pytest::Pytest target not found. Make sure to call find_package(Pytest REQUIRED) before using pytest_discover_tests().")
    endif()

    set(_BOOL_ARGS
        STRIP_PARAM_BRACKETS
        INCLUDE_FILE_PATH
        BUNDLE_TESTS
    )

    set(_SINGLE_VALUE_ARGS
        WORKING_DIRECTORY
        TRIM_FROM_NAME
        TRIM_FROM_FULL_NAME
    )

    set(_MULTI_VALUE_ARGS
        TEST_PATHS
        LIBRARY_PATH_PREPEND
        PYTHON_PATH_PREPEND
        ENVIRONMENT
        PROPERTIES
        DEPENDS
        EXTRA_ARGS
        DISCOVERY_EXTRA_ARGS
    )

    cmake_parse_arguments(
        PARSE_ARGV 1 ""
        "${_BOOL_ARGS}"
        "${_SINGLE_VALUE_ARGS}"
        "${_MULTI_VALUE_ARGS}"
    )

    # Set platform-specific library path environment variable.
    if (CMAKE_SYSTEM_NAME STREQUAL Windows)
        set(LIBRARY_ENV_NAME PATH)
    elseif(CMAKE_SYSTEM_NAME STREQUAL Darwin)
        set(LIBRARY_ENV_NAME DYLD_LIBRARY_PATH)
    else()
        set(LIBRARY_ENV_NAME LD_LIBRARY_PATH)
    endif()

    # Convert paths to CMake-friendly format.
    if(DEFINED ENV{${LIBRARY_ENV_NAME}})
        cmake_path(CONVERT "$ENV{${LIBRARY_ENV_NAME}}" TO_CMAKE_PATH_LIST LIBRARY_PATH)
    else()
        set(LIBRARY_PATH "")
    endif()
    if(DEFINED ENV{PYTHONPATH})
        cmake_path(CONVERT "$ENV{PYTHONPATH}" TO_CMAKE_PATH_LIST PYTHON_PATH)
    else()
        set(PYTHON_PATH "")
    endif()

    # Prepend specified paths to the library and Python paths.
    if (_LIBRARY_PATH_PREPEND)
        list(REVERSE _LIBRARY_PATH_PREPEND)
        foreach (_path ${_LIBRARY_PATH_PREPEND})
            set(LIBRARY_PATH "${_path}" "${LIBRARY_PATH}")
        endforeach()
    endif()

    if (_PYTHON_PATH_PREPEND)
        list(REVERSE _PYTHON_PATH_PREPEND)
        foreach (_path ${_PYTHON_PATH_PREPEND})
            set(PYTHON_PATH "${_path}" "${PYTHON_PATH}")
        endforeach()
    endif()

    # Set default working directory if none is specified.
    if (NOT _WORKING_DIRECTORY)
        set(_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    endif()

    get_filename_component(_WORKING_DIRECTORY "${_WORKING_DIRECTORY}" REALPATH)

    # Override option by environment variable if available.
    if (DEFINED ENV{BUNDLE_PYTHON_TESTS})
        set(_BUNDLE_TESTS $ENV{BUNDLE_PYTHON_TESTS})
    endif()

    # Define file paths for generated CMake include files.
    set(_include_file "${CMAKE_CURRENT_BINARY_DIR}/${NAME}_include.cmake")
    set(_tests_file "${CMAKE_CURRENT_BINARY_DIR}/${NAME}_tests.cmake")

    add_custom_command(
        VERBATIM
        OUTPUT "${_tests_file}"
        DEPENDS ${_DEPENDS}
        COMMAND ${CMAKE_COMMAND}
        -D "PYTEST_EXECUTABLE=${PYTEST_EXECUTABLE}"
        -D "TEST_PATHS=${_TEST_PATHS}"
        -D "TEST_GROUP_NAME=${NAME}"
        -D "BUNDLE_TESTS=${_BUNDLE_TESTS}"
        -D "LIBRARY_ENV_NAME=${LIBRARY_ENV_NAME}"
        -D "LIBRARY_PATH=${LIBRARY_PATH}"
        -D "PYTHON_PATH=${PYTHON_PATH}"
        -D "TRIM_FROM_NAME=${_TRIM_FROM_NAME}"
        -D "TRIM_FROM_FULL_NAME=${_TRIM_FROM_FULL_NAME}"
        -D "STRIP_PARAM_BRACKETS=${_STRIP_PARAM_BRACKETS}"
        -D "INCLUDE_FILE_PATH=${_INCLUDE_FILE_PATH}"
        -D "WORKING_DIRECTORY=${_WORKING_DIRECTORY}"
        -D "ENVIRONMENT=${_ENVIRONMENT}"
        -D "TEST_PROPERTIES=${_PROPERTIES}"
        -D "CTEST_FILE=${_tests_file}"
        -D "EXTRA_ARGS=${_EXTRA_ARGS}"
        -D "DISCOVERY_EXTRA_ARGS=${_DISCOVERY_EXTRA_ARGS}"
        -P "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/PytestAddTests.cmake")

    # Create a custom target to run the tests.
    add_custom_target(${NAME} ALL DEPENDS ${_tests_file})

    file(WRITE "${_include_file}"
        "if(EXISTS \"${_tests_file}\")\n"
        "    include(\"${_tests_file}\")\n"
        "else()\n"
        "    add_test(${NAME}_NOT_BUILT ${NAME}_NOT_BUILT)\n"
        "endif()\n"
    )

    # Register the include file to be processed for tests.
    set_property(DIRECTORY
        APPEND PROPERTY TEST_INCLUDE_FILES "${_include_file}")

endfunction()