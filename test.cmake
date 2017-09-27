# Copyright (C) 2008-2014 LAAS-CNRS, JRL AIST-CNRS.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Configure the unit test compilation
IF(NOT DEFINED DISABLE_TESTS)
  SET(DISABLE_TESTS OFF)
ENDIF(NOT DEFINED DISABLE_TESTS)
IF(DISABLE_TESTS)
  ADD_TEST(ctest_build_tests "${CMAKE_COMMAND}" --build ${CMAKE_BINARY_DIR} --target build_tests)
  ADD_CUSTOM_TARGET(build_tests)
ENDIF(DISABLE_TESTS)

# ADD_UNIT_TEST(NAME)
# ----------------------
#
# The behaviour of this function depends on DISABLE_TESTS option:
# - if OFF (default), nothing special is done.
# - if ON, the unit-test is not compiled with target all.
#          A target build_tests is added to compile the tests and
#          a test that run target build_tests is run before all other tests.
#
MACRO(ADD_UNIT_TEST NAME SOURCE)
  IF(DISABLE_TESTS)
    ADD_EXECUTABLE(${NAME} EXCLUDE_FROM_ALL ${SOURCE})
    ADD_DEPENDENCIES(build_tests ${NAME})
    ADD_TEST(${NAME} ${RUNTIME_OUTPUT_DIRECTORY}/${NAME})
    SET_TESTS_PROPERTIES ( ${NAME} PROPERTIES DEPENDS ctest_build_tests)
  ELSE(DISABLE_TESTS)
    ADD_EXECUTABLE(${NAME} ${SOURCE})
    ADD_TEST(${NAME} ${RUNTIME_OUTPUT_DIRECTORY}/${NAME})
  ENDIF(DISABLE_TESTS)
ENDMACRO(ADD_UNIT_TEST NAME SOURCE)

# DEFINE_UNIT_TEST(NAME LIB)
# ----------------------
#
# Compile a program and add it as a test
#
MACRO(DEFINE_UNIT_TEST NAME LIB)
  ADD_UNIT_TEST(${NAME} ${NAME}.cc)
  TARGET_LINK_LIBRARIES(${NAME} ${LIB})
ENDMACRO(DEFINE_UNIT_TEST)
