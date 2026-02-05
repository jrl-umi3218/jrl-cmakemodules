# Copyright 2025-2026 Inria

if(NOT TARGET Python::Interpreter)
    message(
        FATAL_ERROR
        "
        Python::Interpreter not found.
            Make sure you have the Python interpreter using find_package(Python REQUIRED COMPONENTS Interpreter).
    "
    )
endif()

# Windows: If python is installed via vcpkg and pytest installed via
# C:/vcpkg/installed/x64-windows/tools/python3/python.exe -m pip install pytest
# Then pytest will be located in C:/vcpkg/installed/x64-windows/tools/python3/Scripts/pytest.exe
# So we add an additional hint to find_program
cmake_path(GET Python_EXECUTABLE PARENT_PATH Python_ROOT)

# On Ubuntu 22.04, pytest is named pytest-3
find_program(Pytest_EXECUTABLE NAMES pytest pytest-3 HINTS ${Python_ROOT}/Scripts REQUIRED)

# On Ubuntu 22.04, pytest prints the version in stderr
execute_process(
    COMMAND ${Pytest_EXECUTABLE} --version
    OUTPUT_VARIABLE Pytest_VERSION_FULL
    ERROR_VARIABLE Pytest_VERSION_FULL
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(REGEX MATCH "[0-9]+\\.[0-9]+(\\.[0-9a-zA-Z]+)?" Pytest_VERSION "${Pytest_VERSION_FULL}")

if(NOT Pytest_VERSION)
    message(FATAL_ERROR "Could not determine Pytest version from output: '${Pytest_VERSION_FULL}'")
endif()

mark_as_advanced(Pytest_EXECUTABLE Pytest_VERSION)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Pytest REQUIRED_VARS Pytest_EXECUTABLE VERSION_VAR Pytest_VERSION)

if(NOT TARGET Pytest::Pytest)
    add_executable(Pytest::Pytest IMPORTED)
    set_target_properties(
        Pytest::Pytest
        PROPERTIES VERSION ${Pytest_VERSION} IMPORTED_LOCATION ${Pytest_EXECUTABLE}
    )
endif()
