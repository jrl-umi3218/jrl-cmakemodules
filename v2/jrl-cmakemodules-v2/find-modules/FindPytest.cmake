if(NOT TARGET Python::Interpreter)
    message(
        FATAL_ERROR
        "
        Python::Interpreter not found.
            Make sure you have the Python interpreter using find_package(Python REQUIRED COMPONENTS Interpreter).
    "
    )
endif()

# If python is installed via vcpkg and pytest installed via
# C:/vcpkg/installed/x64-windows/tools/python3/python.exe -m pip install pytest
# Then pytest will be located in C:/vcpkg/installed/x64-windows/tools/python3/Scripts/pytest.exe
# So we add an additional hint to find_program

cmake_path(GET Python_EXECUTABLE PARENT_PATH Python_ROOT)
find_program(Pytest_EXECUTABLE pytest HINTS ${Python_ROOT}/Scripts REQUIRED)

execute_process(
    COMMAND ${Pytest_EXECUTABLE} --version
    OUTPUT_VARIABLE Pytest_VERSION_FULL
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(REGEX MATCH "[0-9]+(\\.[0-9]+)*" Pytest_VERSION "${Pytest_VERSION_FULL}")

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
