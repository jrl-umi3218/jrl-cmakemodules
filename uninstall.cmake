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

# _SETUP_PROJECT_UNINSTALL
# ------------------------
#
# Add custom rule to uninstall the package.
#
macro(_SETUP_PROJECT_UNINSTALL)
  # FIXME: it is utterly stupid to rely on the install manifest. Can't we just
  # remember what we install ?!
  configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake/cmake_uninstall.cmake" IMMEDIATE @ONLY)

  add_custom_target(
    uninstall "${CMAKE_COMMAND}" -P
              "${CMAKE_CURRENT_BINARY_DIR}/cmake/cmake_uninstall.cmake")

  configure_file("${CMAKE_CURRENT_LIST_DIR}/cmake_reinstall.cmake.in"
                 "${PROJECT_BINARY_DIR}/cmake/cmake_reinstall.cmake.configured")
  if(DEFINED CMAKE_BUILD_TYPE)
    file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/cmake/${CMAKE_BUILD_TYPE}")
  else(DEFINED CMAKE_BUILD_TYPE)
    foreach(CFG ${CMAKE_CONFIGURATION_TYPES})
      file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/cmake/${CFG}")
    endforeach()
  endif(DEFINED CMAKE_BUILD_TYPE)
  file(
    GENERATE
    OUTPUT "${PROJECT_BINARY_DIR}/cmake/$<CONFIGURATION>/cmake_reinstall.cmake"
    INPUT "${PROJECT_BINARY_DIR}/cmake/cmake_reinstall.cmake.configured")
  add_custom_target(
    reinstall
    "${CMAKE_COMMAND}" -P
    "${PROJECT_BINARY_DIR}/cmake/$<CONFIGURATION>/cmake_reinstall.cmake")
endmacro(_SETUP_PROJECT_UNINSTALL)
