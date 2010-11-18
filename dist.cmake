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
    FIND_PROGRAM(TAR tar)

    ADD_CUSTOM_TARGET(distdir
      COMMAND
      ${CMAKE_SOURCE_DIR}/cmake/git-archive-all.sh
      --prefix ${PROJECT_NAME}-${PROJECT_VERSION}/  ${PROJECT_NAME}.tar
      && cd ${CMAKE_BINARY_DIR}/
      && (test -d ${PROJECT_NAME}-${PROJECT_VERSION} |
	find ${PROJECT_NAME}-${PROJECT_VERSION}/ -type d -print0
         | xargs -0 chmod a+w  || true)
      && rm -rf ${PROJECT_NAME}-${PROJECT_VERSION}/
      && ${TAR} xf ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}.tar
      && echo "${PROJECT_VERSION}" >
         ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${PROJECT_VERSION}/.version
      && rm -f ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}.tar
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      COMMENT "Generating dist directory..."
      )

    ADD_CUSTOM_TARGET(dist
      COMMAND
      ${TAR} czf ${PROJECT_NAME}-${PROJECT_VERSION}.tar.gz
                 ${PROJECT_NAME}-${PROJECT_VERSION}/
      && rm -rf ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${PROJECT_VERSION}/
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      COMMENT "Generating tarball..."
      )
    ADD_DEPENDENCIES(dist distdir)
  ELSE()
    #FIXME: what to do here?
  ENDIF()
ENDMACRO(_SETUP_PROJECT_DIST)
