#.rst:
# C++ Headers
# -----------
#
# .. command:: _SETUP_PROJECT_HEADER
#
# This setup CMake to handle headers properly.
#
# 1. The `include` directory in the build and source trees is added to the
#   include search path (see INCLUDE_DIRECTORIES). As always, the build
#   directory has the priority over the source directory in case of conflict.
#
# However you *should not* have conflicting names for files which are both in
# the build and source trees. Conflicting names are filenames which differ only
# by a prefix:
#
# include/a.h vs _build/include/a.h src/a.h     vs src/foo/a.h
#
# ...this files makes a project very fragile as the -I ordering will have a lot
# of importance and may break easily when using tools which may reorder the
# pre-processor flags such as pkg-config.
#
# 1. The headers are installed in the prefix in a way which preserves the
#   directory structure.
#
# The directory name for header follows the rule: each non alpha-numeric
# character is replaced by a slash (`/`). In practice, it means that hpp-util
# will put its header in: ${CMAKE_INSTALL_PREFIX}/include/hpp/util
#
# This rule has been decided to homogenize headers location, however some
# packages do not follow this rule (dg-middleware for instance).
#
# In that case, CUSTOM_HEADER_DIR can be set to override this policy.
#
# Reminder: breaking the JRL/LAAS policies shoud be done after discussing the
# issue. You should at least open a ticket or send an e-mail to notify this
# behavior.
#

# Copyright (C) 2008-2024 LAAS-CNRS, JRL AIST-CNRS, INRIA.
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

# .rst: .. ifmode:: user
#
# .. variable:: ${PROJECT_NAME}_HEADERS
#
# List of C++ header filenames. They will be installed automatically using
# :command:`HEADER_INSTALL`
#

