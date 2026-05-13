# Copyright 2025-2026 Inria

cmake_minimum_required(VERSION 3.22)
project(jrl-tests-modules LANGUAGES NONE)
enable_testing()

include(${CMAKE_CURRENT_SOURCE_DIR}/jrl_test_case.cmake)

include(${CMAKE_CURRENT_SOURCE_DIR}/test_jrl_option.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/test__jrl_check.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/test__jrl_check_helpers.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/test__jrl_check_valid_visibility.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/test__jrl_check_no_unrecognized_arguments.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/test__jrl_log.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/test__jrl_normalize_version.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/test__jrl_dir_helpers.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/test__jrl_pad_string.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/test_jrl_get_cxx_compiler_id.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/test_jrl_add_export_component.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/test_jrl_configure_default_build_type.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/test_jrl_export_dependency.cmake)
