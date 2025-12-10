# Checks the Python module name inside a compiled extension module file.
# Usage:
# add_custom_command(
#     TARGET ${target}
#     POST_BUILD
#     COMMAND
#         ${CMAKE_COMMAND} -DMODULE_FILE=$<TARGET_FILE:${target}> -DEXPECTED_MODULE_NAME=${target}
#         -P /path/to/PythonCheckModuleNameScript.cmake
#     VERBATIM
# )

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
