# Copyright 2025-2026 Inria

# Add unit tests for jrl-cmakemodules functions

add_test(
    NAME test_jrl_option
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_SOURCE_DIR}/test_jrl_option.cmake
)
