# Copyright (C) 2008-2013 LAAS-CNRS, JRL AIST-CNRS.
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

# SEARCH_FOR_GEOMETRIC_TOOLS
# -----------------
#
# The geometric-tools (aka WildMagic5) does not provide a pkg-config
# file. This macro defines a CMake variable that must be filled to
# point to the geometric-tools install prefix.
#
MACRO(SEARCH_FOR_GEOMETRIC_TOOLS)
  SET(GEOMETRIC_TOOLS_INSTALL_PREFIX "" CACHE PATH "geometric-tools installation prefix")
  SET(LIB_GEOMETRIC_TOOLS_CORE LIB_GEOMETRIC_TOOLS_CORE-NOTFOUND)
  SET(LIB_GEOMETRIC_TOOLS_MATH LIB_GEOMETRIC_TOOLS_MATH-NOTFOUND)
  FIND_LIBRARY(LIB_GEOMETRIC_TOOLS_CORE
    libWm5Core.so
    PATH
    ${GEOMETRIC_TOOLS_INSTALL_PREFIX}/lib)
  IF (NOT LIB_GEOMETRIC_TOOLS_CORE)
    MESSAGE(FATAL_ERROR
      "Failed to find geometric-tools Core library, check that geometric-tools is installed and set the GEOMETRIC_TOOLS_INSTALL_PREFIX CMake variable.")
  ENDIF()
  FIND_LIBRARY(LIB_GEOMETRIC_TOOLS_MATH
    libWm5Mathematics.so
    PATH
    ${GEOMETRIC_TOOLS_INSTALL_PREFIX}/lib)
  IF (NOT LIB_GEOMETRIC_TOOLS_MATH)
    MESSAGE(FATAL_ERROR
      "Failed to find geometric-tools Mathematics library, check that geometric-tools is installed and set the GEOMETRIC_TOOLS_INSTALL_PREFIX CMake variable.")
  ENDIF()
  SET(GEOMETRIC_TOOLS_H GEOMETRIC_TOOLS-NOTFOUND)
  FIND_PATH (GEOMETRIC_TOOLS_H
    Wm5DistSegment3Segment3.h
    "${GEOMETRIC_TOOLS_INSTALL_PREFIX}/include/geometric-tools")
  IF (NOT GEOMETRIC_TOOLS_H)
    MESSAGE(FATAL_ERROR
      "Failed to find geometric-tools/Wm5DistSegment3Segment3.h, check that geometric-tools is installed.")
  ENDIF()
  INCLUDE_DIRECTORIES("${GEOMETRIC_TOOLS_INSTALL_PREFIX}/include")
  LINK_DIRECTORIES("${GEOMETRIC_TOOLS_INSTALL_PREFIX}/lib")
ENDMACRO(SEARCH_FOR_GEOMETRIC_TOOLS)
