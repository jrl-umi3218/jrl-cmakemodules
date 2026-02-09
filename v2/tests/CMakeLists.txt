# gersemi: off
add_test(
    NAME ${PROJECT_NAME}-install
    COMMAND ${CMAKE_CTEST_COMMAND}
        --build-and-test    "${PROJECT_SOURCE_DIR}"
                            "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-build"
        --build-config      "Release"
        --build-generator   "${CMAKE_GENERATOR}"
        --build-target      install
        --build-options     "-DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-install"
)

function(add_cmake_test dir)
    cmake_parse_arguments(arg "" "" "EXTRA_OPTIONS" ${ARGN})
    string(SHA256 hash "${dir};${arg_EXTRA_OPTIONS}")
    string(SUBSTRING ${hash} 0 8 test_id)
    set(test_name "${dir} ${arg_EXTRA_OPTIONS} (test_id=${test_id})")
    add_test(
        NAME "${test_name}"
        COMMAND ${CMAKE_CTEST_COMMAND}
            --build-and-test    "${CMAKE_CURRENT_SOURCE_DIR}/${dir}"
                                "${CMAKE_CURRENT_BINARY_DIR}/${dir}/${test_id}/build"
            ${arg_EXTRA_OPTIONS}
            --build-config      "Release"
            --build-generator   "${CMAKE_GENERATOR}"
            --build-target      install
            --build-options     "-DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/${dir}/${test_id}/install"
                                "-DCMAKE_PREFIX_PATH=${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-install"
    )
    set_tests_properties("${test_name}" PROPERTIES DEPENDS ${PROJECT_NAME}-install)
endfunction()
# gersemi: on

add_cmake_test(test_project)
add_cmake_test(test_project EXTRA_OPTIONS "--build-noclean")
add_cmake_test(test_project EXTRA_OPTIONS "--build-noclean" "--build-two-config")

add_cmake_test(test_project_without_deps)
add_cmake_test(test_project_without_deps EXTRA_OPTIONS "--build-noclean")
add_cmake_test(test_project_without_deps EXTRA_OPTIONS "--build-noclean" "--build-two-config")

add_cmake_test(packaging/fetchcontent)

add_subdirectory(modules)
