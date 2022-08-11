# Copyright (C) 2008-2020 LAAS-CNRS, JRL AIST-CNRS, INRIA.
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.

# .rst: .. variable:: DISABLE_TESTS :deprecated:
#
# Boolean variable to configure unit test compilation declared with
# :command:`ADD_UNIT_TEST`.
#
# A target *build_tests* is added to compile the unit-tests. In all cases,
# ``make all && make test`` compiles and runs the unit-tests.
#
# * if ``OFF`` (default), the unit-tests are compiled with target *all*, as
#   usual.
# * if ``ON``, a unit-test called *ctest_build_tests* is added. It is equivalent
#   to the command ``make build_tests``. All unit-test added with
#   :command:`ADD_UNIT_TEST` will be executed after unit-test
#   *ctest_build_tests* completed.
#
# Thus, the unit-tests are not compiled with target *all* but with target
# *test*. unit-test  is added and all tests added with
if(DEFINED DISABLE_TESTS)
  message(
    AUTHOR_WARNING "DISABLE_TESTS is deprecated. Use BUILD_TESTING instead.")
  if(DISABLE_TESTS)
    set(BUILD_TESTING
        OFF
        CACHE BOOL "")
  else()
    set(BUILD_TESTING
        ON
        CACHE BOOL "")
  endif()
endif(DEFINED DISABLE_TESTS)

if(NOT TARGET build_tests)
  add_custom_target(build_tests)
endif()

# Add new target 'run_tests' to improve integration with build tooling
if(NOT CMAKE_GENERATOR MATCHES "Visual Studio" AND NOT TARGET run_tests)
  add_custom_target(
    run_tests
    COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure -V
    VERBATIM)
endif()

if(NOT DEFINED ctest_build_tests_exists)
  set_property(GLOBAL PROPERTY ctest_build_tests_exists OFF)
endif(NOT DEFINED ctest_build_tests_exists)

# .rst: .. command:: CREATE_CTEST_BUILD_TESTS_TARGET
#
# Create target ctest_build_tests if does not exist yet.
#
macro(CREATE_CTEST_BUILD_TESTS_TARGET)
  get_property(ctest_build_tests_exists_value GLOBAL
               PROPERTY ctest_build_tests_exists)
  if(NOT BUILD_TESTING)
    if(NOT ctest_build_tests_exists_value)
      add_test(
        ctest_build_tests
        "${CMAKE_COMMAND}"
        --build
        ${CMAKE_BINARY_DIR}
        --target
        build_tests
        --
        $ENV{MAKEFLAGS})
      set_property(GLOBAL PROPERTY ctest_build_tests_exists ON)
    endif(NOT ctest_build_tests_exists_value)
  endif(NOT BUILD_TESTING)
endmacro(CREATE_CTEST_BUILD_TESTS_TARGET)

# .rst: .. command:: ADD_UNIT_TEST (NAME SOURCE [SOURCE ...])
#
# The behaviour of this function depends on :variable:`BUILD_TESTING` option.
#
macro(ADD_UNIT_TEST NAME)
  create_ctest_build_tests_target()

  if(NOT BUILD_TESTING)
    add_executable(${NAME} EXCLUDE_FROM_ALL ${ARGN})
  else(NOT BUILD_TESTING)
    add_executable(${NAME} ${ARGN})
  endif(NOT BUILD_TESTING)

  add_dependencies(build_tests ${NAME})

  add_test(${NAME} ${RUNTIME_OUTPUT_DIRECTORY}/${NAME})
  # Support definition of DYLD_LIBRARY_PATH for OSX systems
  if(APPLE)
    set_tests_properties(
      ${NAME}
      PROPERTIES
        ENVIRONMENT
        "LD_LIBRARY_PATH=$ENV{LD_LIBRARY_PATH};DYLD_LIBRARY_PATH=$ENV{DYLD_LIBRARY_PATH}"
    )
  endif(APPLE)

  if(NOT BUILD_TESTING)
    set_tests_properties(${NAME} PROPERTIES DEPENDS ctest_build_tests)
  endif(NOT BUILD_TESTING)
endmacro(
  ADD_UNIT_TEST
  NAME
  SOURCE)

