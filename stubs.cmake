# Copyright (C) 2021 INRIA
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

set(CURRENT_FILE_PATH ${CMAKE_CURRENT_LIST_DIR} CACHE INTERNAL "")

#.rst:
# .. command:: LOAD_STUBGEN([GIT_TAG])
#
#    GIT_TAG: the git tag of stubgen. This optional argument allows to use a precise version of stubgen (not necessarily the last master branch).
#
#    Download and configure the stub generator module.
#
MACRO(LOAD_STUBGEN)
  # Handle optional argument
  set(GIT_TAG "master")
  set(extra_macro_args ${ARGN})
  list(LENGTH extra_macro_args num_extra_args)
  if(${num_extra_args} GREATER 0)
    list(GET extra_macro_args 0 GIT_TAG)
  endif()

  # Download at configure time
  set(STUBGEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/stubgen)
  configure_file(${CURRENT_FILE_PATH}/stubgen/CMakeLists.txt.in stubgen/CMakeLists.txt)
  execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${STUBGEN_DIR})
  if(result)
    message(FATAL_ERROR "CMake step for stubgen failed: ${result}")
  endif()

  execute_process(COMMAND ${CMAKE_COMMAND} --build .
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${STUBGEN_DIR})
  if(result)
    message(FATAL_ERROR "Build step for stubgen failed: ${result}")
  endif()

  SET(STUBGEN_MAIN_FILE ${STUBGEN_DIR}/src/pybind11_stubgen/__init__.py)
ENDMACRO(LOAD_STUBGEN)

#.rst:
# .. command:: LOAD_STUBGEN(module_path module_name module_install_dir)
#
#    Generate the stubs associated to a given project.
#    If the TARGET python exists, then the stubs generation will be performed after python target.
#
#.rst:
# .. variable:: module_path
#
#  Path pointing to the module
#
#.rst:
# .. variable:: module_name
#
#  Name of the module
#
#.rst:
# .. variable:: module_install_dir
#
#  Where the module is installed
#
FUNCTION(GENERATE_STUBS module_path module_name module_install_dir)

  IF(NOT STUBGEN_MAIN_FILE)
    message(FATAL_ERROR "You need to first load the stubgen module via LOAD_STUBGEN.")
  ENDIF(NOT STUBGEN_MAIN_FILE)

  # Regex from IsValidTargetName in CMake/Source/cmGeneratorExpression.cxx
  IF(NOT module_path)
    STRING(REGEX REPLACE "[^A-Za-z0-9_.+-]" "_" target_name "generate_stubs_${module_name}")
  ELSE()
    STRING(REGEX REPLACE "[^A-Za-z0-9_.+-]" "_" target_name "generate_stubs_${module_path}_${module_name}")
  ENDIF()

  IF($ENV{PYTHONPATH})
    SET(PYTHONPATH ${module_path};$ENV{PYTHONPATH})
  ELSE()
    SET(PYTHONPATH ${module_path})
  ENDIF($ENV{PYTHONPATH})

  ADD_CUSTOM_TARGET(
    ${target_name}
    ALL
    COMMAND
    ${CMAKE_COMMAND} -E env PYTHONPATH=${PYTHONPATH}
    "${PYTHON_EXECUTABLE}"
    "${STUBGEN_MAIN_FILE}"
    "-o"
    "${module_path}"
    "${module_name}"
    "--boost-python"
    --ignore-invalid signature
    "--no-setup-py"
    "--root-module-suffix"
    ""
    VERBATIM
  )
  IF(TARGET python)
    ADD_DEPENDENCIES(${target_name} python)
  ENDIF(TARGET python)

  INSTALL(
    DIRECTORY ${module_path}/${module_name}
    DESTINATION ${module_install_dir}
    FILES_MATCHING PATTERN "*.pyi"
  )

  SET_PROPERTY(
    TARGET ${target_name}
    APPEND
    PROPERTY ADDITIONAL_CLEAN_FILES FILES_MATCHING PATTERN "*.pyi"
  )

ENDFUNCTION(GENERATE_STUBS module_name)