cmake_minimum_required(VERSION 3.22)
project(eti-project VERSION 1.0.0 LANGUAGES NONE)

include(${CMAKE_CURRENT_SOURCE_DIR}/../../add_cmake_test.cmake)
enable_testing()

add_cmake_test(NAME jrl-cmakemodules SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../..")
add_cmake_test(NAME failing-eti-project DEPENDS jrl-cmakemodules
    PASS_REGULAR_EXPRESSION "The expected targets that were not imported are: Dummy::DoesNotExist"
)

install(CODE "message(STATUS \"Fake install\")")
