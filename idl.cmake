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

# .rst: .. command:: OMNIIDL_INCLUDE_DIRECTORIES (DIRECTORIES)
#
# Set include directories for omniidl
#
# :param DIRECTORIES: a list of directories to search for idl files.
#
macro(OMNIIDL_INCLUDE_DIRECTORIES)
  set(_OMNIIDL_INCLUDE_FLAG "")
  foreach(DIR ${ARGV})
    set(_OMNIIDL_INCLUDE_FLAG ${_OMNIIDL_INCLUDE_FLAG} -I${DIR} " ")
  endforeach()
  string(REGEX REPLACE " " ";" _OMNIIDL_INCLUDE_FLAG ${_OMNIIDL_INCLUDE_FLAG})
endmacro()

# .rst: .. command:: GENERATE_IDL_CPP (FILENAME DIRECTORY)
#
# Generate C++ stubs from an idl file. An include directory can also be
# specified. The filename of the generated file is appended to
# ``ALL_IDL_CPP_STUBS``.
#
# In CMake, *source file properties are visible only to targets added in the
# same directory (CMakeLists.txt)*. As a result, we cannot provide a single
# macro that takes care of generating the files and ensures a proper build
# dependency graph.
#
# .. warning:: It is your responsibility to make sure the target dependency tree
# is correct. For instance with::
#
# ADD_CUSTOM_TARGET(generate_idl_cpp DEPENDS ${ALL_IDL_CPP_STUBS})
# ADD_DEPENDENCIES (my-library generate_idl_cpp)
#
# For more information:
# http://www.cmake.org/Wiki/CMake_FAQ#How_can_I_add_a_dependency_to_a_source_file_which_is_generated_in_a_subdirectory.3F
#
# :param FILENAME:   IDL filename without the extension. Can be prefixed by a
# path: _path/_filename :param DIRECTORY:  IDL directory. The idl file being
# search for is: ``${DIRECTORY}/${_filename}.idl`` :param ENABLE_Wba: Option to
# trigger generation of code for TypeCode and Any. :param HEADER_SUFFIX: Set
# option -Wbh of omniidl :param NO_DEFAULT: Do not add default arguments to
# omniidl (``-Wbkeep_inc_path``) :param ARGUMENTS:  The following words are
# passed as arguments to omniidl
#
macro(GENERATE_IDL_CPP FILENAME DIRECTORY)
  set(options ENABLE_Wba NO_DEFAULT)
  set(oneValueArgs HEADER_SUFFIX)
  set(multiValueArgs ARGUMENTS)
  cmake_parse_arguments(_omni "${options}" "${oneValueArgs}"
                        "${multiValueArgs}" ${ARGN})
  if(NOT DEFINED _omni_HEADER_SUFFIX)
    set(_omni_HEADER_SUFFIX ".hh")
  endif()

  get_filename_component(_PATH ${FILENAME} PATH)
  get_filename_component(_NAME ${FILENAME} NAME)
  if(_PATH STREQUAL "")
    set(_PATH "./")
  endif(_PATH STREQUAL "")
  find_program(OMNIIDL omniidl)
  if(${OMNIIDL} STREQUAL OMNIIDL-NOTFOUND)
    message(FATAL_ERROR "cannot find omniidl.")
  endif(${OMNIIDL} STREQUAL OMNIIDL-NOTFOUND)

  set(IDL_COMPILED_FILES ${FILENAME}SK.cc ${FILENAME}${_omni_HEADER_SUFFIX})
  set(_omniidl_args -bcxx ${_OMNIIDL_INCLUDE_FLAG} -Wbh=${_omni_HEADER_SUFFIX}
                    ${_omni_ARGUMENTS})
  # This is to keep backward compatibility
  if(NOT _omni_NO_DEFAULT)
    set(_omniidl_args ${_omniidl_args} -Wbkeep_inc_path)
  endif()
  if(_omni_ENABLE_Wba)
    set(_omniidl_args ${_omniidl_args} -Wba)
    set(IDL_COMPILED_FILES ${IDL_COMPILED_FILES} ${FILENAME}DynSK.cc)
  endif(_omni_ENABLE_Wba)
  add_custom_command(
    OUTPUT ${IDL_COMPILED_FILES}
    COMMAND ${OMNIIDL} ARGS ${_omniidl_args} -C${_PATH}
            ${DIRECTORY}/${_NAME}.idl
    MAIN_DEPENDENCY ${DIRECTORY}/${_NAME}.idl
    COMMENT "Generating C++ stubs for ${_NAME}")

  list(APPEND ALL_IDL_CPP_STUBS ${IDL_COMPILED_FILES})

  # Clean generated files.
  set_property(
    DIRECTORY
    APPEND
    PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${IDL_COMPILED_FILES})
  set_property(
    SOURCE ${IDL_COMPILED_FILES}
    APPEND_STRING
    PROPERTY
      COMPILE_FLAGS
      "-Wno-conversion -Wno-cast-qual -Wno-unused-variable -Wno-unused-parameter"
  )

  list(APPEND LOGGING_WATCHED_VARIABLES OMNIIDL ALL_IDL_CPP_STUBS)
