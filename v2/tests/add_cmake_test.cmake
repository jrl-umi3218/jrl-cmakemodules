# Function to define tests that build and install a CMake project
function(add_cmake_test)
    set(options "")
    set(oneValueArgs
        "NAME"
        "SOURCE_DIR"
        "BUILD_TARGET"
        "PASS_REGULAR_EXPRESSION"
        "WILL_FAIL"
    )
    set(multiValueArgs "DEPENDS" "EXTRA_OPTIONS" "ENVIRONMENT" "COMMAND")
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
            message(
                FATAL_ERROR
                "Dependency ${arg_DEPENDS} does not have an install directory defined."
            )
        endif()
        set(extra_build_options "-DCMAKE_PREFIX_PATH=${${arg_DEPENDS}_INSTALL_DIR}")
    endif()

    # Clear the build and install directories before each test run to avoid stale artifacts.
    set(cleanup_test_name "${test_name} [clean build/install]")
    add_test(
        NAME "${cleanup_test_name}"
        COMMAND ${CMAKE_COMMAND} -E rm -rf "${binary_dir}" "${install_dir}"
    )
    set_tests_properties("${cleanup_test_name}" PROPERTIES FIXTURES_SETUP "${test_name}_fixture")

    if(arg_COMMAND)
        set(test_command "--test-command" ${arg_COMMAND})
    else()
        set(test_command "")
    endif()

    # The actual test that builds and installs the project, and checks the results.
    add_test(
        NAME "${test_name}"
        COMMAND
            ${CMAKE_CTEST_COMMAND} --build-and-test "${source_dir}" "${binary_dir}" --build-config
            "Release" --build-generator "${CMAKE_GENERATOR}" --build-target "${build_target}"
            --build-options "${build_options}" ${extra_build_options} ${arg_EXTRA_OPTIONS}
            ${test_command}
    )
    set_tests_properties("${test_name}" PROPERTIES FIXTURES_REQUIRED "${test_name}_fixture")

    if(arg_DEPENDS)
        if(NOT DEFINED ${arg_DEPENDS}_TEST_NAME)
            message(FATAL_ERROR "Dependency ${arg_DEPENDS} does not have a test name defined.")
        endif()
        if(${arg_DEPENDS}_TEST_NAME)
            set_tests_properties("${test_name}" PROPERTIES DEPENDS "${${arg_DEPENDS}_TEST_NAME}")
        endif()
    endif()

    if(arg_WILL_FAIL)
        set_tests_properties("${test_name}" PROPERTIES WILL_FAIL ${arg_WILL_FAIL})
    endif()

    if(arg_PASS_REGULAR_EXPRESSION)
        set_tests_properties(
            "${test_name}"
            PROPERTIES PASS_REGULAR_EXPRESSION "${arg_PASS_REGULAR_EXPRESSION}"
        )
    endif()

    if(arg_ENVIRONMENT)
        set_tests_properties("${test_name}" PROPERTIES ENVIRONMENT "${arg_ENVIRONMENT}")
    endif()
endfunction()
