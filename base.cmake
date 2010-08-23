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
#
# Please note that functions starting with an underscore are internal
# functions and should not be used directly.

 # ---- #
 # TODO #
 # ---- #

# Add Debian support.
# Add check target which compiles test (instead of relying
#  on a configure-time option which is unpractical).




INCLUDE(CPack)

FIND_PACKAGE(Doxygen)
FIND_PACKAGE(PkgConfig)


 # --------- #
 # Constants #
 # --------- #

# Variables requires by SETUP_PROJECT.
SET(REQUIRED_VARIABLES PROJECT_NAME PROJECT_VERSION)

# Additional pkg-config variables whose value will be imported
# during the dependency check.
SET(PKG_CONFIG_ADDITIONAL_VARIABLES docdir doxygendocdir)

# Shared library related constants
# (used for pkg-config file generation).
# FIXME: can't we get these information from CMake directly?
IF(WIN32)
  SET(INCDIR_KW "") # FIXME: put a value here.
  SET(LIBDIR_KW "/LIBPATH:")
  SET(LIBINCL_KW "")
  SET(LIB_EXT ".lib")
ELSEIF(UNIX)
  SET(INCDIR_KW "-I")
  SET(LIBDIR_KW "-L")
  SET(LIBINCL_KW "-l")
  SET(LIB_EXT "")
ENDIF(WIN32)


 # --------------------- #
 # Project configuration #
 # --------------------- #

# _ADD_TO_COMMA_LIST LIST VALUE
# -------------
#
# Add a value to a comma-separated list.
#
# LIST	: the comma-separated list.
# VALUE : the value to be appended.
#
FUNCTION(_ADD_TO_COMMA_LIST LIST VALUE)
  IF(${LIST} STREQUAL "")
    SET(LIST ${VALUE})
  ELSE(${LIST} STREQUAL "")
    SET(LIST "${LIST}, ${VALUE}")
  ENDIF(${LIST} STREQUAL "")
ENDFUNCTION(_ADD_TO_COMMA_LIST LIST VALUE)


# _SETUP_PROJECT_CPACK
# --------------------
#
# Configure CPack as much as possible.
#
FUNCTION(_SETUP_PROJECT_CPACK)
  # CPack related variables definition.

  ## For tarball generation
  SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PROJECT_NAME})
  SET(CPACK_PACKAGE_VENDOR "JRL, CNRS/AIST")
  SET(CPACK_PACKAGE_DESCRIPTION_FILE
    ${CMAKE_CURRENT_SOURCE_DIR}/README)
  SET(
    CPACK_SOURCE_PACKAGE_FILE_NAME
    "${PROJECT_NAME}-${PROJECT_VERSION}"
    CACHE INTERNAL "tarball basename"
    )
  SET(CPACK_SOURCE_GENERATOR TGZ)

  ## For Debian
  # FIXME: to be done.
ENDFUNCTION(_SETUP_PROJECT_CPACK)


# _SETUP_PROJECT_PKG_CONFIG
# -------------------------
#
# Prepare pkg-config pc file generation step.
#
FUNCTION(_SETUP_PROJECT_PKG_CONFIG)
  # Pkg-config related commands.
  SET(PKG_CONFIG_PREFIX ${CMAKE_INSTALL_PREFIX})
  SET(PKG_CONFIG_EXEC_PREFIX ${PKG_CONFIG_PREFIX})
  SET(PKG_CONFIG_LIBDIR ${PKG_CONFIG_EXEC_PREFIX}/lib)
  SET(PKG_CONFIG_INCLUDEDIR ${PKG_CONFIG_PREFIX}/include)
  SET(PKG_CONFIG_DATAROOTDIR ${PKG_CONFIG_PREFIX}/share)
  SET(PKG_CONFIG_DOCDIR ${PKG_CONFIG_DATAROOTDIR}/doc/${PROJECT_NAME}
   )
  SET(PKG_CONFIG_DOXYGENDOCDIR ${PKG_CONFIG_DOCDIR}/doxygen-html)

  SET(PKG_CONFIG_PROJECT_NAME ${PROJECT_NAME})
  SET(PKG_CONFIG_DESCRIPTION)
  SET(PKG_CONFIG_URL)
  SET(PKG_CONFIG_VERSION ${PROJECT_VERSION})
  SET(PKG_CONFIG_REQUIRES)
  SET(PKG_CONFIG_CONFLICTS)
  SET(PKG_CONFIG_LIBS)
  SET(PKG_CONFIG_LIBS_PRIVATE)
  SET(PKG_CONFIG_LIBS_CFLAGS)

  SET(PKG_CONFIG_EXTRA)

  # Where to install the pkg-config file?
  SET(PKG_CONFIG_DIR ${PKG_CONFIG_LIBDIR}/pkgconfig)
  MESSAGE(STATUS ${PKG_CONFIG_DIR})

  # Generate the file.
  CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/pkg-config.pc.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc
    )

  # Install it.
  INSTALL(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc
    DESTINATION ${PKG_CONFIG_DIR}
    PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE)
