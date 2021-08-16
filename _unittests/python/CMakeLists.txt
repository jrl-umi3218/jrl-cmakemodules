cmake_minimum_required(VERSION 3.1)

# These variables have to be defined before running SETUP_PROJECT
set(PROJECT_NAME jrl-cmakemodules-python)
set(PROJECT_VERSION 0.0.0)
set(PROJECT_DESCRIPTION "JRL CMake module - python")
set(PROJECT_URL http://jrl-cmakemodules.readthedocs.io)

include(../macros.cmake)

include(../../base.cmake)
include(../../python.cmake)

compute_project_args(PROJECT_ARGS)
project(${PROJECT_NAME} ${PROJECT_ARGS})
findpython()

check_exist_variable(PYTHON_SITELIB "")

python_install_on_site(jrl_cmakemodule python.py)
