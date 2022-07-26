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

# _SETUP_DEBIAN
# -------------------
#
# Prepare needed file for debian if the target is a shared library.
#
macro(_SETUP_DEBIAN)
  if(BUILDING_DEBIAN_PACKAGE)
    message(STATUS "setup debian. Trying to get the type of ${PROJECT_NAME}")
    get_target_property(${PROJECT_NAME}_IS_SHARED_LIBRARY ${PROJECT_NAME} TYPE)
    message(STATUS "${PROJECT_NAME}_IS_SHARED_LIBRARY:"
                   ${${PROJECT_NAME}_IS_SHARED_LIBRARY})

    if(UNIX)
      if(IS_DIRECTORY ${PROJECT_SOURCE_DIR}/debian)
        if(${PROJECT_NAME}_IS_SHARED_LIBRARY STREQUAL "SHARED_LIBRARY")
          # Create the install file to be inside ld.so.conf.d
          message(STATUS "PROJECT_SOURCE_DIR:" ${PROJECT_SOURCE_DIR})
          execute_process(
            COMMAND ${GIT} describe --abbrev=0 --match=v* HEAD
            WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
            RESULT_VARIABLE LGIT_DESCRIBE_RESULT
            OUTPUT_VARIABLE LGIT_DESCRIBE_OUTPUT
            ERROR_VARIABLE LGIT_DESCRIBE_ERROR
            OUTPUT_STRIP_TRAILING_WHITESPACE)
          message(STATUS "LGIT_DESCRIBE_OUTPUT:" ${LGIT_DESCRIBE_OUTPUT})
          message(STATUS "LGIT_DESCRIBE_ERROR:" ${LGIT_DESCRIBE_ERROR})

          # From the v[0-9]+.[0-9]+.[0-9]+ version remove the v in prefix.
          string(REGEX REPLACE "^v" "" LPROJECT_RELEASE_VERSION
                               "${LGIT_DESCRIBE_OUTPUT}")

          # Considers the file *.release.version
          set(file_release_version
              "${PROJECT_SOURCE_DIR}/debian/${PROJECT_NAME}.release.version")

          message(STATUS "file_release_version: ${file_release_version}")
          message(STATUS "Everything sounds great: ${LPROJECT_RELEASE_VERSION}")
          # If this is not a git version.
          if(LPROJECT_RELEASE_VERSION STREQUAL "")
            # If the file exists
            message(STATUS "Read the release version file")
            if(EXISTS ${file_release_version})
              # Use it. This is the release version.
              file(STRINGS ${file_release_version} LPROJECT_RELEASE_VERSION)
            endif(EXISTS ${file_release_version})
            # if this is
          else(LPROJECT_RELEASE_VERSION STREQUAL "")
            # Then create the containing the release version.
            message(STATUS "Create the release version file")
            file(WRITE ${file_release_version} "${LPROJECT_RELEASE_VERSION}")

          endif(LPROJECT_RELEASE_VERSION STREQUAL "")

          set(install_file_name_src
              "debian/lib${PROJECT_NAME}${LPROJECT_RELEASE_VERSION}.install.cmake"
          )

          message(STATUS "install_file_name_src :" ${install_file_name_src})
          if(EXISTS ${PROJECT_SOURCE_DIR}/${install_file_name_src})
            set(install_file_name_dest
                "debian/lib${PROJECT_NAME}${LPROJECT_RELEASE_VERSION}.install")
            execute_process(
              COMMAND cp ${install_file_name_src} ${install_file_name_dest}
              WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})

            message(STATUS "install_file_name :" ${install_file_name_dest})
            file(APPEND ${install_file_name_dest} "/etc/ld.so.conf.d/*\n")
            # Create the file to be installed.
            set(install_file_name "debian/lib${PROJECT_NAME}.conf")
            file(WRITE ${install_file_name} "${CMAKE_INSTALL_PREFIX}/lib")
            message(STATUS "install_file_name :" ${install_file_name})
            install(FILES ${install_file_name} DESTINATION /etc/ld.so.conf.d)

          endif(EXISTS ${PROJECT_SOURCE_DIR}/${install_file_name_src})
        endif(${PROJECT_NAME}_IS_SHARED_LIBRARY STREQUAL "SHARED_LIBRARY")
      endif(IS_DIRECTORY ${PROJECT_SOURCE_DIR}/debian)
    endif(UNIX)
  endif(BUILDING_DEBIAN_PACKAGE)
endmacro(_SETUP_DEBIAN)

# _SETUP_PROJECT_DEB
# -------------------
#
# Add a deb target to generate a Debian package using git-buildpackage (Linux
# specific).
#

macro(_SETUP_PROJECT_DEB)
  if(UNIX AND NOT APPLE)
    add_custom_target(
      deb-src
      COMMAND git-buildpackage --git-debian-branch=debian
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
      COMMENT "Generating source Debian package...")
    add_custom_target(
      deb
      COMMAND git-buildpackage --git-debian-branch=debian
              --git-builder="debuild -S -i.git -I.git"
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
      COMMENT "Generating Debian package...")
  endif(UNIX AND NOT APPLE)
endmacro(_SETUP_PROJECT_DEB)