endmacro(
  GENERATE_IDL_CPP
  FILENAME
  DIRECTORY)

# .rst: .. command:: GENERATE_IDL_PYTHON (FILENAME DIRECTORY)
#
# Generate Python stubs from an idl file. An include directory can also be
# specified. The filename of the generated file is appended to
# ``ALL_IDL_PYTHON_STUBS``.
#
# In CMake, *source file properties are visible only to targets added in the
# same directory (CMakeLists.txt)*. As a result, we cannot provide a single
# macro that takes care of generating the files and ensures a proper build
# dependency graph.
#
# .. warning:: It is your responsibility to make sure the target dependency tree
# is correct. For instance with::
#
# ADD_CUSTOM_TARGET(generate_idl_python DEPENDS ${ALL_IDL_PYTHON_STUBS})
# ADD_DEPENDENCIES (my-library generate_idl_python)
#
# For more information:
# http://www.cmake.org/Wiki/CMake_FAQ#How_can_I_add_a_dependency_to_a_source_file_which_is_generated_in_a_subdirectory.3F
#
# :param FILENAME: IDL filename without the extension. Can be prefixed by a
# path: _path/_filename :param DIRECTORY: IDL directory. The idl file being
# search for is: ``${DIRECTORY}/${_filename}.idl`` :param ARGUMENTS:  The
# following words are passed as arguments to omniidl :param ENABLE_DOCSTRING:
# generate docstrings from doxygen comments (only in Python 3) :param STUBS: set
# option -Wbstubs of omniidl.
#
macro(GENERATE_IDL_PYTHON FILENAME DIRECTORY)
  set(options ENABLE_DOCSTRING)
  set(oneValueArgs STUBS)
  set(multiValueArgs ARGUMENTS)
  cmake_parse_arguments(_omni "${options}" "${oneValueArgs}"
                        "${multiValueArgs}" ${ARGN})

  get_filename_component(_PATH ${FILENAME} PATH)
  get_filename_component(_NAME ${FILENAME} NAME)
  if(_PATH STREQUAL "")
    set(_PATH "./")
  endif(_PATH STREQUAL "")
  find_program(OMNIIDL omniidl)
  if(${OMNIIDL} STREQUAL OMNIIDL-NOTFOUND)
    message(FATAL_ERROR "cannot find omniidl.")
  endif(${OMNIIDL} STREQUAL OMNIIDL-NOTFOUND)

  if(_omni_ENABLE_DOCSTRING AND PYTHON_VERSION_MAJOR EQUAL 3)
    set(_omniidl_args -p${PROJECT_JRL_CMAKE_MODULE_DIR}/hpp/idl
                      -bomniidl_be_python_with_docstring -K)
  else()
    set(_omniidl_args -bpython)
  endif()
  set(_omniidl_args ${_omniidl_args} ${_OMNIIDL_INCLUDE_FLAG} -C${_PATH}
                    ${_omni_ARGUMENTS})
  if(DEFINED _omni_STUBS)
    set(_omniidl_args ${_omniidl_args} -Wbstubs=${_omni_STUBS})
    string(REPLACE "." "/" _omni_STUBS_DIR ${_omni_STUBS})
  endif()
  set(output_files
      ${CMAKE_CURRENT_BINARY_DIR}/${_PATH}/${_omni_STUBS_DIR}/${FILENAME}_idl.py
  )

  add_custom_command(
    OUTPUT ${output_files}
    COMMAND ${OMNIIDL} ARGS ${_omniidl_args} ${DIRECTORY}/${_NAME}.idl
    MAIN_DEPENDENCY ${DIRECTORY}/${_NAME}.idl
    COMMENT "Generating Python stubs for ${_NAME}")

  list(APPEND ALL_IDL_PYTHON_STUBS ${output_files})

  # Clean generated files.
  set_property(
    DIRECTORY
    APPEND
    PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${output_files})

  list(APPEND LOGGING_WATCHED_VARIABLES OMNIIDL ALL_IDL_PYTHON_STUBS)
endmacro(
  GENERATE_IDL_PYTHON
  FILENAME
  DIRECTORY)

# GENERATE_IDL_FILE FILENAME DIRECTORY
# ------------------------------------
#
# Legacy macro, now replaced by GENERATE_IDL_CPP.
macro(GENERATE_IDL_FILE FILENAME DIRECTORY)
  message(
    FATAL_ERROR
      "GENERATE_IDL_FILE has been removed. Please use GENERATE_IDL_CPP instead."
  )
endmacro(
  GENERATE_IDL_FILE
  FILENAME
  DIRECTORY)
