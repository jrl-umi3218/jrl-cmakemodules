# Copyright (C) 2010 Florent Lamiraux, Thomas Moulard, JRL, CNRS/AIST.
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
#
# Create and install KineoPathPlanner (Kitelab) add-on modules.

# KINEO_ADDON
# -------------
#
# Build a add-on module for KineoPathPlanner
#
# MODULE_NAME		: name of the module
#
#   1. compile a shared object named lib${MODULE_NAME}.so the sources of
#      which are defined by (global) variable KINEO_ADDON_SOURCES,
#   2. install this shared object in lib/modules/${UNAME_N} where ${UNAME_N}
#      is the result of command "uname -n": the name of the machine,
#   3. generate a target named "license" that creates the required .kab file.
#      Note that you must be in possession of a valid kineo license file.
#
#   Before calling this macro, it is recommended to reset variable
#   PKG_CONFIG_LIBS to the empty string since the right directory is appended
#   to the "libs:" field of the .pc file by the macro.
#
MACRO(KINEO_ADDON MODULE_NAME)
  EXEC_PROGRAM(uname ARGS -n OUTPUT_VARIABLE UNAME_N)
  SET(ADDON_INSTALLDIR lib/modules/${UNAME_N})
  PKG_CONFIG_APPEND_LIBRARY_DIR(${CMAKE_INSTALL_PREFIX}/${ADDON_INSTALLDIR})
  PKG_CONFIG_APPEND_LIBS(${PROJECT_NAME})
  ADD_LIBRARY(${MODULE_NAME} SHARED ${KINEO_ADDON_SOURCES})
  SET_TARGET_PROPERTIES(${MODULE_NAME} PROPERTIES
    SOVERSION ${PROJECT_VERSION}
    INSTALL_RPATH ${ADDON_INSTALLDIR}
    )
  ADD_CUSTOM_COMMAND(OUTPUT ${ADDON_INSTALLDIR}/lib${MODULE_NAME}.kab
    DEPEND ${ADDON_INSTALLDIR}/lib${MODULE_NAME}.so
    COMMAND KineoAddonBuilder ARGS
    -m ${CMAKE_INSTALL_PREFIX}/${ADDON_INSTALLDIR}/lib${MODULE_NAME}.so)
  ADD_CUSTOM_TARGET(license
    DEPENDS ${ADDON_INSTALLDIR}/lib${MODULE_NAME}.kab)
  ADD_DEPENDENCIES(license
    ${CMAKE_INSTALL_PREFIX}/${ADDON_INSTALLDIR}/lib${MODULE_NAME}.so)
  INSTALL(TARGETS ${MODULE_NAME} DESTINATION ${ADDON_INSTALLDIR})
ENDMACRO()
