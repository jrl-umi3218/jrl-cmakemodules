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

# .rst: .. ifmode:: internal
#
# .. variable::AUTO_UNINTSALL
#
# When this is ON, the install target will start by uninstalling

option(AUTO_UNINSTALL "Enable auto-uninstall on install" ON)

# _SETUP_PROJECT_UNINSTALL
# ------------------------
#
# Add custom rule to uninstall the package.
#
macro(_SETUP_PROJECT_UNINSTALL)
  # Detect if the .catkin was created previously
  if(
    NOT DEFINED PACKAGE_CREATES_DOT_CATKIN
    OR
      NOT
        "${PACKAGE_PREVIOUS_INSTALL_PREFIX}" STREQUAL "${CMAKE_INSTALL_PREFIX}"
  )
    set(
      PACKAGE_PREVIOUS_INSTALL_PREFIX
      "${CMAKE_INSTALL_PREFIX}"
      CACHE INTERNAL
      "Cache install prefix given to the package"
    )
    if(EXISTS "${CMAKE_INSTALL_PREFIX}/.catkin")
      set(PACKAGE_CREATES_DOT_CATKIN FALSE CACHE INTERNAL "")
    else()
      set(PACKAGE_CREATES_DOT_CATKIN TRUE CACHE INTERNAL "")
    endif()
  endif()
  # FIXME: it is utterly stupid to rely on the install manifest. Can't we just
  # remember what we install ?!
  configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake/cmake_uninstall.cmake"
    @ONLY
  )

  if(NOT TARGET uninstall)
    add_custom_target(uninstall)
  endif()
  add_custom_target(
    ${PROJECT_NAME}-uninstall
    "${CMAKE_COMMAND}"
    -DPACKAGE_CREATES_DOT_CATKIN=${PACKAGE_CREATES_DOT_CATKIN} -P
    "${CMAKE_CURRENT_BINARY_DIR}/cmake/cmake_uninstall.cmake"
  )
  add_dependencies(uninstall ${PROJECT_NAME}-uninstall)

  configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/cmake_reinstall.cmake.in"
    "${PROJECT_BINARY_DIR}/cmake/cmake_reinstall.cmake.configured"
    @ONLY
  )
  if(DEFINED CMAKE_BUILD_TYPE)
    file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/cmake/${CMAKE_BUILD_TYPE}")
  else(DEFINED CMAKE_BUILD_TYPE)
    foreach(CFG ${CMAKE_CONFIGURATION_TYPES})
      file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/cmake/${CFG}")
    endforeach()
  endif(DEFINED CMAKE_BUILD_TYPE)
  file(
    GENERATE OUTPUT
    "${PROJECT_BINARY_DIR}/cmake/$<CONFIGURATION>/cmake_reinstall.cmake"
    INPUT "${PROJECT_BINARY_DIR}/cmake/cmake_reinstall.cmake.configured"
  )

  if(NOT TARGET reinstall)
    add_custom_target(reinstall)
  endif()
  add_custom_target(
    ${PROJECT_NAME}-reinstall
    "${CMAKE_COMMAND}" -P
    "${PROJECT_BINARY_DIR}/cmake/$<CONFIGURATION>/cmake_reinstall.cmake"
  )
  add_dependencies(reinstall ${PROJECT_NAME}-reinstall)
endmacro(_SETUP_PROJECT_UNINSTALL)

# We setup the auto-uninstall target here, it is early enough that we can ensure
# it is going to be called first See the first paragraph here
# https://cmake.org/cmake/help/latest/command/install.html#introduction
if(DEFINED CMAKE_CONFIGURATION_TYPES)
  set(UNINSTALL_CONFIG_ARG "--config \${CMAKE_INSTALL_CONFIG_NAME}")
endif()
if(AUTO_UNINTSALL)
  install(
    CODE
      "execute_process(COMMAND \"${CMAKE_COMMAND}\" --build \"${PROJECT_BINARY_DIR}\" ${UNINSTALL_CONFIG_ARG} --target uninstall)"
  )
endif()
