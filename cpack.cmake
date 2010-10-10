# Copyright (C) 2010 Thomas Moulard, Olivier Stasse, JRL, CNRS/AIST.
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

INCLUDE(CPack)

# SETUP_PROJECT_CPACK
# -------------------
#
# Warning: use only this macro if NECESSARY.
#
# This macro adds CPack support to the package.
# It should be avoided unless Ubuntu 8.04 packages have to be built.
#
# Please, prefer the use of git-archive for tarball generation
# and debhelper for Debian package generation.
#
MACRO(SETUP_PROJECT_CPACK)
  SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PROJECT_DESCRIPTION})
  SET(CPACK_PACKAGE_VENDOR "JRL CNRS/AIST")
  SET(CPACK_PACKAGE_DESCRIPTION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/README.md)
  SET(CPACK_DEBIAN_PACKAGE_MAINTAINER
    "Olivier Stasse (olivier.stasse@aist.go.jp)")

  # The following components are regex's to match anywhere (unless anchored)
  # in absolute path + filename to find files or directories to be excluded
  # from source tarball.
  SET(CPACK_SOURCE_IGNORE_FILES
    "~$"
    "^${PROJECT_SOURCE_DIR}/build/"
    "^${PROJECT_SOURCE_DIR}/.git/"
    )

  SET(
    CPACK_SOURCE_PACKAGE_FILE_NAME
    "${PROJECT_NAME}-src-${PROJECT_VERSION}"
    CACHE INTERNAL "tarball basename"
    )

  SET(CPACK_PACKAGE_NAME ${PROJECT_NAME})
  SET(CPACK_BINARY_DEB ON)
  SET(CPACK_GENERATOR TGZ)
  SET(CPACK_GENERATOR DEB)
  SET(CPACK_PACKAGING_INSTALL_PREFIX "/usr/share/openrobots")
ENDMACRO(SETUP_PROJECT_CPACK)
