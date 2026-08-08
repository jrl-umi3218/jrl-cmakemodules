cmake_minimum_required(VERSION 3.22)

project(pmv-required-fail VERSION 1.0.0 LANGUAGES NONE)

find_package(jrl-cmakemodules 2.0.0 CONFIG REQUIRED)

jrl_find_python(3.9 REQUIRED COMPONENTS Interpreter)

set(fake_modules_dir "${CMAKE_CURRENT_BINARY_DIR}/fake_python_modules")
file(WRITE "${fake_modules_dir}/pmv_versioned/__init__.py" "__version__ = \"4.12.2\"\n")
set(ENV{PYTHONPATH} "${fake_modules_dir}")

# The module is installed but too old: a REQUIRED check must fail the configure.
jrl_check_python_module(pmv_versioned 99.0 REQUIRED)

message(FATAL_ERROR "[${PROJECT_NAME}] jrl_check_python_module should have errored.")
