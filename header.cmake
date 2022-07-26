# Copyright (C) 2008-2019 LAAS-CNRS, JRL AIST-CNRS, INRIA.
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

# .rst: .. ifmode:: internal
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
macro(_SETUP_PROJECT_HEADER)
  # Install project headers.
  if(DEFINED CUSTOM_HEADER_DIR)
    set(HEADER_DIR "${CUSTOM_HEADER_DIR}")
  else(DEFINED CUSTOM_HEADER_DIR)
    string(REGEX REPLACE "[^a-zA-Z0-9]" "/" HEADER_DIR "${PROJECT_NAME}")
  endif(DEFINED CUSTOM_HEADER_DIR)

  if(NOT DEFINED PROJECT_CUSTOM_HEADER_EXTENSION)
    set(PROJECT_CUSTOM_HEADER_EXTENSION "hh")
  endif(NOT DEFINED PROJECT_CUSTOM_HEADER_EXTENSION)

  string(TOLOWER "${HEADER_DIR}" "HEADER_DIR")

  # Generate config.hh header.
  string(REGEX REPLACE "[^a-zA-Z0-9]" "_" PACKAGE_CPPNAME "${PROJECT_NAME}")
  string(TOLOWER "${PACKAGE_CPPNAME}" "PACKAGE_CPPNAME_LOWER")
  string(TOUPPER "${PACKAGE_CPPNAME}" "PACKAGE_CPPNAME")

  generate_configuration_header(
    ${HEADER_DIR} config.${PROJECT_CUSTOM_HEADER_EXTENSION} ${PACKAGE_CPPNAME}
    ${PACKAGE_CPPNAME_LOWER}_EXPORTS)

  # Generate deprecated.hh header.
  configure_file(
    ${PROJECT_JRL_CMAKE_MODULE_DIR}/deprecated.hh.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/include/${HEADER_DIR}/deprecated.${PROJECT_CUSTOM_HEADER_EXTENSION}
    @ONLY)

  if(INSTALL_GENERATED_HEADERS)
    install(
      FILES
        ${CMAKE_CURRENT_BINARY_DIR}/include/${HEADER_DIR}/deprecated.${PROJECT_CUSTOM_HEADER_EXTENSION}
      DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${HEADER_DIR}
      PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE)
  endif(INSTALL_GENERATED_HEADERS)

  # Generate warning.hh header.
  configure_file(
    ${PROJECT_JRL_CMAKE_MODULE_DIR}/warning.hh.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/include/${HEADER_DIR}/warning.${PROJECT_CUSTOM_HEADER_EXTENSION}
    @ONLY)

  if(INSTALL_GENERATED_HEADERS)
    install(
      FILES
        ${CMAKE_CURRENT_BINARY_DIR}/include/${HEADER_DIR}/warning.${PROJECT_CUSTOM_HEADER_EXTENSION}
      DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${HEADER_DIR}
      PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE)
  endif(INSTALL_GENERATED_HEADERS)

  # Generate config.h header. This header, unlike the previous one is *not*
  # installed and is generated in the top-level directory of the build tree.
  # Therefore it must not be included by any distributed header.
  configure_file(${PROJECT_JRL_CMAKE_MODULE_DIR}/config.h.cmake
                 ${CMAKE_CURRENT_BINARY_DIR}/config.h)

  # Default include directories: - top-level build directory (for generated
  # non-distributed headers). - include directory in the build tree (for
  # generated, distributed headers). - include directory in the source tree
  # (non-generated, distributed headers).
  include_directories(
    ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_BINARY_DIR}/include
    ${PROJECT_SOURCE_DIR}/include)
endmacro(_SETUP_PROJECT_HEADER)

# GENERATE_CONFIGURATION_HEADER
# -----------------------------
#
# This macro generates a configuration header. Macro parameters may be used to
# customize it.
#
# HEADER_DIR    : where to generate the header FILENAME      : how should the
# file named LIBRARY_NAME  : CPP symbol prefix, should match the compiled
# library name EXPORT_SYMBOl : what symbol controls the switch between symbol
# import/export
function(GENERATE_CONFIGURATION_HEADER HEADER_DIR FILENAME LIBRARY_NAME
         EXPORT_SYMBOL)

  if(${PROJECT_VERSION_MAJOR} MATCHES UNKNOWN)
    set(PROJECT_VERSION_MAJOR_CONFIG ${LIBRARY_NAME}_VERSION_UNKNOWN_TAG)
  else()
    set(PROJECT_VERSION_MAJOR_CONFIG ${PROJECT_VERSION_MAJOR})
  endif()

  if(${PROJECT_VERSION_MINOR} MATCHES UNKNOWN)
    set(PROJECT_VERSION_MINOR_CONFIG ${LIBRARY_NAME}_VERSION_UNKNOWN_TAG)
  else()
    set(PROJECT_VERSION_MINOR_CONFIG ${PROJECT_VERSION_MINOR})
  endif()

  if(${PROJECT_VERSION_PATCH} MATCHES UNKNOWN)
    set(PROJECT_VERSION_PATCH_CONFIG ${LIBRARY_NAME}_VERSION_UNKNOWN_TAG)
  else()
    set(PROJECT_VERSION_PATCH_CONFIG ${PROJECT_VERSION_PATCH})
  endif()

  # Generate the header.
  configure_file(
    ${PROJECT_JRL_CMAKE_MODULE_DIR}/config.hh.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/include/${HEADER_DIR}/${FILENAME} @ONLY)

  # Install it if requested.
  if(INSTALL_GENERATED_HEADERS)
    install(
      FILES ${CMAKE_CURRENT_BINARY_DIR}/include/${HEADER_DIR}/${FILENAME}
      DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${HEADER_DIR}
      PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE)
  endif(INSTALL_GENERATED_HEADERS)
endfunction(GENERATE_CONFIGURATION_HEADER)

# _SETUP_PROJECT_HEADER_FINALIZE
# ------------------------------
#
# Post-processing of the header management step. Install public headers if
# required.
#
macro(_SETUP_PROJECT_HEADER_FINALIZE)
  # If the header list is set, install it.
  if(DEFINED ${PROJECT_NAME}_HEADERS)
    foreach(FILE ${${PROJECT_NAME}_HEADERS})
      header_install(${FILE})
    endforeach(FILE)
  endif(DEFINED ${PROJECT_NAME}_HEADERS)
endmacro(_SETUP_PROJECT_HEADER_FINALIZE)

# .rst: .. ifmode:: internal
#
# .. command:: HEADER_INSTALL (FILES)
#
# Install a list of headers.
#
macro(HEADER_INSTALL FILES)
  foreach(FILE ${FILES})
    get_filename_component(DIR "${FILE}" PATH)
    string(REGEX REPLACE "${CMAKE_BINARY_DIR}" "" DIR "${DIR}")
    string(REGEX REPLACE "${PROJECT_SOURCE_DIR}" "" DIR "${DIR}")
    string(REGEX REPLACE "include(/|$)" "" DIR "${DIR}")
    install(
      FILES ${FILE}
      DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${DIR}"
      PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE)
  endforeach()
endmacro()
