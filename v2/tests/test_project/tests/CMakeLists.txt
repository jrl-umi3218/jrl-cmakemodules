add_executable(test_StringUtils test_StringUtils.cpp)
target_link_libraries(test_StringUtils PRIVATE test_project Catch2::Catch2WithMain)

catch_discover_tests(test_StringUtils)

set(test_name "Nanobind Bindings")
add_test(
    NAME ${test_name}
    COMMAND $<TARGET_FILE:Pytest::Pytest> ${CMAKE_CURRENT_SOURCE_DIR}/test_nanobind_bindings.py
)
set_tests_properties(
    ${test_name}
    PROPERTIES
        ENVIRONMENT_MODIFICATION
            "PYTHONPATH=path_list_prepend:${CMAKE_BINARY_DIR}/lib/site-packages;PYTHONPATH=path_list_prepend:${CMAKE_CURRENT_BINARY_DIR}"
        LABELS "python"
        DEPENDS "test_project_pywrap"
)

add_test(
    NAME "Test Boost Python Bindings"
    COMMAND
        ${CMAKE_COMMAND} -E env PYTHONPATH=${CMAKE_BINARY_DIR}/lib/site-packages
        $<TARGET_FILE:Pytest::Pytest> ${CMAKE_CURRENT_SOURCE_DIR}/test_boostpy_bindings.py
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
