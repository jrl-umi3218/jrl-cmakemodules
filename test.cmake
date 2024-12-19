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
    AUTHOR_WARNING
    "DISABLE_TESTS is deprecated. Use BUILD_TESTING instead."
  )
  if(DISABLE_TESTS)
    set(BUILD_TESTING OFF CACHE BOOL "")
  else()
    set(BUILD_TESTING ON CACHE BOOL "")
  endif()
endif(DEFINED DISABLE_TESTS)

if(NOT TARGET build_tests)
  add_custom_target(build_tests)
endif()

# Add new target 'run_tests' to improve integration with build tooling
if(NOT CMAKE_GENERATOR MATCHES "Visual Studio|Xcode" AND NOT TARGET run_tests)
  if(NOT TARGET run_tests)
    add_custom_target(run_tests)
  endif()
  add_custom_target(
    ${PROJECT_NAME}-run_tests
    COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure -V
    VERBATIM
  )
  add_dependencies(run_tests ${PROJECT_NAME}-run_tests)
endif()

if(NOT DEFINED ctest_build_tests_exists)
  set_property(GLOBAL PROPERTY ctest_build_tests_exists OFF)
endif(NOT DEFINED ctest_build_tests_exists)

# .rst: .. command:: CREATE_CTEST_BUILD_TESTS_TARGET
#
# Create target ctest_build_tests if does not exist yet.
#
macro(CREATE_CTEST_BUILD_TESTS_TARGET)
  get_property(
    ctest_build_tests_exists_value
    GLOBAL
    PROPERTY ctest_build_tests_exists
  )
  if(NOT BUILD_TESTING)
    if(NOT ctest_build_tests_exists_value)
      add_test(
        ctest_build_tests
        "${CMAKE_COMMAND}"
        --build
        ${PROJECT_BINARY_DIR}
        --target
        build_tests
        --
        $ENV{MAKEFLAGS}
      )
      set_property(GLOBAL PROPERTY ctest_build_tests_exists ON)
    endif(NOT ctest_build_tests_exists_value)
  endif(NOT BUILD_TESTING)
endmacro(CREATE_CTEST_BUILD_TESTS_TARGET)

# .rst: .. command:: ADD_UNIT_TEST (NAME SOURCE [SOURCE ...])
#
# The behaviour of this function depends on :variable:`BUILD_TESTING` option.
#
macro(ADD_UNIT_TEST NAME)
  CREATE_CTEST_BUILD_TESTS_TARGET()

  if(NOT BUILD_TESTING)
    add_executable(${NAME} EXCLUDE_FROM_ALL ${ARGN})
  else(NOT BUILD_TESTING)
    add_executable(${NAME} ${ARGN})
  endif(NOT BUILD_TESTING)

  add_dependencies(build_tests ${NAME})

  if(ENABLE_COVERAGE)
    add_test(
      NAME ${NAME}
      COMMAND
        ${KCOV} --include-path=${CMAKE_SOURCE_DIR} ${KCOV_DIR}/${NAME} ${NAME}
    )
  else()
    add_test(NAME ${NAME} COMMAND ${NAME})
  endif()
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
endmacro(ADD_UNIT_TEST NAME SOURCE)

