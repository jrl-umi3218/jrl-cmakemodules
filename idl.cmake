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

# GENERATE_IDL_FILE FILENAME DIRECTORY
# ------------------------------------
#
# Generate stubs from an idl file.
# An include directory can also be specified.
#
# FILENAME : IDL filename without the extension
# DIRECTORY : IDL directory
#
MACRO(GENERATE_IDL_FILE FILENAME DIRECTORY)
  FIND_PROGRAM(OMNIIDL omniidl)
  ADD_CUSTOM_COMMAND(
    OUTPUT ${FILENAME}SK.cc ${FILENAME}.hh
    COMMAND ${OMNIIDL}
    ARGS -bcxx ${DIRECTORY}/${FILENAME}.idl
    MAIN_DEPENDENCY ${DIRECTORY}/${FILENAME}.idl
    )
  SET(ALL_IDL_STUBS ${FILENAME}SK.cc ${FILENAME}.hh ${ALL_IDL_STUBS})

  # Clean generated files.
  SET_PROPERTY(
    DIRECTORY APPEND PROPERTY
    ADDITIONAL_MAKE_CLEAN_FILES
    ${FILENAME}SK.cc ${FILENAME}.hh
    )
ENDMACRO(GENERATE_IDL_FILE FILENAME DIRECTORY)
