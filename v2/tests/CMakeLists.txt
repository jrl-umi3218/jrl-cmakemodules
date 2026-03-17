# gersemi: off
function(add_cmake_test)
    set(options "")
    set(oneValueArgs "NAME" "SOURCE_DIR" "BUILD_TARGET")
    set(multiValueArgs "EXTRA_OPTIONS" "DEPENDS")
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT arg_NAME)
        message(FATAL_ERROR "NAME argument is required for add_cmake_test")
    endif()

    if(DEFINED arg_BUILD_TARGET)
        set(build_target "${arg_BUILD_TARGET}")
    else()
        set(build_target "install")
    endif()

    set(name "${arg_NAME}")

    if(DEFINED arg_SOURCE_DIR)
        set(source_dir "${arg_SOURCE_DIR}")
    else()
        set(source_dir "${CMAKE_CURRENT_SOURCE_DIR}/${name}")
    endif()

    set(binary_dir "${CMAKE_CURRENT_BINARY_DIR}/${name}-build")
    set(install_dir "${CMAKE_CURRENT_BINARY_DIR}/${name}-install")

    # Generate a unique test name to avoid conflicts in CTest
    # when multiple tests have the same base name but different options or dependencies.
    string(SHA256 hash "${source_dir};${arg_EXTRA_OPTIONS};${arg_DEPENDS}")
    string(SUBSTRING ${hash} 0 8 test_id)
    set(test_name "${name} ${arg_EXTRA_OPTIONS} (test_id=${test_id})")

    # Cache the directories and test name for potential external use (e.g., by dependent tests)
    set(${name}_SOURCE_DIR "${source_dir}" CACHE PATH "Source directory for ${name}")
    set(${name}_BINARY_DIR "${binary_dir}" CACHE PATH "Build directory for ${name}")
    set(${name}_INSTALL_DIR "${install_dir}" CACHE PATH "Installation directory for ${name}")
    set(${name}_TEST_NAME "${test_name}" CACHE STRING "Test name for ${name}")

    set(build_options "-DCMAKE_INSTALL_PREFIX=${install_dir}")
    if(arg_DEPENDS)
        if(NOT DEFINED ${arg_DEPENDS}_INSTALL_DIR)
            message(FATAL_ERROR "Dependency ${arg_DEPENDS} does not have an install directory defined.")
        endif()
        set(extra_build_options "-DCMAKE_PREFIX_PATH=${${arg_DEPENDS}_INSTALL_DIR}")
    endif()

    add_test(
        NAME "${test_name}"
        COMMAND ${CMAKE_CTEST_COMMAND}
            --build-and-test    "${source_dir}"
                                "${binary_dir}"
            ${arg_EXTRA_OPTIONS}
            --build-config      "Release"
            --build-generator   "${CMAKE_GENERATOR}"
            --build-target      "${build_target}"
            --build-options     "${build_options}"
                                "${extra_build_options}"
    )

    if(arg_DEPENDS)
        if(NOT DEFINED ${arg_DEPENDS}_TEST_NAME)
            message(FATAL_ERROR "Dependency ${arg_DEPENDS} does not have a test name defined.")
        endif()
        set_tests_properties("${test_name}" PROPERTIES DEPENDS ${${arg_DEPENDS}_TEST_NAME})
    endif()
endfunction()
# gersemi: on

# 1. Build and install the jrl-cmakemodules package itself.
add_cmake_test(
    NAME jrl-cmakemodules
    SOURCE_DIR ${PROJECT_SOURCE_DIR}
)

# 2. Check that the jrl.cmake is present
add_test(
    NAME "Check jrl.cmake"
    COMMAND
        ${CMAKE_COMMAND} -E cat
        "${jrl-cmakemodules_INSTALL_DIR}/share/cmake/jrl-cmakemodules/v2/modules/jrl.cmake"
)
set_tests_properties("Check jrl.cmake" PROPERTIES DEPENDS jrl-cmakemodules)

# 3. Run the tests with the local test projects

add_cmake_test(NAME packaging/find_package_v1 DEPENDS jrl-cmakemodules)
add_cmake_test(NAME packaging/find_package_v2 DEPENDS jrl-cmakemodules)

add_cmake_test(NAME test_project DEPENDS jrl-cmakemodules)
add_cmake_test(NAME test_project EXTRA_OPTIONS "--build-noclean" DEPENDS jrl-cmakemodules)
add_cmake_test(NAME test_project EXTRA_OPTIONS "--build-noclean" "--build-two-config" DEPENDS jrl-cmakemodules)

add_cmake_test(NAME test_project_without_deps DEPENDS jrl-cmakemodules)
add_cmake_test(NAME test_project_without_deps EXTRA_OPTIONS "--build-noclean" DEPENDS jrl-cmakemodules)
add_cmake_test(NAME test_project_without_deps EXTRA_OPTIONS "--build-noclean" "--build-two-config" DEPENDS jrl-cmakemodules)

add_cmake_test(NAME packaging/fetchcontent)

add_subdirectory(modules)

add_subdirectory(multitargets)
