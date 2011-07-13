# Copyright (C) 2011 Olivier Stasse, JRL, CNRS/AIST.
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

# _SETUP_DEBIAN
# -------------------
#
# Prepare needed file for debian if the target is a shared library.
#
MACRO(_SETUP_DEBIAN)
  MESSAGE(STATUS "setup debian. Trying to get the type of ${PROJECT_NAME}")
  GET_TARGET_PROPERTY(${PROJECT_NAME}_IS_SHARED_LIBRARY ${PROJECT_NAME} TYPE)
  MESSAGE(STATUS "${PROJECT_NAME}_IS_SHARED_LIBRARY:" ${${PROJECT_NAME}_IS_SHARED_LIBRARY})

  IF(UNIX)
    IF (IS_DIRECTORY ${CMAKE_SOURCE_DIR}/debian)
      IF(${PROJECT_NAME}_IS_SHARED_LIBRARY STREQUAL "SHARED_LIBRARY")
	 # Create the install file to be inside ld.so.conf.d
	 SET(install_file_name "debian/install")
         FILE(WRITE ${install_file_name}
	   "debian/lib${PROJECT_NAME}.conf /etc/ld.so.conf.d"
	   )
	 # Create the file to be installed.
	 SET(install_file_name "debian/lib${PROJECT_NAME}.conf")
	 FILE(WRITE ${install_file_name}
	   "${CMAKE_INSTALL_PREFIX}/lib"
	   )
      ENDIF(${PROJECT_NAME}_IS_SHARED_LIBRARY STREQUAL "SHARED_LIBRARY")
    ENDIF(IS_DIRECTORY ${CMAKE_SOURCE_DIR}/debian)
  ENDIF(UNIX)
ENDMACRO(_SETUP_DEBIAN)

# _SETUP_PROJECT_DEB
# -------------------
#
# Add a deb target to generate a Debian package using
# git-buildpackage (Linux specific).
#

MACRO(_SETUP_PROJECT_DEB)
  IF(UNIX)
  ADD_CUSTOM_TARGET(deb-src
    COMMAND
    git-buildpackage
    --git-debian-branch=debian
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Generating source Debian package..."
    )
  ADD_CUSTOM_TARGET(deb
    COMMAND
    git-buildpackage
    --git-debian-branch=debian --git-builder="debuild -S -i.git -I.git"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Generating Debian package..."
    )
  ENDIF(UNIX)
ENDMACRO(_SETUP_PROJECT_DEB)

