if(NOT DEFINED Python_EXECUTABLE)
    message(
        FATAL_ERROR
        "Python_EXECUTABLE is not defined. Please set it to the path of the Python interpreter."
    )
endif()

execute_process(
    COMMAND ${Python_EXECUTABLE} -c "import scipy; print(scipy.__version__)"
    OUTPUT_VARIABLE Scipy_VERSION
    ERROR_VARIABLE Scipy_ERROR
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(Scipy_ERROR)
    message(FATAL_ERROR "Scipy not found: ${Scipy_ERROR}")
endif()

mark_as_advanced(Scipy_VERSION)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Scipy REQUIRED_VARS Python_EXECUTABLE VERSION_VAR Scipy_VERSION)

if(NOT TARGET Scipy::Scipy)
    add_library(Scipy::Scipy IMPORTED INTERFACE)
    set_target_properties(Scipy::Scipy PROPERTIES VERSION ${Scipy_VERSION})
endif()