macro(_SETUP_PROJECT_HEADER)
  # Install project headers.
  if(DEFINED PROJECT_CUSTOM_HEADER_DIR)
    set(HEADER_DIR "${PROJECT_CUSTOM_HEADER_DIR}")
  elseif(DEFINED CUSTOM_HEADER_DIR)
    set(HEADER_DIR "${CUSTOM_HEADER_DIR}")
  else()
    string(REGEX REPLACE "[^a-zA-Z0-9]" "/" HEADER_DIR "${PROJECT_NAME}")
  endif()

  if(NOT DEFINED PROJECT_CUSTOM_HEADER_EXTENSION)
    set(PROJECT_CUSTOM_HEADER_EXTENSION "hh")
  endif(NOT DEFINED PROJECT_CUSTOM_HEADER_EXTENSION)

  if(NOT DEFINED PROJECT_GENERATED_HEADERS_SKIP_CONFIG)
    set(PROJECT_GENERATED_HEADERS_SKIP_CONFIG OFF)
  endif()

  if(NOT DEFINED PROJECT_GENERATED_HEADERS_SKIP_DEPRECATED)
    set(PROJECT_GENERATED_HEADERS_SKIP_DEPRECATED OFF)
  endif()

  if(NOT DEFINED PROJECT_GENERATED_HEADERS_SKIP_WARNING)
    set(PROJECT_GENERATED_HEADERS_SKIP_WARNING OFF)
  endif()

  string(TOLOWER "${HEADER_DIR}" "HEADER_DIR")

  string(REGEX REPLACE "[^a-zA-Z0-9]" "_" PACKAGE_CPPNAME "${PROJECT_NAME}")
  string(TOLOWER "${PACKAGE_CPPNAME}" "PACKAGE_CPPNAME_LOWER")
  string(TOUPPER "${PACKAGE_CPPNAME}" "PACKAGE_CPPNAME")

  if(NOT PROJECT_GENERATED_HEADERS_SKIP_CONFIG)
    # Generate config.hh header.
    GENERATE_CONFIGURATION_HEADER(
      ${HEADER_DIR}
      config.${PROJECT_CUSTOM_HEADER_EXTENSION}
      ${PACKAGE_CPPNAME}
      ${PACKAGE_CPPNAME_LOWER}_EXPORTS
    )
  endif()

  if(NOT PROJECT_GENERATED_HEADERS_SKIP_DEPRECATED)
    # Generate deprecated.hh header.
    configure_file(
      ${PROJECT_JRL_CMAKE_MODULE_DIR}/deprecated.hh.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/include/${HEADER_DIR}/deprecated.${PROJECT_CUSTOM_HEADER_EXTENSION}
      @ONLY
    )

    if(INSTALL_GENERATED_HEADERS)
      install(
        FILES
          ${CMAKE_CURRENT_BINARY_DIR}/include/${HEADER_DIR}/deprecated.${PROJECT_CUSTOM_HEADER_EXTENSION}
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${HEADER_DIR}
        PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE
      )
    endif(INSTALL_GENERATED_HEADERS)
  endif()

  if(NOT PROJECT_GENERATED_HEADERS_SKIP_WARNING)
    # Generate warning.hh header.
    configure_file(
      ${PROJECT_JRL_CMAKE_MODULE_DIR}/warning.hh.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/include/${HEADER_DIR}/warning.${PROJECT_CUSTOM_HEADER_EXTENSION}
      @ONLY
    )

    if(INSTALL_GENERATED_HEADERS)
      install(
        FILES
          ${CMAKE_CURRENT_BINARY_DIR}/include/${HEADER_DIR}/warning.${PROJECT_CUSTOM_HEADER_EXTENSION}
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${HEADER_DIR}
        PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE
      )
    endif(INSTALL_GENERATED_HEADERS)
  endif()

  # Generate config.h header. This header, unlike the previous one is *not*
  # installed and is generated in the top-level directory of the build tree.
  # Therefore it must not be included by any distributed header.
  configure_file(
    ${PROJECT_JRL_CMAKE_MODULE_DIR}/config.h.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/config.h
  )

  # Default include directories: - top-level build directory (for generated
  # non-distributed headers). - include directory in the build tree (for
  # generated, distributed headers). - include directory in the source tree
  # (non-generated, distributed headers).
  include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}/include
    ${PROJECT_SOURCE_DIR}/include
  )
endmacro(_SETUP_PROJECT_HEADER)

# GENERATE_CONFIGURATION_HEADER
# -----------------------------
#
# This macro generates a configuration header. Macro parameters may be used to
# customize it.
#
# * HEADER_DIR    : where to generate the header
# * FILENAME      : how the file should be named
# * LIBRARY_NAME  : CPP symbol prefix, should match the compiled library name
# * EXPORT_SYMBOL : controls the switch between symbol import/export
function(
  GENERATE_CONFIGURATION_HEADER
  HEADER_DIR
  FILENAME
  LIBRARY_NAME
  EXPORT_SYMBOL
)
  GENERATE_CONFIGURATION_HEADER_V2(
    INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/include
    HEADER_DIR ${HEADER_DIR}
    FILENAME ${FILENAME}
    LIBRARY_NAME ${LIBRARY_NAME}
    EXPORT_SYMBOL ${EXPORT_SYMBOL}
  )
endfunction(GENERATE_CONFIGURATION_HEADER)

