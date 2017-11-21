# Copyright (C) 2008-2014 LAAS-CNRS, JRL AIST-CNRS.
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

#.rst:
# .. command:: RELEASE_SETUP
#
#   .. _target-release:
#
#   This adds a *release* target which release a stable version of the
#   current package.
#
#   To release a package, please run:
#
#   .. code-block:: bash
#
#     make release VERSION=X.Y.Z
#
#   where ``X.Y.Z`` is the version number of your new package.
#
#   A release consists in:
#
#   - adding a signed tag following the ``vVERSION`` pattern.
#   - running ``make distcheck`` (:ref:`distcheck <target-distcheck>`) to make sure everything is ok.
#   - pushing the tag on the GitHub repository (to be done manually as
#     it is simple but cannot be reverted).
#
#   .. todo::
#
#     The following steps are missing to the current release procedure:
#
#     - uploading the stable documentation.
#     - uploading the resulting tarball to GitHub.
#     - announce the release by e-mail.
#
MACRO(RELEASE_SETUP)
  IF(UNIX)
    FIND_PROGRAM(GIT git)

    ADD_CUSTOM_TARGET(release
      COMMAND
      ! test x$$VERSION = x
        || (echo "Please set a version for this release" && false)
      && cd ${PROJECT_SOURCE_DIR}
      && ${GIT} tag -s v$$VERSION -m "Release of version $$VERSION."
      && cd ${CMAKE_BINARY_DIR}
      && cmake ${PROJECT_SOURCE_DIR}
      && make distcheck
       || (echo "Please fix distcheck first."
           && cd ${PROJECT_SOURCE_DIR}
           && ${GIT} tag -d v$$VERSION
           && cd ${CMAKE_BINARY_DIR}
           && cmake ${PROJECT_SOURCE_DIR}
           && false)
      && echo "Please, run 'git push --tags' to finalize this release."
      )
  ENDIF()
ENDMACRO()
