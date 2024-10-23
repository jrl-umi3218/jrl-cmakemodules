# Copyright (C) 2008-2014,2018 LAAS-CNRS, JRL AIST-CNRS.
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

# .rst: .. command:: RELEASE_SETUP
#
# .. _target-release:
#
# This adds a *release* target which release a stable version of the current
# package.
#
# To release a package, please run:
#
# .. code-block:: bash
#
# make release VERSION=X.Y.Z
#
# where ``X.Y.Z`` is the version number of your new package.
#
# A release consists in:
#
# * adding a signed tag following the ``vVERSION`` pattern.
# * running ``make distcheck`` (:ref:`distcheck <target-distcheck>`) to make
#   sure everything is ok.
# * running ``make dist`` to generate a tarball
# * running ``make distclean`` to remove the current dist directory
# * reminds that you should push the tag and tarball on the GitHub repository
#   (to be done manually as it is simple but cannot be reverted).
#
# .. todo::
#
# The following steps are missing to the current release procedure:
#
# * uploading the stable documentation.
# * uploading the resulting tarball to GitHub.
# * announce the release by e-mail.
#
macro(RELEASE_SETUP)
  if(UNIX)
    find_program(GIT git)
    string(TIMESTAMP TODAY "%Y-%m-%d")

    # Set LD_LIBRARY_PATH
    if(APPLE)
      set(LD_LIBRARY_PATH_VARIABLE_NAME "DYLD_LIBRARY_PATH")
    else(APPLE)
      set(LD_LIBRARY_PATH_VARIABLE_NAME "LD_LIBRARY_PATH")
    endif(APPLE)

    if(NOT TARGET release_package_xml)
      add_custom_target(release_package_xml COMMENT "Update package.xml")
    endif()
    add_custom_target(
      ${PROJECT_NAME}-release_package_xml
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
      COMMENT "Update package.xml for ${PROJECT_NAME}"
      COMMAND
        sed -i.back \"s|<version>.*</version>|<version>$$VERSION</version>|g\"
        package.xml && rm package.xml.back && ${GIT} add package.xml && ${GIT}
        commit -m "release: Update package.xml version to $$VERSION" && echo
        "Updated package.xml and committed"
    )
    add_dependencies(release_package_xml ${PROJECT_NAME}-release_package_xml)

    if(NOT TARGET release_pyproject_toml)
      add_custom_target(release_pyproject_toml COMMENT "Update pyproject.toml")
    endif()
    add_custom_target(
      ${PROJECT_NAME}-release_pyproject_toml
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
      COMMENT "Update pyproject.toml for ${PROJECT_NAME}"
      COMMAND
        ${PYTHON_EXECUTABLE} ${PROJECT_JRL_CMAKE_MODULE_DIR}/pyproject.py
        $$VERSION && if ! (git diff --quiet pyproject.toml) ; then
        (
          ${GIT}
          add pyproject.toml && ${GIT} commit -m
          "release: Update pyproject.toml version to $$VERSION" && echo
          "Updated pyproject.toml and committed"
        )
        ; fi
    )
    add_dependencies(
      release_pyproject_toml
      ${PROJECT_NAME}-release_pyproject_toml
    )

    if(NOT TARGET release_changelog)
      add_custom_target(release_changelog COMMENT "Update CHANGELOG.md")
    endif()
    add_custom_target(
      ${PROJECT_NAME}-release_changelog
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
      COMMENT "Update CHANGELOG.md for ${PROJECT_NAME}"
      COMMAND
        sed -i.back
        "\"s|\#\# \\[Unreleased\\]|\#\# [Unreleased]\\n\\n\#\# [$$VERSION] - ${TODAY}|\""
        CHANGELOG.md && sed -i.back
        "\"s|^\\[Unreleased]: \\(https://.*compare/\\)\\(v.*\\)...HEAD|[Unreleased]: \\1v$$VERSION...HEAD\\n[$$VERSION]: \\1\\2...v$$VERSION|\""
        CHANGELOG.md && if ! (git diff --quiet CHANGELOG.md) ; then
        (
          ${GIT}
          add CHANGELOG.md && ${GIT} commit -m
          "release: Update CHANGELOG.md for $$VERSION" && echo
          "Updated CHANGELOG.md and committed"
        )
        ; fi
    )
    add_dependencies(release_changelog ${PROJECT_NAME}-release_changelog)

    if(NOT TARGET release_pixi_toml)
      add_custom_target(release_pixi_toml COMMENT "Update pixi.toml")
    endif()
    # gersemi: off
    add_custom_target(
      ${PROJECT_NAME}-release_pixi_toml
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
      COMMENT "Update pixi.toml for ${PROJECT_NAME}"
      COMMAND
        ${PYTHON_EXECUTABLE} ${PROJECT_JRL_CMAKE_MODULE_DIR}/pixi.py $$VERSION &&
        if ! (git diff --quiet pixi.toml) ; then
        (
         ${GIT} add pixi.toml &&
         ${GIT} commit -m "release: Update pixi.toml version to $$VERSION" &&
         echo "Updated pixi.toml and committed"
        ) ; fi
    )
    # gersemi: on
    add_dependencies(release_pixi_toml ${PROJECT_NAME}-release_pixi_toml)

    if(NOT TARGET release_citation_cff)
      add_custom_target(release_citation_cff COMMENT "Update CITATION.cff")
    endif()
    add_custom_target(
      ${PROJECT_NAME}-release_citation_cff
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
      COMMENT "Update CITATION.cff for ${PROJECT_NAME}"
      COMMAND
        sed -i.back
        "\"s|^version:.*|version: $$VERSION|;s|^date-released:.*|date-released: \\\"${TODAY}\\\"|\""
        CITATION.cff && rm CITATION.cff.back && ${GIT} add CITATION.cff &&
        ${GIT} commit -m "release: Update CITATION.cff version to $$VERSION" &&
        echo "Updated CITATION.cff and committed"
    )
    add_dependencies(release_citation_cff ${PROJECT_NAME}-release_citation_cff)

    set(BUILD_CMD ${CMAKE_COMMAND} --build ${PROJECT_BINARY_DIR} --target)
    if(NOT TARGET release)
      add_custom_target(release COMMENT "Create a new release")
    endif()
    # gersemi: off
    add_custom_target(
      ${PROJECT_NAME}-release
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
      COMMENT "Create a new release for ${PROJECT_NAME}"
      COMMAND
        export LD_LIBRARY_PATH=$ENV{LD_LIBRARY_PATH} &&
        export ${LD_LIBRARY_PATH_VARIABLE_NAME}=$ENV{${LD_LIBRARY_PATH_VARIABLE_NAME}} &&
        export PYTHONPATH=$ENV{PYTHONPATH} &&
        ! test x$$VERSION = x || (echo "Please set a version for this release" && false) &&
        # Update version in package.xml if it exists
        if [ -f "package.xml" ]; then (${BUILD_CMD} ${PROJECT_NAME}-release_package_xml) ; fi &&
        # Update version in pyproject.toml if it exists
        if [ -f "pyproject.toml" ]; then (${BUILD_CMD} ${PROJECT_NAME}-release_pyproject_toml) ; fi &&
        # Update CHANGELOG.md if it exists
        if [ -f "CHANGELOG.md" ]; then (${BUILD_CMD} ${PROJECT_NAME}-release_changelog) ; fi &&
        # Update version in pixi.toml if it exists
        if [ -f "pixi.toml" ]; then (${BUILD_CMD} ${PROJECT_NAME}-release_pixi_toml) ; fi &&
        # Update date and version in CITATION.cff if it exists
        if [ -f "CITATION.cff" ]; then (${BUILD_CMD} ${PROJECT_NAME}-release_citation_cff) ; fi &&
        ${GIT} tag -s v$$VERSION -m "Release of version $$VERSION." &&
        cd ${PROJECT_BINARY_DIR} &&
        cmake ${PROJECT_SOURCE_DIR} &&
        ${BUILD_CMD} ${PROJECT_NAME}-distcheck ||
        (
         echo "Please fix distcheck first." &&
         cd ${PROJECT_SOURCE_DIR} &&
         ${GIT} tag -d v$$VERSION &&
         cd ${PROJECT_BINARY_DIR} &&
         cmake ${PROJECT_SOURCE_DIR} &&
         false
        ) &&
        ${BUILD_CMD} ${PROJECT_NAME}-dist &&
        ${BUILD_CMD} ${PROJECT_NAME}-distclean &&
        echo "Please, run 'git push --tags' and upload the tarball to github to finalize this release."
    )
    # gersemi: on
    add_dependencies(release ${PROJECT_NAME}-release)
  endif()
endmacro()
