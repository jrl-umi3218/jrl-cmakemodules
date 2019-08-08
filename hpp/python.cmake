# Copyright (C) 2019 LAAS-CNRS
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

IF(NOT COMMAND FINDPYTHON)
  include(cmake/python.cmake)
ENDIF()

SET(PYTHON_DEFAULT_VERSION 2.7)

MACRO(HPP_FINDPYTHON)
  IF(NOT DEFINED PYTHON_DESIRED_VERSION)
    SET(PYTHON_DESIRED_VERSION ${PYTHON_DEFAULT_VERSION})
  ENDIF()
  FINDPYTHON(${PYTHON_DESIRED_VERSION} EXACT ${ARGN})
ENDMACRO(HPP_FINDPYTHON)
