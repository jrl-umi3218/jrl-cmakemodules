# Copyright (C) 2017 LAAS-CNRS, JRL AIST-CNRS.
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

# ADD_VERSION_SCRIPT(TARGET VERSION_SCRIPT)
# ------------------
#
# This macro adds a version script to a given target and a link-time
# dependency between the target and the version script.
#
# It has no effect on WIN32 platform.
#
# TARGET: Name of the target, the macro does nothing if TARGET is not a
#         cmake target.
#
# VERSION_SCRIPT: Version script to add to the library.
#
MACRO(ADD_VERSION_SCRIPT TARGET VERSION_SCRIPT)
  IF(NOT WIN32)
    IF(TARGET ${TARGET})
      SET_PROPERTY(TARGET ${TARGET} APPEND_STRING PROPERTY
                   LINK_FLAGS " -Wl,--version-script,${VERSION_SCRIPT}")
      SET_TARGET_PROPERTIES(${TARGET} PROPERTIES LINK_DEPENDS ${VERSION_SCRIPT})
    ENDIF()
  ENDIF()
ENDMACRO(ADD_VERSION_SCRIPT)