# .rst: .. command:: COMPUTE_PYTHONPATH (result [MODULES...])
#
# Fill `result` with all necessary environment variables (`PYTHONPATH`,
# `LD_LIBRARY_PATH`, `DYLD_LIBRARY_PATH`) to load the `MODULES` in
# `PROJECT_BINARY_DIR` (`PROJECT_BINARY_DIR/MODULE_PATH`)
#
# Path in PROJECT_PYTHON_PACKAGES_IN_WORKSPACE are added to the PYTHONPATH.
#
# .. note:: :command:`FINDPYTHON` should have been called first.
#
function(COMPUTE_PYTHONPATH result)
  set(MODULES "${ARGN}") # ARGN is not a variable
  foreach(MODULE_PATH IN LISTS MODULES)
    if(CMAKE_GENERATOR MATCHES "Visual Studio|Xcode")
      list(APPEND PYTHONPATH "${PROJECT_BINARY_DIR}/${MODULE_PATH}/$<CONFIG>")
    else()
      list(APPEND PYTHONPATH "${PROJECT_BINARY_DIR}/${MODULE_PATH}")
    endif()
  endforeach(MODULE_PATH IN LISTS MODULES)

  if(DEFINED ENV{PYTHONPATH})
    list(APPEND PYTHONPATH "$ENV{PYTHONPATH}")
  endif(DEFINED ENV{PYTHONPATH})

  list(APPEND PYTHONPATH ${PROJECT_PYTHON_PACKAGES_IN_WORKSPACE})

  # get path separator to join those paths
  execute_process(
    COMMAND "${PYTHON_EXECUTABLE}" "-c" "import os; print(os.pathsep)"
    OUTPUT_VARIABLE PATHSEP
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  list(REMOVE_DUPLICATES PYTHONPATH)
  if(WIN32)
    # ensure that severals paths stay together as ENV variable PYTHONPATH when
    # passed to python test via PROPERTIES
    string(REPLACE ";" "\\\;" PYTHONPATH_STR "${PYTHONPATH}")
  else(WIN32)
    string(REPLACE ";" "${PATHSEP}" PYTHONPATH_STR "${PYTHONPATH}")
  endif(WIN32)
  set(ENV_VARIABLES "PYTHONPATH=${PYTHONPATH_STR}")
  if(APPLE)
    list(APPEND ENV_VARIABLES "LD_LIBRARY_PATH=$ENV{LD_LIBRARY_PATH}")
    list(APPEND ENV_VARIABLES "DYLD_LIBRARY_PATH=$ENV{DYLD_LIBRARY_PATH}")
  endif(APPLE)

  set(${result} ${ENV_VARIABLES} PARENT_SCOPE)
endfunction()

# .rst: .. command:: ADD_PYTHON_UNIT_TEST (NAME SOURCE [MODULES...])
#
# Add a test called `NAME` that runs an equivalent of ``python ${SOURCE}``,
# optionnaly with a `PYTHONPATH` set to `PROJECT_BINARY_DIR/MODULE_PATH` for
# each MODULES `SOURCE` is relative to `PROJECT_SOURCE_DIR`
#
# .. note:: :command:`FINDPYTHON` should have been called first.
#
macro(ADD_PYTHON_UNIT_TEST NAME SOURCE)
  if(ENABLE_COVERAGE)
    # run this python test to gather C++ coverage of python bindings
    add_test(
      NAME ${NAME}
      COMMAND
        ${KCOV} --include-path=${CMAKE_SOURCE_DIR} ${KCOV_DIR}/${NAME}
        ${PYTHON_EXECUTABLE} "${PROJECT_SOURCE_DIR}/${SOURCE}"
    )
    # run this python test again, but this time to gather python coverage
    add_test(
      NAME ${NAME}-pycov
      COMMAND
        ${KCOV} --include-path=${CMAKE_SOURCE_DIR} ${KCOV_DIR}/${NAME}
        "${PROJECT_SOURCE_DIR}/${SOURCE}"
    )
  else()
    add_test(
      NAME ${NAME}
      COMMAND ${PYTHON_EXECUTABLE} "${PROJECT_SOURCE_DIR}/${SOURCE}"
    )
  endif()

  set(MODULES "${ARGN}") # ARGN is not a variable
  set(PYTHONPATH)
  COMPUTE_PYTHONPATH(ENV_VARIABLES ${MODULES})
  set_tests_properties(${NAME} PROPERTIES ENVIRONMENT "${ENV_VARIABLES}")
  if(ENABLE_COVERAGE)
    set_tests_properties(
      ${NAME}-pycov
      PROPERTIES ENVIRONMENT "${ENV_VARIABLES}"
    )
  endif()
endmacro(ADD_PYTHON_UNIT_TEST NAME SOURCE)

# .rst: .. command:: ADD_PYTHON_MEMORYCHECK_UNIT_TEST (NAME SOURCE [MODULES...])
#
# Add a test called `NAME` that runs an equivalent of ``valgrind -- python
# ${SOURCE}``, optionnaly with a `PYTHONPATH` set to
# `PROJECT_BINARY_DIR/MODULE_PATH` for each MODULES. `SOURCE` is relative to
# `PROJECT_SOURCE_DIR`.
#
# .. note:: :command:`FINDPYTHON` should have been called first. .. note:: Only
# work if valgrind is installed
#
macro(ADD_PYTHON_MEMORYCHECK_UNIT_TEST NAME SOURCE)
  ADD_PYTHON_MEMORYCHECK_UNIT_TEST_V2(
    NAME
    ${NAME}
    SOURCE
    ${SOURCE}
    MODULES
    ${ARGN}
  )
endmacro()

# ~~~
# .rst: .. command:: ADD_PYTHON_MEMORYCHECK_UNIT_TEST_V2(
#   NAME <name>
#   SOURCE <source>
#   [SUPP <supp>]
#   [MODULES <modules>...])
# ~~~
#
# Add a test that run a Python script through Valgrind to test if a Python
# script leak memory.
#
# :param NAME: Test name.
#
# :param SOURCE: Test source path relative to project source dir.
#
# :param SUPP: optional valgrind suppressions file path relative to project
# source dir.
#
# :param MODULES: Set the `PYTHONPATH` environment variable to
# `PROJECT_BINARY_DIR/<modules>...`.
#
# .. note:: :command:`FINDPYTHON` should have been called first.
#
# .. note:: Only work if valgrind is installed.
macro(ADD_PYTHON_MEMORYCHECK_UNIT_TEST_V2)
  if(MEMORYCHECK_COMMAND AND MEMORYCHECK_COMMAND MATCHES ".*valgrind$")
    set(options)
    set(oneValueArgs NAME SOURCE SUPP)
    set(multiValueArgs MODULES)
    cmake_parse_arguments(
      ARGS
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN}
    )

    set(TEST_FILE_NAME memorycheck_unit_test_${ARGS_NAME}.cmake)
    set(PYTHON_TEST_SCRIPT "${PROJECT_SOURCE_DIR}/${ARGS_SOURCE}")
    if(ARGS_SUPP)
      set(VALGRIND_SUPP_FILE "${PROJECT_SOURCE_DIR}/${ARGS_SUPP}")
    endif()
    configure_file(
      ${PROJECT_JRL_CMAKE_MODULE_DIR}/memorycheck_unit_test.cmake.in
      ${TEST_FILE_NAME}
      @ONLY
    )

    add_test(NAME ${ARGS_NAME} COMMAND ${CMAKE_COMMAND} -P ${TEST_FILE_NAME})

    COMPUTE_PYTHONPATH(ENV_VARIABLES ${ARGS_MODULES})
    set_tests_properties(${ARGS_NAME} PROPERTIES ENVIRONMENT "${ENV_VARIABLES}")
  endif()
endmacro()

# .rst: .. command:: ADD_JULIA_UNIT_TEST (NAME SOURCE [MODULES...])
#
# Add a test called `NAME` that runs an equivalent of ``julia ${SOURCE}``.
#
macro(ADD_JULIA_UNIT_TEST NAME SOURCE)
  add_test(
    NAME ${NAME}
    COMMAND ${Julia_EXECUTABLE} "${PROJECT_SOURCE_DIR}/${SOURCE}"
  )
endmacro(ADD_JULIA_UNIT_TEST NAME SOURCE)

# DEFINE_UNIT_TEST(NAME LIB)
# ----------------------
#
# Compile a program and add it as a test
#
macro(DEFINE_UNIT_TEST NAME LIB)
  ADD_UNIT_TEST(${NAME} ${NAME}.cc)
  target_link_libraries(${NAME} ${PUBLIC_KEYWORD} ${LIB})
endmacro(DEFINE_UNIT_TEST)
