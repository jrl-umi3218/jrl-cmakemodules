jrl_boostpy_add_module(test_project_pywrap_bp bindings.cpp)
jrl_check_python_module_name(test_project_pywrap_bp)
target_link_libraries(test_project_pywrap_bp PRIVATE test_project)
jrl_target_set_default_compile_options(test_project_pywrap_bp PRIVATE)
jrl_target_set_output_directory(test_project_pywrap_bp OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/site-packages/test_project_bp)

jrl_python_generate_init_py(
    test_project_pywrap_bp
    OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib/site-packages/test_project_bp/__init__.py
)

jrl_boostpy_add_stubs(
    test_project_pywrap_bp_stubs
    MODULE test_project_bp.test_project_pywrap_bp
    OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib/site-packages
    PYTHON_PATH ${CMAKE_BINARY_DIR}/lib/site-packages
    DEPENDS test_project_pywrap_bp
    VERBOSE
)

jrl_python_compile_all(DIRECTORY
    ${CMAKE_BINARY_DIR}/lib/site-packages/test_project_bp
    VERBOSE
)

jrl_python_compute_install_dir(python_install_dir)
install(
    DIRECTORY ${CMAKE_BINARY_DIR}/lib/site-packages/test_project_bp
    DESTINATION ${python_install_dir}
    FILES_MATCHING
    PATTERN "*.py"
    PATTERN "*.pyc"
    PATTERN "*.pyi"
    PATTERN "*.typed"
    PATTERN "*.so"
    PATTERN "*.pyd"
)
