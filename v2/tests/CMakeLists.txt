# gersemi: off
include(${CMAKE_CURRENT_LIST_DIR}/add_cmake_test.cmake)
# gersemi: on

# 1. Build and install the jrl-cmakemodules package itself.
add_cmake_test(
    NAME jrl-cmakemodules
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../.."
)

# 2. Check that the jrl.cmake is present
add_test(
    NAME "Check jrl.cmake"
    COMMAND
        ${CMAKE_COMMAND} -E cat
        "${jrl-cmakemodules_INSTALL_DIR}/share/cmake/jrl-cmakemodules/v2/modules/jrl.cmake"
)
set_tests_properties("Check jrl.cmake" PROPERTIES DEPENDS jrl-cmakemodules RUN_SERIAL TRUE)

# 3. Run the tests with the local test projects
add_subdirectory(find_modules)
add_subdirectory(v1_api)
add_subdirectory(regular_find_package)
add_subdirectory(expected_targets_warn)
add_subdirectory(expected_targets_skip)
add_subdirectory(expected_targets_ok)
add_subdirectory(expected_targets_invalid)
add_subdirectory(fetchcontent)
add_subdirectory(modules)
add_subdirectory(minimal_project)
add_subdirectory(camel_case)
add_subdirectory(header_visibility)
add_subdirectory(multi_targets)
add_subdirectory(multi_comp)
add_subdirectory(comp_genexp)
add_subdirectory(no_deps)
add_subdirectory(python_bindings)
add_subdirectory(print_dependencies_summary)
add_subdirectory(export_package_control)
