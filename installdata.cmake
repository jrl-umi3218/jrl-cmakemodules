# Copyright (C) 2010 Olivier Stasse, JRL, CNRS/AIST.
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

# _INSTALL_PROJECT_DATA_DOCUMENTATION
# -----------------------------------
#
# Build the installation rules for a set of data to install
# 
MACRO(_INSTALL_PROJECT_DATA)
  IF(DEFINED ${PROJECT_NAME}_DATA)
    SET(${LPROJECT_NAME}_FULLPATHDATA )
    FOREACH (ldata ${${PROJECT_NAME}_DATA})
      SET(${PROJECT_NAME}_FULLPATHDATA
        ${${PROJECT_NAME}_FULLPATHDATA} 
        ${CMAKE_CURRENT_SOURCE_DIR}/${ldata})
    ENDFOREACH(ldata)

    INSTALL(FILES ${${PROJECT_NAME}_FULLPATHDATA}
      DESTINATION share/${PROJECT_NAME}
      PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE
    )
  ENDIF(DEFINED ${PROJECT_NAME}_DATA)
ENDMACRO(_INSTALL_PROJECT_DATA)
