# Copyright (C) 2008-2014 LAAS-CNRS, JRL AIST-CNRS.
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

# OMNIIDL_INCLUDE_DIRECTORIES
# ---------------------------
#
# Set include directories for omniidl
#
# DIRECTORIES: a list of directories to search for idl files.
#
MACRO (OMNIIDL_INCLUDE_DIRECTORIES)
  SET (_OMNIIDL_INCLUDE_FLAG "")
  FOREACH (DIR ${ARGV})
    SET (_OMNIIDL_INCLUDE_FLAG ${_OMNIIDL_INCLUDE_FLAG}
      -I${DIR} " "
      )
  ENDFOREACH ()
  STRING (REGEX REPLACE " " ";" _OMNIIDL_INCLUDE_FLAG ${_OMNIIDL_INCLUDE_FLAG})
ENDMACRO ()

# GENERATE_IDL_CPP FILENAME DIRECTORY
# ------------------------------------
#
# Generate C++ stubs from an idl file.
# An include directory can also be specified.
#
# FILENAME : IDL filename without the extension
#            Can be prefixed by a path: _path/_filename
# DIRECTORY : IDL directory
#             The idl file being search for is: ${DIRECTORY}/${_filename}.idl
#
MACRO(GENERATE_IDL_CPP FILENAME DIRECTORY)
  GET_FILENAME_COMPONENT (_PATH ${FILENAME} PATH)
  GET_FILENAME_COMPONENT (_NAME ${FILENAME} NAME)
  IF (_PATH STREQUAL "")
    SET(_PATH "./")
  ENDIF (_PATH STREQUAL "")
  FIND_PROGRAM(OMNIIDL omniidl)
  IF(${OMNIIDL} STREQUAL OMNIIDL-NOTFOUND)
    MESSAGE(FATAL_ERROR "cannot find omniidl.")
  ENDIF(${OMNIIDL} STREQUAL OMNIIDL-NOTFOUND)

  LIST(APPEND IDL_COMPILED_FILES ${FILENAME}SK.cc ${FILENAME}.hh)
  ADD_CUSTOM_COMMAND(
    OUTPUT ${IDL_COMPILED_FILES}
    COMMAND ${OMNIIDL}
    ARGS -bcxx -Wbkeep_inc_path ${_OMNIIDL_INCLUDE_FLAG}
    -C${_PATH} ${DIRECTORY}/${_NAME}.idl
    MAIN_DEPENDENCY ${DIRECTORY}/${_NAME}.idl
    COMMENT "Compiling C++ stubs for ${_NAME}"
    )

  SET(ALL_IDL_CPP_STUBS ${IDL_COMPILED_FILES} ${ALL_IDL_CPP_STUBS})

  # Clean generated files.
  SET_PROPERTY(
    DIRECTORY APPEND PROPERTY
    ADDITIONAL_MAKE_CLEAN_FILES
    ${IDL_COMPILED_FILES}
    )

  LIST(APPEND LOGGING_WATCHED_VARIABLES OMNIIDL ALL_IDL_CPP_STUBS)
ENDMACRO(GENERATE_IDL_CPP FILENAME DIRECTORY)

# GENERATE_IDL_PYTHON FILENAME DIRECTORY
# ------------------------------------
#
# Generate Python stubs from an idl file.
# An include directory can also be specified.
#
# FILENAME : IDL filename without the extension
#            Can be prefixed by a path: _path/_filename
# DIRECTORY : IDL directory
#             The idl file being search for is: ${DIRECTORY}/${_filename}.idl
#
MACRO(GENERATE_IDL_PYTHON FILENAME DIRECTORY)
  GET_FILENAME_COMPONENT (_PATH ${FILENAME} PATH)
  GET_FILENAME_COMPONENT (_NAME ${FILENAME} NAME)
  IF (_PATH STREQUAL "")
    SET(_PATH "./")
  ENDIF (_PATH STREQUAL "")
  FIND_PROGRAM(OMNIIDL omniidl)
  IF(${OMNIIDL} STREQUAL OMNIIDL-NOTFOUND)
    MESSAGE(FATAL_ERROR "cannot find omniidl.")
  ENDIF(${OMNIIDL} STREQUAL OMNIIDL-NOTFOUND)
  ADD_CUSTOM_COMMAND(
    OUTPUT ${FILENAME}_idl.py
    COMMAND ${OMNIIDL}
    ARGS -bpython ${_OMNIIDL_INCLUDE_FLAG}
    -C${_PATH} ${DIRECTORY}/${_NAME}.idl
    MAIN_DEPENDENCY ${DIRECTORY}/${_NAME}.idl
    COMMENT "Compiling Python stubs for ${_NAME}"
    )
  SET(ALL_IDL_PYTHON_STUBS ${FILENAME}_idl.py ${ALL_IDL_PYTHON_STUBS})

  # Clean generated files.
  SET_PROPERTY(
    DIRECTORY APPEND PROPERTY
    ADDITIONAL_MAKE_CLEAN_FILES
    ${FILENAME}_idl.py
    )

  LIST(APPEND LOGGING_WATCHED_VARIABLES OMNIIDL ALL_IDL_PYTHON_STUBS)
ENDMACRO(GENERATE_IDL_PYTHON FILENAME DIRECTORY)

# GENERATE_IDL_FILE FILENAME DIRECTORY
# ------------------------------------
#
# Generate C++ stubs from an idl file (legacy macro).
# An include directory can also be specified.
#
# FILENAME : IDL filename without the extension
#            Can be prefixed by a path: _path/_filename
# DIRECTORY : IDL directory
#             The idl file being search for is: ${DIRECTORY}/${_filename}.idl
#
MACRO(GENERATE_IDL_FILE FILENAME DIRECTORY)
  GENERATE_IDL_CPP(${FILENAME} ${DIRECTORY})
ENDMACRO(GENERATE_IDL_FILE FILENAME DIRECTORY)
