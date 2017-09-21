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

# DEFINE_UNIT_TEST(NAME LIB)
# ----------------------
#
# Compile a program and add it as a test
#
MACRO(DEFINE_UNIT_TEST NAME LIB)
  ADD_EXECUTABLE(${NAME} ${NAME}.cc)
  TARGET_LINK_LIBRARIES(${NAME} ${LIB})
  ADD_TEST(${NAME} ${RUNTIME_OUTPUT_DIRECTORY}/${NAME})
ENDMACRO(DEFINE_UNIT_TEST)

# ADD_UNIT_TESTS_SUBDIRECTORY(NAME)
# ----------------------
#
# Add a subdirectory containing unit-tests.
# If COMPILE_UNIT_TESTS if set to FALSE, then
# ADD_SUBDIRECTORY is called with the EXCLUDE_FROM_ALL
# option
#
MACRO(ADD_UNIT_TESTS_SUBDIRECTORY NAME)
  IF (COMPILE_UNIT_TESTS)
    ADD_SUBDIRECTORY(${NAME})
  ELSE (COMPILE_UNIT_TESTS)
    ADD_SUBDIRECTORY(${NAME} EXCLUDE_FROM_ALL)
  ENDIF (COMPILE_UNIT_TESTS)
ENDMACRO(ADD_UNIT_TESTS_SUBDIRECTORY NAME)
