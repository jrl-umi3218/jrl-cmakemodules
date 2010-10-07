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

# _SETUP_PROJECT_DIST
# -------------------
#
# Add a dist target to generate a tarball using git-archive.
#
# Linux specific: use git-archive-all.sh to obtain a recursive
# git-archive on the project's submodule.
# Please note that git-archive-all.sh is not carefully written
# and create a temporary file in the source directory
# (which is then moved to the build directory).
MACRO(_SETUP_PROJECT_DIST)
  IF(UNIX)
  ADD_CUSTOM_TARGET(dist
    COMMAND
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/git-archive-all.sh
    --prefix ${PROJECT_NAME}-${PROJECT_VERSION}/
    && gzip -f ${PROJECT_NAME}.tar
    && mv ${PROJECT_NAME}.tar.gz
          ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-${PROJECT_VERSION}.tar.gz
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Generating tarball..."
    )
  ENDIF(UNIX)
ENDMACRO(_SETUP_PROJECT_DIST)
