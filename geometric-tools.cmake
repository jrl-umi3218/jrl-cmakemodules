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

# SEARCH_FOR_GEOMETRIC_TOOLS
# -----------------
#
# The geometric-tools (aka WildMagic5) does not provide a pkg-config file. This
# macro defines a CMake variable that must be filled to point to the
# geometric-tools install prefix.
#
macro(SEARCH_FOR_GEOMETRIC_TOOLS)
  message(STATUS "geometric-tools is required.")
  set(GEOMETRIC_TOOLS_INSTALL_PREFIX
      ""
      CACHE PATH "geometric-tools installation prefix")
  set(LIB_GEOMETRIC_TOOLS_CORE LIB_GEOMETRIC_TOOLS_CORE-NOTFOUND)
  set(LIB_GEOMETRIC_TOOLS_MATH LIB_GEOMETRIC_TOOLS_MATH-NOTFOUND)
  message(STATUS "checking for module geometric-tools")
  find_library(LIB_GEOMETRIC_TOOLS_CORE libWm5Core.so PATH
               ${GEOMETRIC_TOOLS_INSTALL_PREFIX}/lib)
  if(NOT LIB_GEOMETRIC_TOOLS_CORE)
    message(
      FATAL_ERROR
        "Failed to find geometric-tools Core library, check that geometric-tools is installed and set the GEOMETRIC_TOOLS_INSTALL_PREFIX CMake variable."
    )
  endif()
  find_library(LIB_GEOMETRIC_TOOLS_MATH libWm5Mathematics.so PATH
               ${GEOMETRIC_TOOLS_INSTALL_PREFIX}/lib)
  if(NOT LIB_GEOMETRIC_TOOLS_MATH)
    message(
      FATAL_ERROR
        "Failed to find geometric-tools Mathematics library, check that geometric-tools is installed and set the GEOMETRIC_TOOLS_INSTALL_PREFIX CMake variable."
    )
  endif()
  set(GEOMETRIC_TOOLS_H GEOMETRIC_TOOLS-NOTFOUND)
  find_path(GEOMETRIC_TOOLS_H Wm5DistSegment3Segment3.h
            "${GEOMETRIC_TOOLS_INSTALL_PREFIX}/include/geometric-tools")
  if(NOT GEOMETRIC_TOOLS_H)
    message(
      FATAL_ERROR
        "Failed to find geometric-tools/Wm5DistSegment3Segment3.h, check that geometric-tools is installed."
    )
  endif()

  message(STATUS "  found geometric-tools")

  set(GEOMETRIC_TOOLS_INCLUDEDIR "${GEOMETRIC_TOOLS_INSTALL_PREFIX}/include")
  set(GEOMETRIC_TOOLS_LIBRARYDIR "${GEOMETRIC_TOOLS_INSTALL_PREFIX}/lib")
  set(GEOMETRIC_TOOLS_LIBRARIES ${LIB_GEOMETRIC_TOOLS_MATH}
                                ${LIB_GEOMETRIC_TOOLS_CORE})

  include_directories(SYSTEM ${GEOMETRIC_TOOLS_INCLUDEDIR})
  link_directories(${GEOMETRIC_TOOLS_LIBRARYDIR})

  pkg_config_append_cflags("-isystem ${GEOMETRIC_TOOLS_INCLUDEDIR}")
  pkg_config_append_library_dir("${GEOMETRIC_TOOLS_LIBRARYDIR}")

  message(STATUS "Module geometric-tools has been detected with success.")
endmacro(SEARCH_FOR_GEOMETRIC_TOOLS)
