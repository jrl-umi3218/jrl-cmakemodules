# Copyright (C) 2010 Florent Lamiraux, Thomas Moulard, JRL, CNRS/AIST.
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

 # ------ #
 # README #
 # ------ #

# This file factorizes all rules to define a project for JRL or LAAS.
# It supposes that some variables have already been defined:
# - PROJECT_NAME	Project name.
#			Please keep respect our coding style and choose a name
#			which respects the following regexp: [a-z][a-z0-9-]*
#			I.e. a lower-case letter then one or more lower-case
#			letter, number or hyphen ``-''.
# - PROJECT_VERSION     Project version (X.Y.Z where X, Y, Z are unsigned
#                       integers).
# - PROJECT_DESCRIPTION One line summary of the package goal.
# - PROJECT_URL		Project's website.
#
# Please note that functions starting with an underscore are internal
# functions and should not be used directly.

 # ---- #
 # TODO #
 # ---- #

# - make install should trigger make doc
# - unit tests should be tagged as
#   EXCLUDE_FROM_ALL and make test should trigger their compilation.

# Include base features.
INCLUDE(cmake/compiler.cmake)
INCLUDE(cmake/debian.cmake)
INCLUDE(cmake/dist.cmake)
INCLUDE(cmake/doxygen.cmake)
INCLUDE(cmake/header.cmake)
INCLUDE(cmake/pkg-config.cmake)
INCLUDE(cmake/uninstall.cmake)

 # --------- #
 # Constants #
 # --------- #

# Variables requires by SETUP_PROJECT.
SET(REQUIRED_VARIABLES
  PROJECT_NAME PROJECT_VERSION PROJECT_DESCRIPTION PROJECT_URL)

 # --------------------- #
 # Project configuration #
 # --------------------- #

# _ADD_TO_LIST LIST VALUE
# -------------
#
# Add a value to a comma-separated list.
#
# LIST		: the list.
# VALUE		: the value to be appended.
# SEPARATOR	: the separation symol.
#
MACRO(_ADD_TO_LIST LIST VALUE SEPARATOR)
  IF("${${LIST}}" STREQUAL "")
    SET(${LIST} "${VALUE}")
  ELSE("${${LIST}}" STREQUAL "")
    SET(${LIST} "${${LIST}}${SEPARATOR} ${VALUE}")
  ENDIF("${${LIST}}" STREQUAL "")
ENDMACRO(_ADD_TO_LIST LIST VALUE)

# _CONCATE_ARGUMENTS
# -------------
#
# Concatenate all arguments into the output variable.
#
# OUTPUT	: the output variable.
# SEPARTOR	: the list separation symbol.
# ARG1...ARGN	: the values to be concatenated.
#
MACRO(_CONCATENATE_ARGUMENTS OUTPUT SEPARATOR)
  FOREACH(I RANGE 2 ${ARGC})
    _ADD_TO_LIST("${OUTPUT}" "${ARGV${I}}" "${SEPARATOR}")
  ENDFOREACH(I RANGE 2 ${ARGC})
  MESSAGE(${${OUTPUT}})
ENDMACRO(_CONCATENATE_ARGUMENTS OUTPUT)


# SETUP_PROJECT
# -------------
#
# Initialize the project. Should be called first in the root
# CMakeList.txt.
#
# This function does not take any argument but check that some
# variables are defined (see documentation at the beginning of this
# file).
#
MACRO(SETUP_PROJECT)
  # Check that required variables are defined.
  FOREACH(VARIABLE ${REQUIRED_VARIABLES})
    IF (NOT DEFINED ${VARIABLE})
      MESSAGE(FATAL_ERROR
	"Required variable ``${VARIABLE}'' has not been defined.")
    ENDIF(NOT DEFINED ${VARIABLE})
  ENDFOREACH(VARIABLE)

  # Define project name.
  PROJECT(${PROJECT_NAME} CXX)

  # Be verbose by default.
  SET(CMAKE_VERBOSE_MAKEFILE TRUE)


  ENABLE_TESTING()

  _SETUP_PROJECT_WARNINGS()
  _SETUP_PROJECT_HEADER()
  _SETUP_PROJECT_DIST()
  _SETUP_PROJECT_DEB()
  _SETUP_PROJECT_UNINSTALL()
  _SETUP_PROJECT_PKG_CONFIG()
  _SETUP_PROJECT_DOCUMENTATION()
ENDMACRO(SETUP_PROJECT)

# SETUP_PROJECT_FINALIZE
# ----------------------
#
# To be called at the end of the CMakeLists.txt to
# finalize the project setup.
#
MACRO(SETUP_PROJECT_FINALIZE)
  # Generate the pkg-config file.
  CONFIGURE_FILE(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/pkg-config.pc.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc"
    )

  # If the header list is set, install it.
  IF(DEFINED ${PROJECT_NAME}_HEADERS)
    INSTALL(FILES ${${PROJECT_NAME}_HEADERS}
      DESTINATION "include/${HEADER_DIR}"
      PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE
      )
  ENDIF(DEFINED ${PROJECT_NAME}_HEADERS)

  # Install data if needed
  _INSTALL_PROJECT_DATA()

ENDMACRO(SETUP_PROJECT_FINALIZE)


# CONFIG_FILES
# ---------------
#
# This wraps CONFIGURE_FILES to provide a cleaner, shorter syntax.
#
FUNCTION(CONFIG_FILES)
  FOREACH(I RANGE 0 ${ARGC})
    SET(FILE ${ARGV${I}})
    IF(FILE)
      CONFIGURE_FILE(
	${CMAKE_CURRENT_SOURCE_DIR}/${FILE}.in
	${CMAKE_CURRENT_BINARY_DIR}/${FILE}
	@ONLY
	)
    ENDIF(FILE)
ENDFOREACH(I RANGE 0 ${ARGC})
ENDFUNCTION(CONFIG_FILES)

# CONFIG_FILES_CMAKE
# ------------------
#
# Same as CONFIG_FILES but with CMake-style template files.
#
# Please, prefer the use of CONFIG_FILES to this function as
# it is safer.
#
FUNCTION(CONFIG_FILES_CMAKE)
  FOREACH(I RANGE 0 ${ARGC})
    SET(FILE ${ARGV${I}})
    IF(FILE)
      CONFIGURE_FILE(
	${CMAKE_CURRENT_SOURCE_DIR}/${FILE}.cmake
	${CMAKE_CURRENT_BINARY_DIR}/${FILE}
	)
    ENDIF(FILE)
ENDFOREACH(I RANGE 0 ${ARGC})
ENDFUNCTION(CONFIG_FILES_CMAKE)
