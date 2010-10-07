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

MACRO(_SETUP_PROJECT_HEADER)
  # Install project headers.
  STRING(REGEX REPLACE "[^a-zA-Z0-9]" "/" HEADER_DIR "${PROJECT_NAME}")
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
