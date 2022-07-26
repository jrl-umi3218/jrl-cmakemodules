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

# GENERATE_IDL_FILE FILENAME DIRECTORY
# ------------------------------------
#
# Generate stubs from an idl file. An include directory can also be specified.
#
# FILENAME : IDL filename without the extension DIRECTORY : IDL directory
# LIST_INCLUDE_DIRECTORIES (optional) : List of include directories
#
macro(GENERATE_IDLRTC_FILE FILENAME DIRECTORY)
  find_program(OMNIIDL omniidl)

  # Test existence of omniidl
  if(${OMNIIDL} STREQUAL OMNIIDL-NOTFOUND)
    message(FATAL_ERROR "cannot find omniidl.")
  endif(${OMNIIDL} STREQUAL OMNIIDL-NOTFOUND)

  # Create the flag to include directories
  set(OMNIIDL_INC_DIR "")

  # Check if there is an optional value
  message(STATUS "ARGC: "${ARGC})
  if(${ARGC} EQUAL 3)
    # If there is, the directory to include are added.
    set(LIST_INCLUDE_DIRECTORIES ${ARGV2})

    message(STATUS "ARGV2: "${ARGV2})
    foreach(INCDIR ${LIST_INCLUDE_DIRECTORIES})
      # The format for the first one is special to avoid a \ to be introduced.
      if(OMNIIDL_INC_DIR STREQUAL "")
        set(OMNIIDL_INC_DIR "-I${INCDIR}")
      else(OMNIIDL_INC_DIR STREQUAL "")
        set(OMNIIDL_INC_DIR ${OMNIIDL_INC_DIR} "-I${INCDIR}")
      endif(OMNIIDL_INC_DIR STREQUAL "")
    endforeach(INCDIR ${LIST_INCLUDE_DIRECTORIES})

  endif(${ARGC} EQUAL 3)

  set(IDL_FLAGS "-Wbuse_quotes" "-Wbh=.hh" "-Wbs=SK.cc" "-Wba" "-Wbd=DynSK.cc")
  message(STATUS "OMNIIDL_INC_DIR:" ${OMNIIDL_INC_DIR})
  add_custom_command(
    OUTPUT ${FILENAME}SK.cc ${FILENAME}DynSK.cc ${FILENAME}.hh
    COMMAND ${OMNIIDL} ARGS -bcxx ${IDL_FLAGS} ${OMNIIDL_INC_DIR}
            ${DIRECTORY}/${FILENAME}.idl
    MAIN_DEPENDENCY ${DIRECTORY}/${FILENAME}.idl)
  set(ALL_IDL_STUBS ${FILENAME}SK.cc ${FILENAME}DynSK.cc ${FILENAME}.hh
                    ${ALL_IDL_STUBS})

  # Clean generated files.
  set_property(
    DIRECTORY
    APPEND
    PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${FILENAME}SK.cc ${FILENAME}DynSK.cc
             ${FILENAME}.hh)

  list(APPEND LOGGING_WATCHED_VARIABLES OMNIIDL ALL_IDL_STUBS)
endmacro(
  GENERATE_IDLRTC_FILE
  FILENAME
  DIRECTORY)
