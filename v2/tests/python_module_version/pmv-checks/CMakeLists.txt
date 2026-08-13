cmake_minimum_required(VERSION 3.22)

project(pmv-checks VERSION 1.0.0 LANGUAGES NONE)

find_package(jrl-cmakemodules 2.0.0 CONFIG REQUIRED)

jrl_find_python(3.10 REQUIRED COMPONENTS Interpreter)

# Fake python modules with a known version, made importable through PYTHONPATH.
set(fake_modules_dir "${CMAKE_CURRENT_BINARY_DIR}/fake_python_modules")
file(WRITE "${fake_modules_dir}/pmv_versioned/__init__.py" "__version__ = \"4.12.2\"\n")
file(WRITE "${fake_modules_dir}/pmv_unversioned/__init__.py" "")
set(ENV{PYTHONPATH} "${fake_modules_dir}")

# No version requested.
jrl_check_python_module(pmv_versioned REQUIRED)
_jrl_check("${pmv_versioned_FOUND}")
_jrl_check("${pmv_versioned_VERSION}" STREQUAL "4.12.2")

# Minimum version, as the first positional argument like find_package.
jrl_check_python_module(pmv_versioned 4.5 REQUIRED)
_jrl_check("${pmv_versioned_FOUND}")

jrl_check_python_module(pmv_versioned 4.12.2 REQUIRED)
_jrl_check("${pmv_versioned_FOUND}")

# A version that is too recent is reported as not found, the detected version is
# still exposed.
jrl_check_python_module(pmv_versioned 99.0 QUIET)
_jrl_check(NOT "${pmv_versioned_FOUND}")
_jrl_check("${pmv_versioned_VERSION}" STREQUAL "4.12.2")

# EXACT matches on the requested components only.
jrl_check_python_module(pmv_versioned 4.12 EXACT REQUIRED)
_jrl_check("${pmv_versioned_FOUND}")

jrl_check_python_module(pmv_versioned 4.11 EXACT QUIET)
_jrl_check(NOT "${pmv_versioned_FOUND}")

# Version ranges.
jrl_check_python_module(pmv_versioned 4.0...5.0 REQUIRED)
_jrl_check("${pmv_versioned_FOUND}")

jrl_check_python_module(pmv_versioned 4.0...<5 REQUIRED)
_jrl_check("${pmv_versioned_FOUND}")

jrl_check_python_module(pmv_versioned 4.0...<4.12 QUIET)
_jrl_check(NOT "${pmv_versioned_FOUND}")

jrl_check_python_module(pmv_versioned 5.0...6.0 QUIET)
_jrl_check(NOT "${pmv_versioned_FOUND}")

# A module without any version information is found, unless a version is requested.
jrl_check_python_module(pmv_unversioned REQUIRED)
_jrl_check("${pmv_unversioned_FOUND}")

jrl_check_python_module(pmv_unversioned 1.0 QUIET)
_jrl_check(NOT "${pmv_unversioned_FOUND}")

# A missing module stays not found when a version is requested.
jrl_check_python_module(pmv_missing 1.0 QUIET)
_jrl_check(NOT "${pmv_missing_FOUND}")

message(STATUS "[${PROJECT_NAME}] all jrl_check_python_module version checks passed.")
