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

# .rst: .. command:: _SETUP_PROJECT_DIST
#
# .. _target-dist:
#
# Add a *dist* target to generate a tarball using ``git-archive``.
#
# Linux specific: use ``git-archive-all.sh`` to obtain a recursive
# ``git-archive`` on the project's submodule. Please note that
# ``git-archive-all.sh`` is not carefully written and create a temporary file in
# the source directory (which is then moved to the build directory).
macro(_SETUP_PROJECT_DIST)
  if(UNIX)
    find_program(TAR tar)
    find_program(GPG gpg)

    if(APPLE)
      set(GIT_ARCHIVE_ALL ${PROJECT_JRL_CMAKE_MODULE_DIR}/git-archive-all.py)
    else(APPLE)
      set(GIT_ARCHIVE_ALL ${PROJECT_JRL_CMAKE_MODULE_DIR}/git-archive-all.sh)
    endif(APPLE)

    # Use git-archive-all.sh to generate distributable source code
    if(NOT TARGET distdir)
      add_custom_target(distdir COMMENT "Generating dist directory...")
    endif()
    # gersemi: off
    add_custom_target(
      ${PROJECT_NAME}-distdir
      COMMAND
        rm -f /tmp/${PROJECT_NAME}.tar &&
        ${GIT_ARCHIVE_ALL} --prefix ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/
          ${PROJECT_NAME}.tar &&
        cd ${PROJECT_BINARY_DIR}/ &&
        (
         test -d ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION} &&
         find ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/ -type d -print0 |
           xargs -0 chmod a+w || true
        ) &&
        rm -rf ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/ &&
        ${TAR} xf ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}.tar &&
        echo "${PROJECT_VERSION}" >
          ${PROJECT_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/.version &&
          ${PROJECT_JRL_CMAKE_MODULE_DIR}/gitlog-to-changelog --srcdir ${PROJECT_SOURCE_DIR} >
          ${PROJECT_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/ChangeLog &&
        rm -f ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}.tar
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
      COMMENT "Generating dist directory for ${PROJECT_NAME}...")
    # gersemi: on
    add_dependencies(distdir ${PROJECT_NAME}-distdir)

    # Create a tar.gz tarball for the project, and generate the signature
    if(NOT TARGET dist_targz)
      add_custom_target(
        dist_targz
        COMMENT "Generating tar.gz tarball and its signature..."
      )
    endif()
    # gersemi: off
    add_custom_target(
      ${PROJECT_NAME}-dist_targz
      COMMAND
        ${TAR} -czf ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.gz
          ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/ &&
        ${GPG} --detach-sign --armor -o
          ${PROJECT_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.gz.sig
          ${PROJECT_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.gz
      WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
      COMMENT
        "Generating tar.gz tarball and its signature for ${PROJECT_NAME}...")
    # gersemi: on
    add_dependencies(dist_targz ${PROJECT_NAME}-dist_targz)

    # Create a tar.bz2 tarball for the project, and generate the signature
    if(NOT TARGET dist_tarbz2)
      add_custom_target(
        dist_tarbz2
        COMMENT "Generating tar.bz2 tarball and its signature..."
      )
    endif()
    # gersemi: off
    add_custom_target(
      ${PROJECT_NAME}-dist_tarbz2
      COMMAND
        ${TAR} -cjf ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.bz2
          ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/ &&
        ${GPG} --detach-sign --armor -o
          ${PROJECT_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.bz2.sig
          ${PROJECT_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.bz2
      WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
      COMMENT
        "Generating tar.bz2 tarball and its signature for ${PROJECT_NAME}...")
    # gersemi: on
    add_dependencies(dist_tarbz2 ${PROJECT_NAME}-dist_tarbz2)

    # Create a tar.xz tarball for the project, and generate the signature
    if(NOT TARGET dist_tarxz)
      add_custom_target(
        dist_tarxz
        COMMENT "Generating tar.xz tarball and its signature..."
      )
    endif()
    # gersemi: off
    add_custom_target(
      ${PROJECT_NAME}-dist_tarxz
      COMMAND
        ${TAR} -cJf ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.xz
          ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/ &&
        ${GPG} --detach-sign --armor -o
          ${PROJECT_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.xz.sig
          ${PROJECT_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.xz
      WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
      COMMENT
        "Generating tar.xz tarball and its signature for ${PROJECT_NAME}...")
    # gersemi: on
    add_dependencies(dist_tarxz ${PROJECT_NAME}-dist_tarxz)

    # Alias: dist = dist_targz (backward compatibility)
    if(NOT TARGET dist)
      add_custom_target(dist)
    endif()
    add_custom_target(${PROJECT_NAME}-dist DEPENDS ${PROJECT_NAME}-dist_targz)
    add_dependencies(dist ${PROJECT_NAME}-dist)

    # TODO: call this during `make clean`
    if(NOT TARGET distclean)
      add_custom_target(distclean COMMENT "Cleaning dist sources...")
    endif()
    # gersemi: off
    add_custom_target(
      ${PROJECT_NAME}-distclean
      COMMAND
        rm -rf
          ${PROJECT_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/
      WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
      COMMENT "Cleaning dist sources for ${PROJECT_NAME}...")
    # gersemi: on
    add_dependencies(distclean ${PROJECT_NAME}-distclean)

    if(NOT TARGET distorig)
      add_custom_target(distorig COMMENT "Generating orig tarball...")
    endif()
    # gersemi: off
    add_custom_target(
      ${PROJECT_NAME}-distorig
      COMMAND
        cmake -E copy ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.gz
          ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.orig.tar.gz
      WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
      COMMENT "Generating orig tarball for ${PROJECT_NAME}...")
    # gersemi: on
    add_dependencies(distorig ${PROJECT_NAME}-distorig)

    add_dependencies(${PROJECT_NAME}-dist_targz ${PROJECT_NAME}-distdir)
    add_dependencies(${PROJECT_NAME}-dist_tarbz2 ${PROJECT_NAME}-distdir)
    add_dependencies(${PROJECT_NAME}-dist_tarxz ${PROJECT_NAME}-distdir)
    add_dependencies(${PROJECT_NAME}-distorig ${PROJECT_NAME}-dist)
  else()
    # FIXME: what to do here?
  endif()
endmacro(_SETUP_PROJECT_DIST)
