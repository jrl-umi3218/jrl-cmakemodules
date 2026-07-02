cmake_minimum_required(VERSION 3.22)
project(od-workspace)

# The project using jrl is sandwiched between plain CMake projects.
# That way, we catch possible leakage in either direction.
add_subdirectory(od-plain-a)
add_subdirectory(od-jrl)
add_subdirectory(od-plain-b)

enable_testing()

add_test(
    NAME "output_dirs: od-jrl lib is in the shared build/lib"
    COMMAND ${CMAKE_COMMAND} -E cat "${CMAKE_BINARY_DIR}/lib/$<TARGET_FILE_NAME:od_fakelib_jrl>"
)

add_test(
    NAME "output_dirs: od-plain-a lib is in its own binary dir"
    COMMAND
        ${CMAKE_COMMAND} -E cat
        "${CMAKE_CURRENT_BINARY_DIR}/od-plain-a/$<TARGET_FILE_NAME:od_fakelib_plain_a>"
)

add_test(
    NAME "output_dirs: od-plain-b lib is in its own binary dir"
    COMMAND
        ${CMAKE_COMMAND} -E cat
        "${CMAKE_CURRENT_BINARY_DIR}/od-plain-b/$<TARGET_FILE_NAME:od_fakelib_plain_b>"
)

add_test(
    NAME "output_dirs: od-jrl explicit target property wins over the jrl default"
    COMMAND
        ${CMAKE_COMMAND} -E cat
        "${CMAKE_CURRENT_BINARY_DIR}/od-jrl/bindings/python/od-jrl/$<TARGET_FILE_NAME:od_fakelib_jrl_explicit>"
)

add_test(
    NAME "output_dirs: od-plain-a explicit target property is honored"
    COMMAND
        ${CMAKE_COMMAND} -E cat
        "${CMAKE_CURRENT_BINARY_DIR}/od-plain-a/bindings/python/od-plain-a/$<TARGET_FILE_NAME:od_fakelib_plain_explicit>"
)

install(CODE "message(STATUS \"Fake install\")")
