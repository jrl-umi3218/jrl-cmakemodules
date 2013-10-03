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

# SPHINX_SETUP()
# --------------
#
# Look for Sphinx, add a custom rule to generate the documentation and
# install the documentation properly.
#
MACRO(SPHINX_SETUP)
  FIND_PROGRAM(SPHINX_BUILD sphinx-build DOC
    "Sphinx documentation generator tool")
  IF (NOT SPHINX_BUILD)
    MESSAGE(FATAL_ERROR "Failed to find sphinx")
  ENDIF(NOT SPHINX_BUILD)

  IF(UNIX)
    SET(MAKE make)
  ELSEIF(WIN32)
    SET(MAKE nmake)
  ELSE(UNIX)
    MESSAGE(FATAL_ERROR
      "sphinx documentation generation not supported on this platform.")
  ENDIF(UNIX)

  IF(MSVC)
    # FIXME: it is impossible to trigger documentation installation
    # at install, so put the target in ALL instead.
    ADD_CUSTOM_TARGET(sphinx-doc ALL
      COMMAND ${SPHINX_BUILD} -b html ${CMAKE_CURRENT_BINARY_DIR}/sphinx
      ${CMAKE_CURRENT_BINARY_DIR}/sphinx-html
      COMMENT "Generating sphinx documentation"
      )
  ELIF(APPLE)
    # THE DYLD_LIBRARY_PATH should be completed to run the sphinx command.
    #  otherwise some symbols won't be found.
    SET(EXTRA_LD_PATH "\"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}\":")
    SET(EXTRA_LD_PATH "${EXTRA_LD_PATH}\"${DYNAMIC_GRAPH_PLUGINDIR}\":")
    ADD_CUSTOM_TARGET(sphinx-doc
      COMMAND  export DYLD_LIBRARY_PATH=${EXTRA_LD_PATH}:\$DYLD_LIBRARY_PATH \;
      ${SPHINX_BUILD} -b html ${CMAKE_CURRENT_BINARY_DIR}/sphinx
      ${CMAKE_CURRENT_BINARY_DIR}/sphinx-html
      COMMENT "Generating sphinx documentation"
      )

    INSTALL(CODE "EXECUTE_PROCESS(COMMAND ${MAKE} sphinx-doc)")
  ELSE() #UNIX
    # THE LD_LIBRARY_PATH should be completed to run the sphinx command.
    #  otherwise some symbols won't be found.
    SET(EXTRA_LD_PATH "\"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}\":")
    SET(EXTRA_LD_PATH "${EXTRA_LD_PATH}\"${DYNAMIC_GRAPH_PLUGINDIR}\":")
    ADD_CUSTOM_TARGET(sphinx-doc
      COMMAND  export LD_LIBRARY_PATH=${EXTRA_LD_PATH}:\$LD_LIBRARY_PATH \;
      ${SPHINX_BUILD} -b html ${CMAKE_CURRENT_BINARY_DIR}/sphinx
      ${CMAKE_CURRENT_BINARY_DIR}/sphinx-html
      COMMENT "Generating sphinx documentation"
      )

    INSTALL(CODE "EXECUTE_PROCESS(COMMAND ${MAKE} sphinx-doc)")
  ENDIF(MSVC)

  ADD_CUSTOM_COMMAND(
    OUTPUT
    ${CMAKE_BINARY_DIR}/doc/sphinx-html
    COMMAND ${SPHINX_BUILD} -b html  ${CMAKE_CURRENT_BINARY_DIR}/sphinx
      ${CMAKE_CURRENT_BINARY_DIR}/sphinx-html
    COMMENT "Generating sphinx documentation"
    )

  # Clean generated files.
  SET_PROPERTY(
    DIRECTORY APPEND PROPERTY
    ADDITIONAL_MAKE_CLEAN_FILES
    ${CMAKE_BINARY_DIR}/doc/sphinx-html
    )

  # Install generated files.
  INSTALL(DIRECTORY ${CMAKE_BINARY_DIR}/doc/sphinx-html
    DESTINATION share/doc/${PROJECT_NAME})

  IF(EXISTS ${CMAKE_SOURCE_DIR}/doc/pictures)
    INSTALL(DIRECTORY ${CMAKE_SOURCE_DIR}/doc/pictures
      DESTINATION share/doc/${PROJECT_NAME}/sphinx-html)
  ENDIF(EXISTS ${CMAKE_SOURCE_DIR}/doc/pictures)

  LIST(APPEND LOGGING_WATCHED_VARIABLES
    SPHINX_BUILD
    )
ENDMACRO(SPHINX_SETUP)


# SPHINX_FINALIZE()
# -----------------
#
# Generate Sphinx related files.
#
MACRO(SPHINX_FINALIZE)
  CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/sphinx/index.rst.in
    ${CMAKE_CURRENT_BINARY_DIR}/sphinx/index.rst
    @ONLY
    )

  CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/sphinx/conf.py.in
    ${CMAKE_CURRENT_BINARY_DIR}/sphinx/conf.py
    @ONLY
    )
ENDMACRO(SPHINX_FINALIZE)
