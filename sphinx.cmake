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

# SPHINX_SETUP()
# --------------
#
# Look for Sphinx, add a custom rule to generate the documentation and install
# the documentation properly.
#
macro(SPHINX_SETUP)
  set(SPHINX_BUILD_PATH "")

  # With MSVC, it is likely thant sphinx has been installed using easy-install
  # directly in the python folder.
  if(MSVC)
    get_filename_component(PYTHON_ROOT ${PYTHON_EXECUTABLE} DIRECTORY)
    set(SPHINX_BUILD_PATH ${PYTHON_ROOT}/Scripts)
  endif(MSVC)

  find_program(
    SPHINX_BUILD sphinx-build
    DOC "Sphinx documentation generator tool"
    PATHS "${SPHINX_BUILD_PATH}")

  if(NOT SPHINX_BUILD)
    message(
      WARNING "Failed to find sphinx, documentation will not be generated.")
  else(NOT SPHINX_BUILD)

    if(MSVC)
      # FIXME: it is impossible to trigger documentation installation at
      # install, so put the target in ALL instead.
      add_custom_target(
        sphinx-doc ALL
        COMMAND
          ${PYTHON_EXECUTABLE} ${SPHINX_BUILD} -b html
          ${CMAKE_CURRENT_BINARY_DIR}/sphinx
          ${CMAKE_CURRENT_BINARY_DIR}/sphinx-html
        COMMENT "Generating sphinx documentation")
    elseif(APPLE)
      # THE DYLD_LIBRARY_PATH should be completed to run the sphinx command.
      # otherwise some symbols won't be found.
      set(EXTRA_LD_PATH "\"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}\":")
      set(EXTRA_LD_PATH "${EXTRA_LD_PATH}\"${DYNAMIC_GRAPH_PLUGINDIR}\":")
      add_custom_target(
        sphinx-doc
        COMMAND
          export DYLD_LIBRARY_PATH=${EXTRA_LD_PATH}:\$DYLD_LIBRARY_PATH \;
          ${PYTHON_EXECUTABLE} ${SPHINX_BUILD} -b html
          ${CMAKE_CURRENT_BINARY_DIR}/sphinx
          ${CMAKE_CURRENT_BINARY_DIR}/sphinx-html
        COMMENT "Generating sphinx documentation")

      if(INSTALL_DOCUMENTATION)
        install(
          CODE "EXECUTE_PROCESS(COMMAND ${CMAKE_MAKE_PROGRAM} sphinx-doc)")
      endif(INSTALL_DOCUMENTATION)
    else() # UNIX
      # THE LD_LIBRARY_PATH should be completed to run the sphinx command.
      # otherwise some symbols won't be found.
      set(EXTRA_LD_PATH "\"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}\":")
      set(EXTRA_LD_PATH "${EXTRA_LD_PATH}\"${DYNAMIC_GRAPH_PLUGINDIR}\":")
      add_custom_target(
        sphinx-doc
        COMMAND
          export LD_LIBRARY_PATH=${EXTRA_LD_PATH}:$$LD_LIBRARY_PATH \;
          ${PYTHON_EXECUTABLE} ${SPHINX_BUILD} -b html
          ${CMAKE_CURRENT_BINARY_DIR}/sphinx
          ${CMAKE_CURRENT_BINARY_DIR}/sphinx-html
        COMMENT "Generating sphinx documentation")

      if(INSTALL_DOCUMENTATION)
        install(
          CODE "EXECUTE_PROCESS(COMMAND ${CMAKE_MAKE_PROGRAM} sphinx-doc)")
      endif(INSTALL_DOCUMENTATION)
    endif(MSVC)

    add_custom_command(
      OUTPUT ${CMAKE_BINARY_DIR}/doc/sphinx-html
      COMMAND
        ${PYTHON_EXECUTABLE} ${SPHINX_BUILD} -b html
        ${CMAKE_CURRENT_BINARY_DIR}/sphinx
        ${CMAKE_CURRENT_BINARY_DIR}/sphinx-html
      COMMENT "Generating sphinx documentation")

    # Clean generated files.
    set_property(
      DIRECTORY
      APPEND
      PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${CMAKE_BINARY_DIR}/doc/sphinx-html)

    # Install generated files.
    if(INSTALL_DOCUMENTATION)
      install(DIRECTORY ${CMAKE_BINARY_DIR}/doc/sphinx-html
              DESTINATION share/doc/${PROJECT_NAME})

      if(EXISTS ${PROJECT_SOURCE_DIR}/doc/pictures)
        install(DIRECTORY ${PROJECT_SOURCE_DIR}/doc/pictures
                DESTINATION share/doc/${PROJECT_NAME}/sphinx-html)
      endif(EXISTS ${PROJECT_SOURCE_DIR}/doc/pictures)
    endif(INSTALL_DOCUMENTATION)

  endif(NOT SPHINX_BUILD)

  list(APPEND LOGGING_WATCHED_VARIABLES SPHINX_BUILD)
endmacro(SPHINX_SETUP)

# SPHINX_FINALIZE()
# -----------------
#
# Generate Sphinx related files.
#
macro(SPHINX_FINALIZE)
  if(SPHINX_BUILD)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/sphinx/index.rst.in
                   ${CMAKE_CURRENT_BINARY_DIR}/sphinx/index.rst @ONLY)

    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/sphinx/conf.py.in
                   ${CMAKE_CURRENT_BINARY_DIR}/sphinx/conf.py @ONLY)
  endif(SPHINX_BUILD)
endmacro(SPHINX_FINALIZE)
