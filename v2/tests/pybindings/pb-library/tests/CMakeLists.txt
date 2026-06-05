add_executable(test_StringUtils test_StringUtils.cpp)
target_link_libraries(test_StringUtils PRIVATE pb Catch2::Catch2WithMain)
catch_discover_tests(test_StringUtils)

if(PB_BUILD_PYTHON_BINDINGS)
    add_test(
        NAME "Nanobind Bindings"
        COMMAND $<TARGET_FILE:Pytest::Pytest> ${CMAKE_CURRENT_SOURCE_DIR}/test_nanobind_bindings.py
    )
    set_tests_properties(
        "Nanobind Bindings"
        PROPERTIES
            ENVIRONMENT_MODIFICATION
                "PYTHONPATH=path_list_prepend:${CMAKE_BINARY_DIR}/lib/site-packages"
            LABELS "python"
            DEPENDS "pb_pywrap"
    )

    add_test(
        NAME "Test Boost Python Bindings"
        COMMAND $<TARGET_FILE:Pytest::Pytest> ${CMAKE_CURRENT_SOURCE_DIR}/test_boostpy_bindings.py
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
    set_tests_properties(
        "Test Boost Python Bindings"
        PROPERTIES
            ENVIRONMENT_MODIFICATION
                "PYTHONPATH=path_list_prepend:${CMAKE_BINARY_DIR}/lib/site-packages"
            LABELS "python"
            DEPENDS "pb_pywrap_bp"
    )
endif()