ENDFUNCTION(_SETUP_PROJECT_PKG_CONFIG)


# _SETUP_PROJECT_UNINSTALL
# ------------------------
#
# Add custom rule to uninstall the package.
#
FUNCTION(_SETUP_PROJECT_UNINSTALL)
  # FIXME: it is utterly stupid to rely on the install manifest.
  # Can't we just remember what we install ?!
  CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/cmake/cmake_uninstall.cmake
    IMMEDIATE
    )

  ADD_CUSTOM_TARGET(
    uninstall
    "${CMAKE_COMMAND}" -P
    "${CMAKE_CURRENT_BINARY_DIR}/cmake/cmake_uninstall.cmake"
    )
ENDFUNCTION(_SETUP_PROJECT_UNINSTALL)


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
FUNCTION(SETUP_PROJECT)
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
  SET(CMAKE_VERBOSE_MAKEFILE true)


  _SETUP_PROJECT_CPACK()
  _SETUP_PROJECT_UNINSTALL()
  _SETUP_PROJECT_PKG_CONFIG()
ENDFUNCTION(SETUP_PROJECT)


# ADD_REQUIRED_DEPENDENCY(PREFIX PKGCONFIG_STRING)
# ------------------------------------------------
#
# Check for a dependency using pkg-config. Fail if the package cannot
# be found.
#
# PREFIX		: prefix used to generate CMake variables.
# LIBRARY_NAME		: name of the pkg-config library to check.
#			  Typically, this string looks like ``my-package''.
# PKG_CONFIG_STRING	: string passed to pkg-config to check the version.
#			  Typically, this string looks like: ``my-package >= 0.5''
#
FUNCTION(ADD_REQUIRED_DEPENDENCY PREFIX LIBRARY_NAME PKG_CONFIG_STRING)
  # Search for the package.
  PKG_CHECK_MODULES(${PREFIX} REQUIRED ${PKG_CONFIG_STRING})

  # Get the values of additional variables.
  FOREACH(VARIABLE ${REQUIRED_VARIABLES})
    # Upper-case version of the variable for CMake variable generation.
    STRING(TOUPPER ${VARIABLE} ${VARIABLE}_UC)
    EXEC_PROGRAM(
      ${PKG_CONFIG_EXECUTABLE} ARGS  --variable=${VARIABLE} ${LIBRARY_NAME}
      OUTPUT_VARIABLE ${PREFIX}_${VARIABLE_UC})
  ENDFOREACH(VARIABLE)


  # Add the package to the dependency list.
  _ADD_TO_COMMA_LIST(${PKG_CONFIG_REQUIRES}, ${PKG_CONFIG_STRING})

  # Add to the library list.
  _ADD_TO_COMMA_LIST(${PKG_CONFIG_LIBS}, ${${PREFIX}_LDFLAGS})

  # Add to the include list.
  _ADD_TO_COMMA_LIST(${PKG_CONFIG_INCLUDE}, ${${PREFIX}_CFLAGS})
ENDFUNCTION(ADD_REQUIRED_DEPENDENCY)
