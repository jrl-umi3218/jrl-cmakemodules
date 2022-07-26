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
#
# Create and install KineoPathPlanner (Kitelab) add-on modules.

# KINEO_ADDON
# -----------
#
# Build a add-on module for KineoPathPlanner
#
# MODULE_NAME             : name of the module
#
# 1. compile a shared object named lib${MODULE_NAME}.so the sources of which are
#    defined by (global) variable KINEO_ADDON_SOURCES,
# 2. install this shared object in lib/modules/${UNAME_N} where ${UNAME_N} is the
#    result of command "uname -n": the name of the machine,
# 3. generate a target named "license" that creates the required .kab file. Note
#    that you must be in possession of a valid kineo license file.
#
# Before calling this macro, it is recommended to reset variable PKG_CONFIG_LIBS
# to the empty string since the right directory is appended to the "libs:" field
# of the .pc file by the macro.
#
macro(KINEO_ADDON MODULE_NAME)
  execute_process(
    COMMAND "uname" "-n"
    OUTPUT_VARIABLE UNAME_N
    ERROR_QUIET)
  string(REPLACE "\n" "" UNAME_N "${UNAME_N}")

  set(ADDON_INSTALLDIR lib/modules/${UNAME_N})
  pkg_config_append_library_dir(${CMAKE_INSTALL_PREFIX}/${ADDON_INSTALLDIR})
  pkg_config_append_libs(${PROJECT_NAME})
  add_library(${MODULE_NAME} SHARED ${KINEO_ADDON_SOURCES})
  set_target_properties(
    ${MODULE_NAME} PROPERTIES SOVERSION ${PROJECT_VERSION} INSTALL_RPATH
                                                           ${ADDON_INSTALLDIR})
  add_custom_command(
    OUTPUT ${ADDON_INSTALLDIR}/lib${MODULE_NAME}.kab DEPEND
           ${ADDON_INSTALLDIR}/lib${MODULE_NAME}.so
    COMMAND KineoAddonBuilder ARGS -m
            ${CMAKE_INSTALL_PREFIX}/${ADDON_INSTALLDIR}/lib${MODULE_NAME}.so)
  add_custom_target(license DEPENDS ${ADDON_INSTALLDIR}/lib${MODULE_NAME}.kab)
  add_dependencies(
    license ${CMAKE_INSTALL_PREFIX}/${ADDON_INSTALLDIR}/lib${MODULE_NAME}.so)
  install(TARGETS ${MODULE_NAME} DESTINATION ${ADDON_INSTALLDIR})
endmacro()

# KINEO_STANDALONE
# ----------------
#
# Build a standalone executable for Kineo
#
# STANDALONE_NAME         : name of the executable
#
# 1. compile a kineo add-on builder file ${STANDALONE_NAME}.kab from the
#    executable ${STANDALONE_NAME},
# 2. install this .kab file in the the current build directory, i.e. at the same
#    location as the executable,
# 3. generate a target named "license" that creates the required .kab file.  Note
#    that you must be in possession of a valid kineo license file.
#
macro(KINEO_STANDALONE STANDALONE_NAME)
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${STANDALONE_NAME}.kab DEPEND
           ${CMAKE_CURRENT_BUILD_DIR}/${STANDALONE_NAME}
    COMMAND KineoAddonBuilder ARGS -a
            ${CMAKE_CURRENT_BINARY_DIR}/${STANDALONE_NAME})
  add_custom_target(${STANDALONE_NAME}-license ALL
                    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${STANDALONE_NAME}.kab)
  add_dependencies(${STANDALONE_NAME}-license
                   ${CMAKE_CURRENT_BINARY_DIR}/${STANDALONE_NAME})
endmacro()
