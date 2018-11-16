# Copyright (C) 2018 LAAS-CNRS, JRL AIST-CNRS, INRIA
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
# .. ifmode:: user
#
# .. command:: PROJECT_USE_CXX11
#
#    This macro set up the project to compile the whole project 
#    with C++11 standards.  
#
MACRO(PROJECT_USE_CXX11)
  IF(CMAKE_VERSION VERSION_LESS "3.1")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
  ELSE()
    SET(CMAKE_CXX_STANDARD 11)
  ENDIF()
  IF(APPLE)
    IF(POLICY CMP0025)
      CMAKE_POLICY(SET CMP0025 NEW)
    ENDIF()
  ENDIF()
ENDMACRO(PROJECT_USE_CXX11)
