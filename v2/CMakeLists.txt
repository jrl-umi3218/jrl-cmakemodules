# Copyright 2025-2026 Inria

cmake_minimum_required(VERSION 3.22)
project(jrl-cmakemodules VERSION 2.0.0)

set(jrl-cmakemodules_VERSION ${PROJECT_VERSION} CACHE STRING "Version of jrl-cmakemodules")
include(${CMAKE_CURRENT_SOURCE_DIR}/modules/jrl.cmake)

option(
    JRL_CMAKEMODULES_GENERATE_API_DOC
    "Generate the API documentation for jrl-cmakemodules (v2)"
    ${PROJECT_IS_TOP_LEVEL}
)
option(
    JRL_CMAKEMODULES_BUILD_TESTS
    "Build the tests for jrl-cmakemodules (v2)"
    ${PROJECT_IS_TOP_LEVEL}
)

if(JRL_CMAKEMODULES_GENERATE_API_DOC)
    _jrl_generate_api_doc(
        ${CMAKE_CURRENT_SOURCE_DIR}/modules/jrl.cmake
        ${CMAKE_CURRENT_SOURCE_DIR}/docs/api.md
    )
endif()

if(JRL_CMAKEMODULES_BUILD_TESTS)
    jrl_include_ctest()
    enable_testing()
    add_subdirectory(tests)
endif()

if(NOT PROJECT_IS_TOP_LEVEL)
    return()
endif()

jrl_configure_defaults()

# Where to install the <project>-config.cmake and related files
# Here we choose <prefix>/share/cmake/<project>
set(CMAKE_FILES_INSTALL_DIR ${CMAKE_INSTALL_DATAROOTDIR}/cmake/${PROJECT_NAME})

install(
    DIRECTORY external-modules find-modules modules templates scripts
    DESTINATION ${CMAKE_FILES_INSTALL_DIR}
    PATTERN ".ruff_cache" EXCLUDE
    PATTERN "__pycache__" EXCLUDE
    PATTERN ".pytest_cache" EXCLUDE
)

jrl_export_package(
    PACKAGE_CONFIG_TEMPLATE
        ${CMAKE_CURRENT_SOURCE_DIR}/templates/config-basic.cmake.in
    PACKAGE_CONFIG_EXTRA_CONTENT
        [[include("${CMAKE_CURRENT_LIST_DIR}/modules/jrl.cmake")]]
    CMAKE_FILES_INSTALL_DIR
        ${CMAKE_FILES_INSTALL_DIR}
)
