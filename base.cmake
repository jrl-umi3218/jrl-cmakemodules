# Copyright (C) 2008-2019 LAAS-CNRS, JRL AIST-CNRS, INRIA.
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


#.rst:
# .. ifmode:: user
#
#   This section lists the variables and macros that must be defined and
#   invoked in the right place to enable the features of this cmake modules.
#
#   For a minimal working example see :ref:`minimal-working-example`.
#
#   Required variables
#   ------------------
#
#   .. variable:: PROJECT_NAME
#
#     Please keep respect our coding style and choose a name
#     which respects the following regexp: ``[a-z][a-z0-9-]*``
#     I.e. a lower-case letter then one or more lower-case
#     letter, number or hyphen ``-``.
#
#   .. variable:: PROJECT_URL
#
#     Project's website.
#
#   .. variable:: PROJECT_DESCRIPTION
#
#     One line summary of the package goal.
#
#   Optional variables
#   ------------------
#
#   .. variable:: PROJECT_VERSION
#
#     Project version (X.Y.Z where X, Y, Z are unsigned
#     integers). If not defined, it will automatically
#     be computed through `git describe`.
#     See :cmake:command:`VERSION_COMPUTE` for more information.
#
#   .. variable:: PROJECT_DEBUG_POSTFIX
#
#     If set, ``${PROJECT_DEBUG_POSTFIX}`` will be appended to the libraries
#     generated by the project (as the builtin `CMAKE_DEBUG_POSTFIX
#     <https://cmake.org/cmake/help/v3.0/variable/CMAKE_DEBUG_POSTFIX.html>`_)
#     but this will also trigger the generation of an appropriate debug
#     pkg-config file.
#
#   .. variable:: PROJECT_USE_KEYWORD_LINK_LIBRARIES
#
#     If set to true, the jrl-cmakemodules will use the PUBLIC keyword in
#     ``target_link_libraries``. Defaults to false.
#
#   .. variable: PROJECT_CUSTOM_HEADER_EXTENSION
#     Allows to define a custome extension for C/C++ header files (e.g. .h, .hh, .hpp).
#     The default value is set to .hh.
#
#   .. variable:: PROJECT_USE_CMAKE_EXPORT
#
#     This tells jrl-cmakemodules that you are using export functionalities so it will
#     hook the installation of your configuration files. Defaults to false
#
#   .. variable:: PROJECT_EXPORT_NO_TARGET
#
#     This tells jrl-cmakemodules that there is no targets in the project.
#     However the export functionalities are still provided to detect the
#     project properties. Not setting this variable when no target is present
#     will result in an error.
#
#   .. variable:: PROJECT_JRL_CMAKE_MODULE_DIR
#
#     This variable provides the full path pointing to the JRL cmake module.
#
#   Macros
#   ------
#

SET(PROJECT_JRL_CMAKE_MODULE_DIR ${CMAKE_CURRENT_LIST_DIR} CACHE INTERNAL "")

# Please note that functions starting with an underscore are internal
# functions and should not be used directly.

# Include base features.
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/logging.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/portability.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/compiler.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/debian.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/dist.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/distcheck.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/doxygen.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/header.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/uninstall.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/install-data.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/release.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/version.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/package-config.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/version-script.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/test.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/oscheck.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/cxx-standard.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/coverage.cmake)

 # --------- #
 # Constants #
 # --------- #

# Variables requires by SETUP_PROJECT.
SET(REQUIRED_VARIABLES PROJECT_NAME PROJECT_DESCRIPTION PROJECT_URL)

# Check that required variables are defined.
FOREACH(VARIABLE ${REQUIRED_VARIABLES})
  IF (NOT DEFINED ${VARIABLE})
    MESSAGE(AUTHOR_WARNING "Required variable ``${VARIABLE}'' has not been defined, perhaps you are including cmake/base.cmake too early")
    MESSAGE(AUTHOR_WARNING "Check out https://jrl-cmakemodules.readthedocs.io/en/master/pages/base.html#minimal-working-example for an example")
    MESSAGE(FATAL_ERROR "Required variable ``${VARIABLE}'' has not been defined.")
  ENDIF(NOT DEFINED ${VARIABLE})
