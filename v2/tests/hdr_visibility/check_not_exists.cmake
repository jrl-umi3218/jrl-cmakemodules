# Helper script: fails if the file at FILEPATH path exists.
# Usage: cmake -DFILEPATH=<path> -P check_not_exists.cmake
if(NOT DEFINED FILEPATH)
    message(FATAL_ERROR "FILEPATH variable must be provided")
endif()

if(EXISTS "${FILEPATH}")
    message(FATAL_ERROR "FAIL: File should NOT be installed but found at: ${FILEPATH}")
endif()

message(STATUS "PASS: File is not installed (as expected): ${FILEPATH}")
