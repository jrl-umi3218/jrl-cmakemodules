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

# _SETUP_PROJECT_HEADER
# ---------------------
#
# This setup CMake to handle headers properly.
#
# 1. The `include` directory in the build and source trees is added
#    to the include search path (see INCLUDE_DIRECTORIES).
#    As always, the build directory has the priority over the source
#    directory in case of conflict.
#
#    However you *should not* have conflicting names
#    for files which are both in the build and source trees.
#    Conflicting names are filenames which differ only by a prefix:
#
#    include/a.h vs _build/include/a.h
#    src/a.h     vs src/foo/a.h
#
#    ...this files makes a project very fragile as the -I ordering
#    will have a lot of importance and may break easily when using
#    tools which may reorder the pre-processor flags such as pkg-config.
#
#
# 2. The headers are installed in the prefix
#    in a way which preserves the directory structure.
#
#    The directory name for header follows the rule:
#    each non alpha-numeric character is replaced by a slash (`/`).
#    In practice, it means that hpp-util will put its header in:
#    ${CMAKE_INSTALL_PREFIX}/include/hpp/util
#
#    This rule has been decided to homogenize headers location, however
#    some packages do not follow this rule (dg-middleware for instance).
#
#    In that case, CUSTOM_HEADER_DIR can be set to override this policy.
#
#    Reminder: breaking the JRL/LAAS policies shoud be done after discussing
#              the issue. You should at least open a ticket or send an e-mail
#              to notify this behavior.
#
MACRO(_SETUP_PROJECT_HEADER)
  # Install project headers.
  IF(DEFINED CUSTOM_HEADER_DIR)
    SET(HEADER_DIR "${CUSTOM_HEADER_DIR}")
  ELSE(DEFINED CUSTOM_HEADER_DIR)
    STRING(REGEX REPLACE "[^a-zA-Z0-9]" "/" HEADER_DIR "${PROJECT_NAME}")
  ENDIF(DEFINED CUSTOM_HEADER_DIR)

  STRING(TOLOWER "${HEADER_DIR}" "HEADER_DIR")
  INSTALL(FILES ${${PROJECT_NAME}_HEADERS}
    DESTINATION "include/${HEADER_DIR}"
    PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE
    )

  # Generate config.hh header.
  STRING(REGEX REPLACE "[^a-zA-Z0-9]" "_" PACKAGE_CPPNAME "${PROJECT_NAME}")
  STRING(TOUPPER "${PACKAGE_CPPNAME}" "PACKAGE_CPPNAME")

  CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/config.hh.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/include/${HEADER_DIR}/config.hh
    )
  CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/config.h.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/config.h
    )
  INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/include/${HEADER_DIR}/config.hh
    DESTINATION include/${HEADER_DIR}
    PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE
    )

  # Default include directories.
  INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    )
ENDMACRO(_SETUP_PROJECT_HEADER)
