# Copyright (C) 2024 INRIA.
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with this program.  If not, see <https://www.gnu.org/licenses/>.

# .rst:
# ~~~
# .. command:: GENERATE_TRACY_HEADER (
#   INCLUDE_DIR <include_dir>
#   HEADER_DIR <header_dir>
#   FILENAME <filename>
#   LIBRARY_NAME <library_name>
#   TRACY_ENABLE <tracy_enable>)
# ~~~
#
# This function generates a tracy wrapper header at
# ``<include_dir>/<header_dir>/<filename>``.
#
# If INSTALL_GENERATED_HEADERS is ON, the configuration header will be installed
# in
# ``${CMAKE_INSTALL_INCLUDEDIR}/<header_dir>``.
#
# :param INCLUDE_DIR: Include root directory (absolute).
#
# :param HEADER_DIR: Include sub directory.
#
# :param FILENAME: Configuration header name.
#
# :param LIBRARY_NAME: Define prefix, should match the compiled library name.
#
# :param TRACY_ENABLE: Controls if tracy macro are empty or call tracy.
function(_GENERATE_TRACY_HEADER)
  set(options)
  set(
    oneValueArgs
    INCLUDE_DIR
    HEADER_DIR
    FILENAME
    LIBRARY_NAME
    TRACY_ENABLE
  )
  set(multiValueArgs)
  cmake_parse_arguments(
    ARGS
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  # Set variables for configure_file command
  set(LIBRARY_NAME ${ARGS_LIBRARY_NAME})
  # Activate/Deactivate Tracy macro definition
  if(ARGS_TRACY_ENABLE)
    set(DEFINE_TRACY_ENABLE "#define ${LIBRARY_NAME}_TRACY_ENABLE")
  else()
    set(DEFINE_TRACY_ENABLE)
  endif()

  configure_file(
    ${PROJECT_JRL_CMAKE_MODULE_DIR}/tracy.hh.cmake
    ${ARGS_INCLUDE_DIR}/${ARGS_HEADER_DIR}/${ARGS_FILENAME}
    @ONLY
  )

  # Install it if requested.
  if(INSTALL_GENERATED_HEADERS)
    install(
      FILES ${ARGS_INCLUDE_DIR}/${ARGS_HEADER_DIR}/${ARGS_FILENAME}
      DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${ARGS_HEADER_DIR}
      PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE
    )
  endif()
endfunction()

# .rst:
#
# Read project parameters to generate tracy header
function(_SETUP_TRACY_HEADER)
  # Install project headers.
  if(DEFINED PROJECT_CUSTOM_HEADER_DIR)
    set(HEADER_DIR "${PROJECT_CUSTOM_HEADER_DIR}")
  elseif(DEFINED CUSTOM_HEADER_DIR)
    set(HEADER_DIR "${CUSTOM_HEADER_DIR}")
  else()
    string(REGEX REPLACE "[^a-zA-Z0-9]" "/" HEADER_DIR "${PROJECT_NAME}")
  endif()
  string(TOLOWER "${HEADER_DIR}" "HEADER_DIR")

  if(NOT DEFINED PROJECT_CUSTOM_HEADER_EXTENSION)
    set(HEADER_EXTENSION "hh")
  else()
    set(HEADER_EXTENSION ${PROJECT_CUSTOM_HEADER_EXTENSION})
  endif()

  string(REGEX REPLACE "[^a-zA-Z0-9]" "_" PACKAGE_CPPNAME "${PROJECT_NAME}")
  string(TOUPPER "${PACKAGE_CPPNAME}" PACKAGE_CPPNAME)

  _GENERATE_TRACY_HEADER(
    INCLUDE_DIR ${PROJECT_BINARY_DIR}/include
    HEADER_DIR ${HEADER_DIR}
    FILENAME tracy.${HEADER_EXTENSION}
    LIBRARY_NAME ${PACKAGE_CPPNAME}
    TRACY_ENABLE ${${PACKAGE_CPPNAME}_TRACY_ENABLE}
  )
endfunction()

option(${PACKAGE_CPPNAME}_TRACY_ENABLE "Enable Tracy." OFF)
_SETUP_TRACY_HEADER()
