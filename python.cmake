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


MACRO(FINDPYTHON)
INCLUDE(FindPythonLibs)
IF (NOT ${PYTHONLIBS_FOUND} STREQUAL TRUE)
   MESSAGE(FATAL_ERROR "Python has not been found.")
ENDIF (NOT ${PYTHONLIBS_FOUND} STREQUAL TRUE)

INCLUDE(FindPythonInterp)
IF (NOT ${PYTHONINTERP_FOUND} STREQUAL TRUE)
   MESSAGE(FATAL_ERROR "Python executable has not been found.")
ENDIF (NOT ${PYTHONINTERP_FOUND} STREQUAL TRUE)

# Find PYTHON_LIBRARY_DIRS
GET_FILENAME_COMPONENT(PYTHON_LIBRARY_DIRS ${PYTHON_LIBRARIES} PATH)

EXEC_PROGRAM(${PYTHON_EXECUTABLE} 
  ARGS "-c \"import sys, os; print os.sep.join(['lib', 'python' + sys.version[:3], 'site-packages'])\""
  OUTPUT_VARIABLE PYTHON_SITELIB)
ENDMACRO(FINDPYTHON)


#
# DYNAMIC_GRAPH_PYTHON_MODULE SUBMODULENAME LIBRARYNAME TARGETNAME
# ---------------------------
#
# Add a python submodule to dynamic_graph
#
#  SUBMODULENAME : the name of the submodule (can be foo/bar),
#
#  LIBRARYNAME   : library to link the submodule with.
#
#  TARGETNAME    : name of the target: should be different for several
#                  calls to the macro.
#
#  NOTICE : Before calling this macro, set variable NEW_ENTITY_CLASS as
#           the list of new Entity types that you want to be bound.
#           Entity class name should match the name referencing the type
#           in the factory.
#
MACRO(DYNAMIC_GRAPH_PYTHON_MODULE SUBMODULENAME LIBRARYNAME TARGETNAME)
  FINDPYTHON()

  SET(PYTHON_MODULE ${TARGETNAME})

  ADD_LIBRARY(${PYTHON_MODULE}
    MODULE
    ${jrl-cmake_DIR}/dynamic_graph/python-module-py.cc)

  FILE(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/src/dynamic_graph/${SUBMODULENAME})
  SET_TARGET_PROPERTIES(${PYTHON_MODULE}
    PROPERTIES PREFIX ""
    OUTPUT_NAME dynamic_graph/${SUBMODULENAME}/wrap
   )

  TARGET_LINK_LIBRARIES(${PYTHON_MODULE} ${LIBRARYNAME} ${PYTHON_LIBRARY})

  INCLUDE_DIRECTORIES(${PYTHON_INCLUDE_PATH})

  #
  # Installation
  #
  SET(PYTHON_INSTALL_DIR ${PYTHON_SITELIB}/dynamic_graph/${SUBMODULENAME})

  INSTALL(TARGETS ${PYTHON_MODULE}
    DESTINATION
    ${PYTHON_INSTALL_DIR})

  SET(ENTITY_CLASS_LIST "")
  FOREACH (ENTITY ${NEW_ENTITY_CLASS})
    SET(ENTITY_CLASS_LIST "${ENTITY_CLASS_LIST}${ENTITY}('')\n")
  ENDFOREACH(ENTITY ${NEW_ENTITY_CLASS})

  CONFIGURE_FILE(
    ${jrl-cmake_DIR}/dynamic_graph/submodule/__init__.py.cmake
    ${CMAKE_BINARY_DIR}/src/dynamic_graph/${SUBMODULENAME}/__init__.py
    )

  INSTALL(
    FILES ${CMAKE_BINARY_DIR}/src/dynamic_graph/${SUBMODULENAME}/__init__.py
    DESTINATION ${PYTHON_INSTALL_DIR}
    )

ENDMACRO(DYNAMIC_GRAPH_PYTHON_MODULE SUBMODULENAME)


# PYTHON_INSTALL(MODULE FILE DEST)
# --------------------------------
#
# Install a Python file and its associated compiled version.
#
MACRO(PYTHON_INSTALL MODULE FILE DEST)

  FILE(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${MODULE}")

  INSTALL(CODE
    "EXEC_PROGRAM(
    \"${PYTHON_EXECUTABLE}\" ARGS
    \"${jrl-cmake_DIR}/compile.py\"
    \"${CMAKE_CURRENT_SOURCE_DIR}\"
    \"${CMAKE_CURRENT_BINARY_DIR}\"
    \"${MODULE}/${FILE}\")
    ")

  # Tag pyc file as generated.
  SET_SOURCE_FILES_PROPERTIES(
    "${CMAKE_CURRENT_BINARY_DIR}/${MODULE}/${FILE}c"
    PROPERTIES GENERATED TRUE)

  # Clean generated files.
  SET_PROPERTY(
    DIRECTORY APPEND PROPERTY
    ADDITIONAL_MAKE_CLEAN_FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${MODULE}/${FILE}c"
    )

  INSTALL(FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/${MODULE}/${FILE}"
    "${CMAKE_CURRENT_BINARY_DIR}/${MODULE}/${FILE}c"
    DESTINATION "${DEST}/${MODULE}")
ENDMACRO()

# PYTHON_INSTALL_ON_SITE (MODULE FILE)
# --------------------------------
#
# Install a Python file and its associated compiled version.
#
MACRO(PYTHON_INSTALL_ON_SITE MODULE FILE)

  FINDPYTHON()
  PYTHON_INSTALL(${MODULE} ${FILE} ${PYTHON_SITELIB})

ENDMACRO()

# PYTHON_INSTALL_BUILD(MODULE FILE DEST)
# --------------------------------------
#
# Install a Python file residing in the build directory and its
# associated compiled version.
#
MACRO(PYTHON_INSTALL_BUILD MODULE FILE DEST)

  FILE(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${MODULE}")

  INSTALL(CODE
    "EXEC_PROGRAM(
    \"${PYTHON_EXECUTABLE}\" ARGS
    \"${jrl-cmake_DIR}/compile.py\"
    \"${CMAKE_CURRENT_BINARY_DIR}\"
    \"${CMAKE_CURRENT_BINARY_DIR}\"
    \"${MODULE}/${FILE}\")
    ")

  # Tag pyc file as generated.
  SET_SOURCE_FILES_PROPERTIES(
    "${CMAKE_CURRENT_BINARY_DIR}/${MODULE}/${FILE}c"
    PROPERTIES GENERATED TRUE)

  # Clean generated files.
  SET_PROPERTY(
    DIRECTORY APPEND PROPERTY
    ADDITIONAL_MAKE_CLEAN_FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${MODULE}/${FILE}c"
    )

  INSTALL(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${MODULE}/${FILE}"
    "${CMAKE_CURRENT_BINARY_DIR}/${MODULE}/${FILE}c"
    DESTINATION "${DEST}/${MODULE}")
ENDMACRO()