ENDFOREACH(VARIABLE)

# If the project version number is not set, compute it automatically.
IF(NOT DEFINED PROJECT_VERSION)
  VERSION_COMPUTE()
ELSE()
  IF(NOT DEFINED PROJECT_VERSION_MAJOR AND
      NOT DEFINED PROJECT_VERSION_MINOR AND
      NOT DEFINED PROJECT_VERSION_PATCH)
    SPLIT_VERSION_NUMBER(${PROJECT_VERSION}
      PROJECT_VERSION_MAJOR
      PROJECT_VERSION_MINOR
      PROJECT_VERSION_PATCH)
  ENDIF()
ENDIF()
SET(SAVED_PROJECT_VERSION "${PROJECT_VERSION}")
SET(SAVED_PROJECT_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
SET(SAVED_PROJECT_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
SET(SAVED_PROJECT_VERSION_PATCH "${PROJECT_VERSION_PATCH}")

IF(PROJECT_VERSION MATCHES UNKNOWN)
  SET(PROJECT_VERSION_FULL "")
ELSE(PROJECT_VERSION MATCHES UNKNOWN)
  IF(PROJECT_VERSION_PATCH)
  SET(PROJECT_VERSION_FULL "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
  ELSE(PROJECT_VERSION_PATCH)
    SET(PROJECT_VERSION_FULL "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")
  ENDIF(PROJECT_VERSION_PATCH)
ENDIF(PROJECT_VERSION MATCHES UNKNOWN)

# Set a script to run after project called
SET(CMAKE_PROJECT_${PROJECT_NAME}_INCLUDE "${CMAKE_CURRENT_LIST_DIR}/post-project.cmake")

# Set a hook to finalize the setup, CMake will set CMAKE_CURRENT_LIST_DIR to "" at the end
# Based off https://stackoverflow.com/questions/15760580/execute-command-or-macro-in-cmake-as-the-last-step-before-the-configure-step-f
VARIABLE_WATCH(CMAKE_CURRENT_LIST_DIR SETUP_PROJECT_FINALIZE_HOOK)
FUNCTION(SETUP_PROJECT_FINALIZE_HOOK VARIABLE ACCESS)
  IF("${${VARIABLE}}" STREQUAL "")
    SET(CMAKE_CURRENT_LIST_DIR ${PROJECT_JRL_CMAKE_MODULE_DIR})
    SETUP_PROJECT_FINALIZE()
    IF(PROJECT_USE_CMAKE_EXPORT)
      SETUP_PROJECT_PACKAGE_FINALIZE()
    ENDIF()
    SET(CMAKE_CURRENT_LIST_DIR "") # restore value
  ENDIF()
ENDFUNCTION()

 # --------------------- #
 # Project configuration #
 # --------------------- #

# _ADD_TO_LIST LIST VALUE
# -----------------------
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
    IF(NOT "${VALUE}" STREQUAL "")
      SET(${LIST} "${${LIST}}${SEPARATOR} ${VALUE}")
    ENDIF(NOT "${VALUE}" STREQUAL "")
  ENDIF("${${LIST}}" STREQUAL "")
ENDMACRO(_ADD_TO_LIST LIST VALUE)

# _ADD_TO_LIST_IF_NOT_PRESENT LIST VALUE
# -----------------------
#
# Add a value to a CMake standard list list.
#
# LIST		: the list.
# VALUE		: the value to be appended.
#
MACRO(_ADD_TO_LIST_IF_NOT_PRESENT LIST VALUE)
  IF(CMAKE_VERSION VERSION_GREATER "3.3.0")
    CMAKE_POLICY(PUSH)
    CMAKE_POLICY(SET CMP0057 NEW)
    # To be more robust, value should be stripped
    IF(NOT "${VALUE}" IN_LIST ${LIST})
      LIST(APPEND ${LIST} "${VALUE}")
    ENDIF()
    CMAKE_POLICY(POP)
  ELSE()
    LIST (FIND LIST "${VALUE}" _index)
    IF(${_index} EQUAL -1)
      LIST(APPEND LIST "${VALUE}")
    ENDIF()
  ENDIF()
ENDMACRO(_ADD_TO_LIST_IF_NOT_PRESENT LIST VALUE)

# _CONCATENATE_ARGUMENTS
# ----------------------
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

#.rst:
# .. ifmode:: internal
#
#   .. command:: SETUP_PROJECT
#
#     Initialize the project. Should be called first in the root
#     CMakeList.txt.
#
#     This function does not take any argument but check that some
#     variables are defined (see documentation at the beginning of this
#     file).
#
#     .. warning::
#
#       This function should not be called manually.
#       Instead, simply call project(\${PROJECT_NAME} CXX) after including cmake/base.cmake
#       You can also remove setup_project_finalize() call.
#
MACRO(SETUP_PROJECT)
  # Define project name.
  PROJECT(${PROJECT_NAME} CXX)
  IF(${CMAKE_VERSION} VERSION_GREATER 3.15)
    MESSAGE("Please update your CMakeLists: instead of setup_project() simply call project(\${PROJECT_NAME} CXX) after including cmake/base.cmake\nYou can also remove setup_project_finalize() call")
  ENDIF()
ENDMACRO(SETUP_PROJECT)

#.rst:
# .. ifmode:: internal
#
#   .. command:: SETUP_PROJECT_FINALIZE
#
#     Called automatically at the end of the CMakeLists.txt to
#     finalize the project setup.
#
MACRO(SETUP_PROJECT_FINALIZE)
  IF(INSTALL_PKG_CONFIG_FILE)
    _SETUP_PROJECT_PKG_CONFIG_FINALIZE()
  ENDIF(INSTALL_PKG_CONFIG_FILE)
  _SETUP_PROJECT_DOCUMENTATION_FINALIZE()
  _SETUP_PROJECT_HEADER_FINALIZE()
  _SETUP_COVERAGE_FINALIZE()
  _SETUP_DEBIAN()
  # Install data if needed
  _INSTALL_PROJECT_DATA()

  LOGGING_FINALIZE()
ENDMACRO(SETUP_PROJECT_FINALIZE)

#.rst:
# .. ifmode:: user
#
#   .. command:: COMPUTE_PROJECT_ARGS (OUTPUT_VARIABLE [LANGUAGES <languages>...])
#
#     Compute the arguments to be passed to command PROJECT.
#     For instance::
#
#       COMPUTE_PROJECT_ARGS(PROJECT_ARGS LANGUAGES CXX)
#       PROJECT(${PROJECT_NAME} ${PROJECT_ARGS})
#
#     :param OUTPUT_VARIABLE: the variable where to write the result
#     :param LANGUAGES: the project languages. It defaults to CXX.
#
MACRO(COMPUTE_PROJECT_ARGS _project_VARIABLE)
  CMAKE_PARSE_ARGUMENTS(_project "" "" "LANGUAGES" ${ARGN})
  IF(NOT DEFINED _project_LANGUAGES)
    SET(_project_LANGUAGES "CXX")
  ENDIF()

  IF(CMAKE_VERSION VERSION_GREATER "3.0.0")
    # CMake >= 3.0
    CMAKE_POLICY(SET CMP0048 NEW)
    SET(${_project_VARIABLE} VERSION ${PROJECT_VERSION_FULL} LANGUAGES ${_project_LANGUAGES})

    # Append description for CMake >= 3.9
    IF(CMAKE_VERSION VERSION_GREATER "3.9.0")
      SET(${_project_VARIABLE} ${${_project_VARIABLE}} DESCRIPTION ${PROJECT_DESCRIPTION})
    ENDIF(CMAKE_VERSION VERSION_GREATER "3.9.0")
  ELSE(CMAKE_VERSION VERSION_GREATER "3.0.0")

    # CMake < 3.0
    SET(${_project_VARIABLE} ${_project_LANGUAGES})
  ENDIF(CMAKE_VERSION VERSION_GREATER "3.0.0")
ENDMACRO(COMPUTE_PROJECT_ARGS)
