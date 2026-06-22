cmake_minimum_required(VERSION 3.22)
project(export_package_control LANGUAGES NONE)

include(${CMAKE_CURRENT_SOURCE_DIR}/../add_cmake_test.cmake)

enable_testing()

# Getting the jrl-cmakemodules dep.
add_cmake_test(
    NAME jrl-cmakemodules
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../.."
)

# 1. Default behaviour: export is ON by default.
add_cmake_test(
    NAME epc-library-default
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/epc-library"
    DEPENDS jrl-cmakemodules
)

add_cmake_test(
    NAME epc-consumer-default
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/epc-consumer"
    DEPENDS epc-library-default
    BUILD_TARGET all
)

# 2. CMake Variable: setting EPC_LIBRARY_EXPORT_PACKAGE=OFF skips export.
add_cmake_test(
    NAME epc-library-var-off
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/epc-library"
    DEPENDS jrl-cmakemodules
    EXTRA_OPTIONS "-DEPC_LIBRARY_EXPORT_PACKAGE=OFF"
)

add_cmake_test(
    NAME epc-consumer-var-off
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/epc-consumer"
    DEPENDS epc-library-var-off
    BUILD_TARGET all
    WILL_FAIL TRUE
)

# 3. Environment Variable: setting EPC_LIBRARY_EXPORT_PACKAGE=OFF in ENV skips export.
add_cmake_test(
    NAME epc-library-env-off
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/epc-library"
    DEPENDS jrl-cmakemodules
    ENVIRONMENT "EPC_LIBRARY_EXPORT_PACKAGE=OFF"
)

add_cmake_test(
    NAME epc-consumer-env-off
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/epc-consumer"
    DEPENDS epc-library-env-off
    BUILD_TARGET all
    WILL_FAIL TRUE
)