# ~~~
# .rst: .. command:: GENERATE_CONFIGURATION_HEADER_V2 (
#   INCLUDE_DIR <include_dir>
#   HEADER_DIR <header_dir>
#   FILENAME <filename>
#   LIBRARY_NAME <library_name>
#   EXPORT_SYBMOL <export_symbol>)
# ~~~
#
# This function generates a configuration header at
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
# :param LIBRARY_NAME: CPP symbol prefix, should match the compiled library
# name.
#
# :param EXPORT_SYMBOL: Controls the switch between symbol import/export.
function(GENERATE_CONFIGURATION_HEADER_V2)
  set(options)
  set(
    oneValueArgs
    INCLUDE_DIR
    HEADER_DIR
    FILENAME
    LIBRARY_NAME
    EXPORT_SYMBOL
  )
  set(multiValueArgs)
  cmake_parse_arguments(
    ARGS
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  if(${PROJECT_VERSION_MAJOR} MATCHES UNKNOWN)
    set(PROJECT_VERSION_MAJOR_CONFIG ${ARGS_LIBRARY_NAME}_VERSION_UNKNOWN_TAG)
  else()
    set(PROJECT_VERSION_MAJOR_CONFIG ${PROJECT_VERSION_MAJOR})
  endif()

  if(${PROJECT_VERSION_MINOR} MATCHES UNKNOWN)
    set(PROJECT_VERSION_MINOR_CONFIG ${ARGS_LIBRARY_NAME}_VERSION_UNKNOWN_TAG)
  else()
    set(PROJECT_VERSION_MINOR_CONFIG ${PROJECT_VERSION_MINOR})
  endif()

  if(${PROJECT_VERSION_PATCH} MATCHES UNKNOWN)
    set(PROJECT_VERSION_PATCH_CONFIG ${ARGS_LIBRARY_NAME}_VERSION_UNKNOWN_TAG)
  else()
    set(PROJECT_VERSION_PATCH_CONFIG ${PROJECT_VERSION_PATCH})
  endif()

  # Set variables for configure_file command
  set(EXPORT_SYMBOL ${ARGS_EXPORT_SYMBOL})
  set(LIBRARY_NAME ${ARGS_LIBRARY_NAME})

  # Generate the header.
  configure_file(
    ${PROJECT_JRL_CMAKE_MODULE_DIR}/config.hh.cmake
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
endfunction(GENERATE_CONFIGURATION_HEADER_V2)

# _SETUP_PROJECT_HEADER_FINALIZE
# ------------------------------
#
# Post-processing of the header management step. Install public headers if
# required.
#
macro(_SETUP_PROJECT_HEADER_FINALIZE)
  # If the header list is set, install it.
  if(DEFINED ${PROJECT_NAME}_HEADERS AND NOT BUILD_STANDALONE_PYTHON_INTERFACE)
    HEADER_INSTALL(${${PROJECT_NAME}_HEADERS})
  endif()
endmacro(_SETUP_PROJECT_HEADER_FINALIZE)

# .rst: .. ifmode:: internal
#
# ~~~
# .. command:: HEADER_INSTALL (COMPONENT <component> <files>...)
# ~~~
#
# Install a list of headers.
#
# :param component: Component to forward to install command.
#
# :param files: Files to install.
macro(HEADER_INSTALL)
  set(options)
  set(oneValueArgs COMPONENT)
  set(multiValueArgs)
  cmake_parse_arguments(
    ARGS
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  if(ARGS_COMPONENT)
    set(_COMPONENT_NAME ${ARGS_COMPONENT})
  else()
    set(_COMPONENT_NAME ${CMAKE_INSTALL_DEFAULT_COMPONENT_NAME})
  endif()

  set(FILES ${ARGS_UNPARSED_ARGUMENTS})

  foreach(FILE ${FILES})
    get_filename_component(DIR "${FILE}" PATH)
    string(REPLACE "${PROJECT_BINARY_DIR}" "" DIR "${DIR}")
    string(REPLACE "${PROJECT_SOURCE_DIR}" "" DIR "${DIR}")
    string(REPLACE "include" "" DIR "${DIR}")
    # workaround CMP0177
    cmake_path(SET INSTALL_PATH NORMALIZE "${CMAKE_INSTALL_INCLUDEDIR}/${DIR}")
    install(
      FILES ${FILE}
      DESTINATION ${INSTALL_PATH}
      PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE
      COMPONENT ${_COMPONENT_NAME}
    )
  endforeach()
endmacro()
