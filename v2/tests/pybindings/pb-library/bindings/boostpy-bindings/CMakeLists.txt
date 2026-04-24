jrl_boostpy_add_module(pb_pywrap_bp bindings.cpp)
jrl_check_python_module_name(pb_pywrap_bp)
target_link_libraries(pb_pywrap_bp PRIVATE pb)
jrl_target_set_default_compile_options(pb_pywrap_bp PRIVATE)
jrl_target_set_output_directory(pb_pywrap_bp OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/site-packages/pb_bp)

jrl_python_generate_init_py(
    pb_pywrap_bp
    OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib/site-packages/pb_bp/__init__.py
)

jrl_boostpy_add_stubs(
    pb_pywrap_bp_stubs
    MODULE pb_bp.pb_pywrap_bp
    OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib/site-packages
    PYTHON_PATH ${CMAKE_BINARY_DIR}/lib/site-packages
    DEPENDS pb_pywrap_bp
    VERBOSE
)

jrl_python_compile_all(DIRECTORY
    ${CMAKE_BINARY_DIR}/lib/site-packages/pb_bp
    VERBOSE
)

jrl_python_compute_install_dir(python_install_dir)
install(
    DIRECTORY ${CMAKE_BINARY_DIR}/lib/site-packages/pb_bp
    DESTINATION ${python_install_dir}
    FILES_MATCHING
    PATTERN "*.py"
    PATTERN "*.pyc"
    PATTERN "*.pyi"
    PATTERN "*.typed"
    PATTERN "*.so"
    PATTERN "*.pyd"
)
