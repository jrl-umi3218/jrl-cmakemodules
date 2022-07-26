# Copyright (C) 2008-2014 LAAS-CNRS, JRL AIST-CNRS.
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

# Check the existence of the ros package using rospack. PKG_ROS is a string
# containing the name of the package and eventually the desired version of the
# package using pkg-config syntax. The following operators are handled: {>, >=,
# =, <, <=} example: ADD_ROSPACK_DEPENDENCY("pkg_name")
# ADD_ROSPACK_DEPENDENCY("pkg_name >= 0.1")
macro(ADD_ROSPACK_DEPENDENCY PKG_ROS)
  if(PKG STREQUAL "")
    message(FATAL_ERROR "ADD_ROS_DEPENDENCY invalid call.")
  endif()

  # check if a version is defined
  string(REGEX MATCH "[<>=]+" SIGN "${PKG_ROS}")
  if(NOT "${SIGN}" STREQUAL "")
    string(REGEX MATCH "[0-9.]+ *$" PKG_VERSION "${PKG_ROS}")
    # get the name of the package
    string(REGEX MATCH "[^<>= ]+" PKG ${PKG_ROS})
  else()
    # the name of the package is the full input
    set(PKG ${PKG_ROS})
  endif()

  # Transform package name into a valid variable prefix. 1. replace invalid
  # characters into underscores.
  string(REGEX REPLACE "[^a-zA-Z0-9]" "_" PREFIX "${PKG}")
  # 1. make it uppercase.
  string(TOUPPER "${PREFIX}" "PREFIX")

  set(${PREFIX}_FOUND 0)

  find_program(ROSPACK rospack)
  if(NOT ROSPACK)
    message(FATAL_ERROR "failed to find the rospack binary. Is ROS installed?")
  endif()

  message(STATUS "Looking for ${PKG} using rospack...")
  execute_process(
    COMMAND "${ROSPACK}" find "${PKG}"
    OUTPUT_VARIABLE "${PKG}_ROS_PREFIX"
    ERROR_QUIET)
  if(NOT ${PKG}_ROS_PREFIX)
    message(FATAL_ERROR "Failed to detect ${PKG}.")
  endif()

  # Get the version of the package
  find_program(ROSVERSION rosversion)
  if(NOT ROSVERSION)
    message(
      FATAL_ERROR "failed to find the rosversion binary. Is ROS installed?")
  endif()

  execute_process(
    COMMAND "${ROSVERSION}" "${PKG}"
    OUTPUT_VARIABLE ${PKG}_ROSVERSION_TMP
    ERROR_QUIET)
  string(REGEX REPLACE "\n" "" ${PKG}_ROSVERSION ${${PKG}_ROSVERSION_TMP})

  # check whether the version satisfies the constraint
  if(NOT "${SIGN}" STREQUAL "")
    set(RESULT FALSE)
    if(("${${PKG}_ROSVERSION}" VERSION_LESS "${PKG_VERSION}")
       AND ((${SIGN} STREQUAL "<=") OR (${SIGN} STREQUAL "<")))
      set(RESULT TRUE)
    endif()

    if(("${${PKG}_ROSVERSION}" VERSION_EQUAL "${PKG_VERSION}")
       AND ((${SIGN} STREQUAL ">=")
            OR (${SIGN} STREQUAL "=")
            OR (${SIGN} STREQUAL "<=")))
      set(RESULT TRUE)
    endif()

    if(("${${PKG}_ROSVERSION}" VERSION_GREATER "${PKG_VERSION}")
       AND (("${SIGN}" STREQUAL ">=") OR ("${SIGN}" STREQUAL ">")))
      set(RESULT TRUE)
    endif()

    if(NOT RESULT)
      message(
        FATAL_ERROR
          "The package ${PKG} does not have the correct version."
          " Found: ${${PKG}_ROSVERSION}, desired: ${SIGN} ${PKG_VERSION}")
    endif()
  endif(NOT "${SIGN}" STREQUAL "")

  # Declare that the package has been found
  message("${PKG} found, version ${${PKG}_ROSVERSION}")

  set(${PREFIX}_FOUND 1)
  execute_process(
    COMMAND "${ROSPACK}" export "--lang=cpp" "--attrib=cflags" "${PKG}"
    OUTPUT_VARIABLE "${PREFIX}_CFLAGS"
    ERROR_QUIET)
  execute_process(
    COMMAND "${ROSPACK}" export "--lang=cpp" "--attrib=lflags" "${PKG}"
    OUTPUT_VARIABLE "${PREFIX}_LIBS"
    ERROR_QUIET)
  string(REPLACE "\n" "" ${PREFIX}_CFLAGS "${${PREFIX}_CFLAGS}")
  string(REPLACE "\n" "" ${PREFIX}_LIBS "${${PREFIX}_LIBS}")
  string(REPLACE "\n" "" ${PKG}_ROS_PREFIX "${${PKG}_ROS_PREFIX}")

  # Add flags to package pkg-config file.
  pkg_config_append_cflags("${${PREFIX}_CFLAGS}")
  pkg_config_append_libs_raw("${${PREFIX}_LIBS}")
endmacro()

macro(ROSPACK_USE_DEPENDENCY TARGET PKG)
  if(PKG STREQUAL "")
    message(FATAL_ERROR "ROSPACK_USE_DEPENDENCY invalid call.")
  endif()

  # Transform package name into a valid variable prefix. 1. replace invalid
  # characters into underscores.
  string(REGEX REPLACE "[^a-zA-Z0-9]" "_" PREFIX "${PKG}")
  # 1. make it uppercase.
  string(TOUPPER "${PREFIX}" "PREFIX")

  # Make sure we do not override previous flags.
  get_target_property(CFLAGS "${TARGET}" COMPILE_FLAGS)
  get_target_property(LDFLAGS "${TARGET}" LINK_FLAGS)

  # If there were no previous flags, get rid of the XYFLAGS-NOTFOUND in the
  # variables.
  if(NOT CFLAGS)
    set(CFLAGS "")
  endif()
  if(NOT LDFLAGS)
    set(LDFLAGS "")
  endif()

  # Filter out end of line in new flags.
  string(REPLACE "\n" "" ${PREFIX}_CFLAGS "${${PREFIX}_CFLAGS}")
  string(REPLACE "\n" "" ${PREFIX}_LIBS "${${PREFIX}_LIBS}")

  # Append new flags.
  set(CFLAGS "${CFLAGS} ${${PREFIX}_CFLAGS}")
  set(LDFLAGS "${LDFLAGS} ${${PREFIX}_LIBS}")

  # Update the flags.
  set_target_properties("${TARGET}" PROPERTIES COMPILE_FLAGS "${CFLAGS}"
                                               LINK_FLAGS "${LDFLAGS}")

  # Correct the potential link issue due to the order of link flags. (appears
  # e.g. on ubuntu 12.04). Note that this issue is the same as the one in
  # pkg-config.cmake, method PKG_CONFIG_USE_LLINK_DEPENDENCY
  if(UNIX AND NOT APPLE)
    # convert the string in a list
    string(REPLACE " " ";" LDFLAGS_LIST "${LDFLAGS}")
    foreach(dep ${LDFLAGS_LIST})
      target_link_libraries(${TARGET} ${PUBLIC_KEYWORD} ${dep})
    endforeach(dep)
  endif(UNIX AND NOT APPLE)
endmacro()
