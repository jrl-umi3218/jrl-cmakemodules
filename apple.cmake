# Copyright (C) 2018 LAAS-CNRS, JRL AIST-CNRS.
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

# .rst: .. command:: APPLY_DEFAULT_APPLE_CONFIGURATION ()
#
# Apply a default CMake policy on OSX systems
#
macro(APPLY_DEFAULT_APPLE_CONFIGURATION)
  if(APPLE) # Ensure that the policy if is only applied on OSX systems
    set(CMAKE_MACOSX_RPATH TRUE)
    set(CMAKE_SKIP_BUILD_RPATH FALSE)
    set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

    set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
    list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES
         "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
    if("${isSystemDir}" STREQUAL "-1")
      set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
    endif("${isSystemDir}" STREQUAL "-1")
  endif(APPLE)
endmacro(APPLY_DEFAULT_APPLE_CONFIGURATION)