# .rst: .. command:: ADD_PYTHON_UNIT_TEST (NAME SOURCE [MODULES...])
#
# Add a test called `NAME` that runs an equivalent of ``python ${SOURCE}``,
# optionnaly with a `PYTHONPATH` set to `CMAKE_BINARY_DIR/MODULE_PATH` for each
# MODULES `SOURCE` is relative to `PROJECT_SOURCE_DIR`
#
# .. note:: :command:`FINDPYTHON` should have been called first.
#
macro(ADD_PYTHON_UNIT_TEST NAME SOURCE)
  if(ENABLE_COVERAGE)
    set_property(GLOBAL PROPERTY JRL_CMAKEMODULES_HAS_PYTHON_COVERAGE ON)
    set(PYTHONPATH "${CMAKE_INSTALL_PREFIX}/${PYTHON_SITELIB}")
    add_test(
      NAME ${NAME}
      COMMAND ${PYTHON_EXECUTABLE} -m coverage run --branch -p
              --source=${PYTHONPATH} "${PROJECT_SOURCE_DIR}/${SOURCE}"
      WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
  else()
    add_test(NAME ${NAME} COMMAND ${PYTHON_EXECUTABLE}
                                  "${PROJECT_SOURCE_DIR}/${SOURCE}")
    set(PYTHONPATH)
  endif()

  set(MODULES "${ARGN}") # ARGN is not a variable
  foreach(MODULE_PATH IN LISTS MODULES)
    list(APPEND PYTHONPATH "${CMAKE_BINARY_DIR}/${MODULE_PATH}")
    if(CMAKE_GENERATOR MATCHES "Visual Studio")
      list(APPEND PYTHONPATH "${CMAKE_BINARY_DIR}/${MODULE_PATH}/$<CONFIG>")
    endif(CMAKE_GENERATOR MATCHES "Visual Studio")
  endforeach(MODULE_PATH IN LISTS MODULES)

  if(DEFINED ENV{PYTHONPATH})
    list(APPEND PYTHONPATH "$ENV{PYTHONPATH}")
  endif(DEFINED ENV{PYTHONPATH})

  # get path separator to join those paths
  execute_process(
    COMMAND "${PYTHON_EXECUTABLE}" "-c" "import os; print(os.pathsep)"
    OUTPUT_VARIABLE PATHSEP
    OUTPUT_STRIP_TRAILING_WHITESPACE)

  if(WIN32)
    string(REPLACE ";" ":" PYTHONPATH_STR "${PYTHONPATH}")
  else(WIN32)
    string(REPLACE ";" "${PATHSEP}" PYTHONPATH_STR "${PYTHONPATH}")
  endif(WIN32)
  set(ENV_VARIABLES "PYTHONPATH=${PYTHONPATH_STR}")
  if(APPLE)
    list(APPEND ENV_VARIABLES "LD_LIBRARY_PATH=$ENV{LD_LIBRARY_PATH}")
    list(APPEND ENV_VARIABLES "DYLD_LIBRARY_PATH=$ENV{DYLD_LIBRARY_PATH}")
  endif(APPLE)
  set_tests_properties(${NAME} PROPERTIES ENVIRONMENT "${ENV_VARIABLES}")
endmacro(
  ADD_PYTHON_UNIT_TEST
  NAME
  SOURCE)

# .rst: .. command:: ADD_JULIA_UNIT_TEST (NAME SOURCE [MODULES...])
#
# Add a test called `NAME` that runs an equivalent of ``julia ${SOURCE}``.
#
macro(ADD_JULIA_UNIT_TEST NAME SOURCE)
  add_test(NAME ${NAME} COMMAND ${Julia_EXECUTABLE}
                                "${PROJECT_SOURCE_DIR}/${SOURCE}")
endmacro(
  ADD_JULIA_UNIT_TEST
  NAME
  SOURCE)

# DEFINE_UNIT_TEST(NAME LIB)
# ----------------------
#
# Compile a program and add it as a test
#
macro(DEFINE_UNIT_TEST NAME LIB)
  add_unit_test(${NAME} ${NAME}.cc)
  target_link_libraries(${NAME} ${PUBLIC_KEYWORD} ${LIB})
endmacro(DEFINE_UNIT_TEST)
