# Copyright (C) 2021 INRIA
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

set(CURRENT_FILE_PATH
    ${CMAKE_CURRENT_LIST_DIR}
    CACHE INTERNAL "")

# .rst: .. command:: LOAD_STUBGEN([GIT_TAG])
#
# GIT_TAG: the git tag of stubgen. This optional argument allows to use a
# precise version of stubgen (not necessarily the last master branch).
#
# Download and configure the stub generator module.
#
macro(LOAD_STUBGEN)
  # Handle optional argument
  set(GIT_TAG "master")
  set(extra_macro_args ${ARGN})
  list(LENGTH extra_macro_args num_extra_args)
  if(${num_extra_args} GREATER 0)
    list(GET extra_macro_args 0 GIT_TAG)
  endif()

  # Download at configure time
  set(STUBGEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/stubgen)
  configure_file(${CURRENT_FILE_PATH}/stubgen/CMakeLists.txt.in
                 stubgen/CMakeLists.txt)
  execute_process(
    COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${STUBGEN_DIR})
  if(result)
    message(FATAL_ERROR "CMake step for stubgen failed: ${result}")
  endif()

  execute_process(
    COMMAND ${CMAKE_COMMAND} --build .
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${STUBGEN_DIR})
  if(result)
    message(FATAL_ERROR "Build step for stubgen failed: ${result}")
  endif()

  set(STUBGEN_MAIN_FILE ${STUBGEN_DIR}/src/pybind11_stubgen/__init__.py)
endmacro(LOAD_STUBGEN)

# .rst: .. command:: LOAD_STUBGEN(module_path module_name module_install_dir)
#
# Generate the stubs associated to a given project. If optional arguments (which
# should be CMake targets) are supplied, then the stubs will only be generated
# after every specified target is built. On windows, the PATH will also be
# modified to find the provided targets.
#
# .rst: .. variable:: module_path
#
# Path pointing to the module
#
# .rst: .. variable:: module_name
#
# Name of the module
#
# .rst: .. variable:: module_install_dir
#
# Where the module is installed
#
function(GENERATE_STUBS module_path module_name module_install_dir)

  if(NOT STUBGEN_MAIN_FILE)
    message(
      FATAL_ERROR "You need to first load the stubgen module via LOAD_STUBGEN.")
  endif(NOT STUBGEN_MAIN_FILE)

  # Regex from IsValidTargetName in CMake/Source/cmGeneratorExpression.cxx
  if(NOT module_path)
    string(REGEX REPLACE "[^A-Za-z0-9_.+-]" "_" target_name
                         "generate_stubs_${module_name}")
  else()
    string(REGEX REPLACE "[^A-Za-z0-9_.+-]" "_" target_name
                         "generate_stubs_${module_path}_${module_name}")
  endif()

  if($ENV{PYTHONPATH})
    set(PYTHONPATH ${module_path};$ENV{PYTHONPATH})
  else()
    set(PYTHONPATH ${module_path})
  endif($ENV{PYTHONPATH})

  # On Windows with Python 3.8+, Python doesn't search DLL in PATH anymore.
  #
  # DLL are build in a different directory than the module, we must then specify
  # to pybind11_stubgen where to find it with the
  # PYBIND11_STUBGEN_ADD_DLL_DIRECTORY environment variable.
  #
  # See https://github.com/python/cpython/issues/87339#issuecomment-1093902060
  set(ENV_DLL_PATH)
  set(optional_args ${ARGN})
  if(WIN32)
    foreach(py_target IN LISTS optional_args)
      if(TARGET ${py_target})
        set(_is_lib
            "$<STREQUAL:$<TARGET_PROPERTY:${py_target},TYPE>,SHARED_LIBRARY>")
        set(_target_dir "$<TARGET_FILE_DIR:${py_target}>")
        set(_target_path $<${_is_lib}:${_target_dir}> ${_target_path})
      endif()
    endforeach()
    # Join the list with escaped semicolon to keep the environment path format
    # when giving it to `add_custom_target`
    string(REPLACE ";" "\\\;" _join_target_path "${_target_path}")
    set(ENV_DLL_PATH PYBIND11_STUBGEN_ADD_DLL_DIRECTORY=${_join_target_path})
  endif()

  add_custom_target(
    ${target_name} ALL
    COMMAND
      ${CMAKE_COMMAND} -E env ${ENV_DLL_PATH} ${CMAKE_COMMAND} -E env
      PYTHONPATH=${PYTHONPATH} "${PYTHON_EXECUTABLE}" "${STUBGEN_MAIN_FILE}"
      "-o" "${module_path}" "${module_name}" "--boost-python" --ignore-invalid
      signature "--no-setup-py" "--root-module-suffix" ""
    VERBATIM)
  foreach(py_target IN LISTS optional_args)
    if(TARGET ${py_target})
      message(
        STATUS
          "generate_stubs: adding dependency on ${py_target}. Stubs will be generated after it is built."
      )
      add_dependencies(${target_name} ${py_target})
    else(TARGET ${py_target})
      message(WARNING "generate_stubs: target ${py_target} not known.")
    endif(TARGET ${py_target})
  endforeach()

  install(
    DIRECTORY ${module_path}/${module_name}
    DESTINATION ${module_install_dir}
    FILES_MATCHING
    PATTERN "*.pyi")

  set_property(
    TARGET ${target_name}
    APPEND
    PROPERTY ADDITIONAL_CLEAN_FILES FILES_MATCHING PATTERN "*.pyi")

endfunction(GENERATE_STUBS module_name)
