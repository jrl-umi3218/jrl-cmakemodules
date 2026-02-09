nanobind_add_module(test_project_pywrap
    NB_STATIC STABLE_ABI LTO NB_SUPPRESS_WARNINGS
    bindings.cpp
)
jrl_check_python_module_name(test_project_pywrap)
target_link_libraries(test_project_pywrap PRIVATE test_project)
jrl_target_set_default_compile_options(test_project_pywrap PRIVATE)
jrl_target_set_output_directory(test_project_pywrap OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/site-packages/test_project)

jrl_python_generate_init_py(
    test_project_pywrap
    OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib/site-packages/test_project/__init__.py
)

nanobind_add_stub(
    test_project_pywrap_stub
    MODULE test_project.test_project_pywrap
    OUTPUT ${CMAKE_BINARY_DIR}/lib/site-packages/test_project/test_project_pywrap.pyi
    PYTHON_PATH ${CMAKE_BINARY_DIR}/lib/site-packages
    DEPENDS test_project_pywrap
    VERBOSE
)

jrl_python_compile_all(DIRECTORY
    ${CMAKE_BINARY_DIR}/lib/site-packages/test_project
    VERBOSE
)

jrl_python_compute_install_dir(python_install_dir)
install(
    DIRECTORY ${CMAKE_BINARY_DIR}/lib/site-packages/test_project
    DESTINATION ${python_install_dir}
    FILES_MATCHING
    PATTERN "*.py"
    PATTERN "*.pyc"
    PATTERN "*.pyi"
    PATTERN "*.typed"
    PATTERN "*.so"
    PATTERN "*.pyd"
)
