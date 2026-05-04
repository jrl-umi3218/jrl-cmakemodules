nanobind_add_module(pb_pywrap
    NB_STATIC STABLE_ABI LTO NB_SUPPRESS_WARNINGS
    bindings.cpp
)
jrl_check_python_module_name(pb_pywrap)
target_link_libraries(pb_pywrap PRIVATE pb)
jrl_target_set_default_compile_options(pb_pywrap PRIVATE)
jrl_target_set_output_directory(pb_pywrap OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/site-packages/pb)

jrl_python_generate_init_py(
    pb_pywrap
    OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib/site-packages/pb/__init__.py
)

if(COMMAND nanobind_add_stub)
    nanobind_add_stub(
        pb_pywrap_stub
        MODULE pb.pb_pywrap
        OUTPUT ${CMAKE_BINARY_DIR}/lib/site-packages/pb/pb_pywrap.pyi
        PYTHON_PATH ${CMAKE_BINARY_DIR}/lib/site-packages
        DEPENDS pb_pywrap
        VERBOSE
    )
endif()

jrl_python_compile_all(DIRECTORY
    ${CMAKE_BINARY_DIR}/lib/site-packages/pb
    VERBOSE
)

jrl_python_compute_install_dir(python_install_dir)
install(
    DIRECTORY ${CMAKE_BINARY_DIR}/lib/site-packages/pb
    DESTINATION ${python_install_dir}
    FILES_MATCHING
    PATTERN "*.py"
    PATTERN "*.pyc"
    PATTERN "*.pyi"
    PATTERN "*.typed"
    PATTERN "*.so"
    PATTERN "*.pyd"
)
