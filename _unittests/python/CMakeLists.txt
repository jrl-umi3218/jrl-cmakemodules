cmake_minimum_required(VERSION 3.22)

# These variables have to be defined before running SETUP_PROJECT
set(PROJECT_NAME jrl-cmakemodules-python)
set(PROJECT_VERSION 0.0.0)
set(PROJECT_DESCRIPTION "JRL CMake module - python")
set(PROJECT_URL http://jrl-cmakemodules.readthedocs.io)

include(../macros.cmake)

include(../../base.cmake)
include(../../python.cmake)

COMPUTE_PROJECT_ARGS(PROJECT_ARGS)
project(${PROJECT_NAME} ${PROJECT_ARGS})
FINDPYTHON()

check_exist_variable(PYTHON_SITELIB "")

PYTHON_INSTALL_ON_SITE(jrl_cmakemodule python.py)
