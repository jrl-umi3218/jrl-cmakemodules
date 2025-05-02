# Copyright (C) 2008-2024 LAAS-CNRS, JRL AIST-CNRS, INRIA.
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

# .rst: .. command:: FINDPYTHON
#
# Find python interpreter and python libs. Arguments are passed to the
# find_package command so refer to `find_package` documentation to learn about
# valid arguments.
#
# To specify a specific Python version from the command line, use the command
# ``FINDPYTHON()`` and pass the following arguments to CMake
# ``-DPYTHON_EXECUTABLE=/usr/bin/python3.5 -DPYTHON_LIBRARY=
# /usr/lib/x86_64-linux-gnu/libpython3.5m.so.1``
#
# To specify a specific Python version within the CMakeLists.txt, use the
# command ``FINDPYTHON(2.7 EXACT REQUIRED)``.
#
# If PYTHON_PACKAGES_DIR is set, then the {dist,site}-packages will be replaced
# by the value contained in PYTHON_PACKAGES_DIR.
#
# .. warning:: According to the ``FindPythonLibs`` and ``FindPythonInterp``
# documentation, you could also set ``Python_ADDITIONAL_VERSIONS``. If you do
# this, you will not have an error if you found two different versions or
# another version that the requested one.
#

# .rst: .. variable:: PYTHON_SITELIB
#
# Relative path where Python files will be installed.

# .rst: .. variable:: PYTHON_EXT_SUFFIX
#
# Portable suffix of C++ Python modules.

# .rst: .. variable:: PYTHON_COMPONENTS
#
# Required components for python. Default: "Interpreter Development"

# .rst: .. variable:: PYTHON_EXPORT_DEPENDENCY
#
# Define this to forward `FINDPYTHON` to the exported CMake config. This is
# mainly useful for PUBLIC links to Python::Targets, so this setting change
# nothing for CMake < 3.12 which doesn't have those. This also export: -
# `FIND_NUMPY` and/or `SEARCH_FOR_BOOST_PYTHON` if necessary.

macro(FINDPYTHON)
  if(DEFINED FINDPYTHON_ALREADY_CALLED)
    message(
      AUTHOR_WARNING
      "Macro FINDPYTHON has already been called. Several call to FINDPYTHON may not find the same Python version (for a yet unknown reason)."
    )
  endif()
  set(FINDPYTHON_ALREADY_CALLED TRUE)

  if(NOT PYTHON_COMPONENTS)
    set(PYTHON_COMPONENTS Interpreter Development)
  endif()

  list(FIND PYTHON_COMPONENTS "NumPy" _npindex)
  if(NOT ${_npindex} EQUAL -1)
    set(SEARCH_FOR_NUMPY TRUE)
  endif()

  if(CMAKE_VERSION VERSION_LESS "3.18")
    # IF("Development.Module" IN_LIST PYTHON_COMPONENTS) -- require CMake 3.3
    list(FIND PYTHON_COMPONENTS "Development.Module" _index)
    if(NOT ${_index} EQUAL -1)
      message(
        STATUS
        "For CMake < 3.18, Development.Module is not available. Falling back to Development"
      )
      list(REMOVE_ITEM PYTHON_COMPONENTS Development.Module)
      set(PYTHON_COMPONENTS ${PYTHON_COMPONENTS} Development)
    endif()
    if(CMAKE_VERSION VERSION_LESS "3.14")
      if(SEARCH_FOR_NUMPY)
        message(
          STATUS
          "For CMake < 3.14, NumPy is not available. Falling back to custom FIND_NUMPY()"
        )
        list(REMOVE_ITEM PYTHON_COMPONENTS NumPy)
      endif()
    endif()
  endif()

  if(NOT CMAKE_VERSION VERSION_LESS "3.12")
    if(
      DEFINED PYTHON_EXECUTABLE
      OR DEFINED Python_EXECUTABLE
      OR DEFINED Python2_EXECUTABLE
      OR DEFINED Python3_EXECUTABLE
    )
      if(NOT DEFINED PYTHON_EXECUTABLE)
        if(DEFINED Python_EXECUTABLE)
          set(PYTHON_EXECUTABLE ${Python_EXECUTABLE})
        elseif(DEFINED Python2_EXECUTABLE)
          set(PYTHON_EXECUTABLE ${Python2_EXECUTABLE})
        elseif(DEFINED Python3_EXECUTABLE)
          set(PYTHON_EXECUTABLE ${Python3_EXECUTABLE})
        endif()
      endif()

      if(NOT DEFINED Python_EXECUTABLE)
        set(Python_EXECUTABLE ${PYTHON_EXECUTABLE})
      endif()
    else()
      # Search for the default python of the system, if exists
      find_program(PYTHON_EXECUTABLE python)
    endif()

    if(PYTHON_EXECUTABLE)
      if(NOT EXISTS ${PYTHON_EXECUTABLE})
        message(
          FATAL_ERROR
          "${PYTHON_EXECUTABLE} is not a valid path to the Python executable"
        )
      endif()
      execute_process(
        COMMAND ${PYTHON_EXECUTABLE} --version
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        RESULT_VARIABLE _PYTHON_VERSION_RESULT_VARIABLE
        OUTPUT_VARIABLE _PYTHON_VERSION_OUTPUT
        ERROR_VARIABLE _PYTHON_VERSION_OUTPUT
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_STRIP_TRAILING_WHITESPACE
      )

      if(NOT "${_PYTHON_VERSION_RESULT_VARIABLE}" STREQUAL "0")
        message(FATAL_ERROR "${PYTHON_EXECUTABLE} --version did not succeed.")
      endif()
      string(
        REGEX REPLACE
        "Python "
        ""
        _PYTHON_VERSION
        ${_PYTHON_VERSION_OUTPUT}
      )
      string(REGEX REPLACE "\\." ";" _PYTHON_VERSION ${_PYTHON_VERSION})
      list(GET _PYTHON_VERSION 0 _PYTHON_VERSION_MAJOR)

      # Provide some hints according to the current PYTHON_EXECUTABLE
      if(NOT DEFINED PYTHON_INCLUDE_DIR)
        if(_PYTHON_VERSION_MAJOR EQUAL "2")
          set(
            _PYTHON_INCLUDE_DIR_CMD
            "import distutils.sysconfig as sysconfig; print(sysconfig.get_python_inc())"
          )
        else()
          set(
            _PYTHON_INCLUDE_DIR_CMD
            "import sysconfig; print(sysconfig.get_path('include'))"
          )
        endif()
        execute_process(
          COMMAND "${PYTHON_EXECUTABLE}" "-c" "${_PYTHON_INCLUDE_DIR_CMD}"
          OUTPUT_VARIABLE PYTHON_INCLUDE_DIR
          ERROR_QUIET
        )
        string(STRIP "${PYTHON_INCLUDE_DIR}" PYTHON_INCLUDE_DIR)
        file(TO_CMAKE_PATH "${PYTHON_INCLUDE_DIR}" PYTHON_INCLUDE_DIR)
      endif()

      # Hint for finding the right Python version
      set(Python_EXECUTABLE ${PYTHON_EXECUTABLE})
      set(Python${_PYTHON_VERSION_MAJOR}_EXECUTABLE ${PYTHON_EXECUTABLE})
      set(Python${_PYTHON_VERSION_MAJOR}_INCLUDE_DIR ${PYTHON_INCLUDE_DIR})

      if(SEARCH_FOR_NUMPY)
        FIND_NUMPY()
        set(Python_NumPy_INCLUDE_DIR ${NUMPY_INCLUDE_DIRS})
      endif()

      find_package(
        "Python${_PYTHON_VERSION_MAJOR}"
        REQUIRED
        COMPONENTS ${PYTHON_COMPONENTS}
      )
    else()
      # No hint was provided. We can then check for first Python 2, then Python
      # 3
      find_package(Python2 QUIET COMPONENTS ${PYTHON_COMPONENTS})
      if(NOT Python2_FOUND)
        find_package(Python3 QUIET COMPONENTS ${PYTHON_COMPONENTS})
        if(NOT Python3_FOUND)
          message(FATAL_ERROR "Python executable has not been found.")
        else()
          set(_PYTHON_VERSION_MAJOR 3)
        endif()
      else()
        set(_PYTHON_VERSION_MAJOR 2)
      endif()
    endif()

    set(_PYTHON_PREFIX "Python${_PYTHON_VERSION_MAJOR}")

    if(${_PYTHON_PREFIX}_FOUND)
      set(PYTHON_EXECUTABLE ${${_PYTHON_PREFIX}_EXECUTABLE})
      set(Python_EXECUTABLE ${PYTHON_EXECUTABLE})
      set(PYTHON_LIBRARY ${${_PYTHON_PREFIX}_LIBRARIES})
      set(PYTHON_LIBRARIES ${${_PYTHON_PREFIX}_LIBRARIES})
      set(PYTHON_INCLUDE_DIR ${${_PYTHON_PREFIX}_INCLUDE_DIRS})
      set(PYTHON_INCLUDE_DIRS ${${_PYTHON_PREFIX}_INCLUDE_DIRS})
      set(PYTHON_VERSION_STRING ${${_PYTHON_PREFIX}_VERSION})
      set(PYTHONLIBS_VERSION_STRING ${${_PYTHON_PREFIX}_VERSION})
      set(PYTHON_FOUND ${${_PYTHON_PREFIX}_FOUND})
      set(PYTHONLIBS_FOUND ${${_PYTHON_PREFIX}_FOUND})
      set(PYTHON_VERSION_MAJOR ${${_PYTHON_PREFIX}_VERSION_MAJOR})
      set(PYTHON_VERSION_MINOR ${${_PYTHON_PREFIX}_VERSION_MINOR})
      set(PYTHON_VERSION_PATCH ${${_PYTHON_PREFIX}_VERSION_PATCH})
    else()
      message(FATAL_ERROR "Python executable has not been found.")
    endif()

    if(SEARCH_FOR_NUMPY)
      set(
        NUMPY_INCLUDE_DIRS
        "${Python${_PYTHON_VERSION_MAJOR}_NumPy_INCLUDE_DIRS}"
      )
      string(REPLACE "\\" "/" NUMPY_INCLUDE_DIRS "${NUMPY_INCLUDE_DIRS}")
      file(TO_CMAKE_PATH "${NUMPY_INCLUDE_DIRS}" NUMPY_INCLUDE_DIRS)
    endif()
  else()
    find_package(PythonInterp ${ARGN})
    if(NOT ${PYTHONINTERP_FOUND} STREQUAL TRUE)
      message(FATAL_ERROR "Python executable has not been found.")
    endif()
    message(STATUS "PythonInterp: ${PYTHON_EXECUTABLE}")

    # Set PYTHON_INCLUDE_DIR variables if it is not defined by the user
    if(DEFINED PYTHON_EXECUTABLE)
      # Retrieve the corresponding value of PYTHON_INCLUDE_DIR if it is not
      # defined
      if(NOT DEFINED PYTHON_INCLUDE_DIR)
        if(PYTHON_VERSION_MAJOR EQUAL "2")
          set(
            _PYTHON_INCLUDE_DIR_CMD
            "import distutils.sysconfig as sysconfig; print(sysconfig.get_python_inc())"
          )
        else()
          set(
            _PYTHON_INCLUDE_DIR_CMD
            "import sysconfig; print(sysconfig.get_path('include'))"
          )
        endif()
        execute_process(
          COMMAND "${PYTHON_EXECUTABLE}" "-c" "${_PYTHON_INCLUDE_DIR_CMD}"
          OUTPUT_VARIABLE PYTHON_INCLUDE_DIR
          ERROR_QUIET
        )
        string(STRIP "${PYTHON_INCLUDE_DIR}" PYTHON_INCLUDE_DIR)
      endif()
      set(PYTHON_INCLUDE_DIRS ${PYTHON_INCLUDE_DIR})
    endif()

    # Inform PythonLibs of the required version of PythonInterp
    set(PYTHONLIBS_VERSION_STRING ${PYTHON_VERSION_STRING})

    find_package(PythonLibs ${ARGN})
    message(STATUS "PythonLibraries: ${PYTHON_LIBRARIES}")
    if(NOT ${PYTHONLIBS_FOUND} STREQUAL TRUE)
      message(FATAL_ERROR "Python has not been found.")
    endif()

    string(REPLACE "." ";" _PYTHONLIBS_VERSION ${PYTHONLIBS_VERSION_STRING})
    list(GET _PYTHONLIBS_VERSION 0 PYTHONLIBS_VERSION_MAJOR)
    list(GET _PYTHONLIBS_VERSION 1 PYTHONLIBS_VERSION_MINOR)

    if(
      NOT ${PYTHON_VERSION_MAJOR} EQUAL ${PYTHONLIBS_VERSION_MAJOR}
      OR NOT ${PYTHON_VERSION_MINOR} EQUAL ${PYTHONLIBS_VERSION_MINOR}
    )
      message(
        FATAL_ERROR
        "Python interpreter and libraries are in different version: ${PYTHON_VERSION_STRING} vs ${PYTHONLIBS_VERSION_STRING}"
      )
    endif()
  endif()

  # Find PYTHON_LIBRARY_DIRS
  get_filename_component(PYTHON_LIBRARY_DIRS "${PYTHON_LIBRARIES}" PATH)
  message(STATUS "PythonLibraryDirs: ${PYTHON_LIBRARY_DIRS}")
  message(STATUS "PythonLibVersionString: ${PYTHONLIBS_VERSION_STRING}")

  if(NOT PYTHON_SITELIB)
    # Use either site-packages (default) or dist-packages (Debian packages)
    # directory
    option(PYTHON_DEB_LAYOUT "Enable Debian-style Python package layout" OFF)
    # ref. https://docs.python.org/3/library/site.html
    option(PYTHON_STANDARD_LAYOUT "Enable standard Python package layout" ON)

    if(PYTHON_STANDARD_LAYOUT)
      set(
        _PYTHON_SITELIB_CMD
        "import sys, os; print(os.sep.join(['lib', 'python' + '.'.join(sys.version.split('.')[:2]), 'site-packages']))"
      )
    else()
      if(PYTHON_VERSION_MAJOR EQUAL "2")
        set(
          _PYTHON_SITELIB_CMD
          "from distutils import sysconfig; print(sysconfig.get_python_lib(prefix='', plat_specific=False))"
        )
      else()
        set(
          _PYTHON_SITELIB_CMD
          "import sysconfig; from pathlib import Path; print(Path(sysconfig.get_path('purelib')).relative_to(sysconfig.get_path('data')))"
        )
      endif()
    endif()

    execute_process(
      COMMAND "${PYTHON_EXECUTABLE}" "-c" "${_PYTHON_SITELIB_CMD}"
      OUTPUT_VARIABLE PYTHON_SITELIB
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )

    # Keep compatility with former jrl-cmake-modules versions
    if(PYTHON_DEB_LAYOUT)
      string(
        REPLACE
        "site-packages"
        "dist-packages"
        PYTHON_SITELIB
        "${PYTHON_SITELIB}"
      )
    endif()

    # If PYTHON_PACKAGES_DIR is defined, then force the Python packages
    # directory name
    if(PYTHON_PACKAGES_DIR)
      string(
        REGEX REPLACE
        "(site-packages|dist-packages)"
        "${PYTHON_PACKAGES_DIR}"
        PYTHON_SITELIB
        "${PYTHON_SITELIB}"
      )
    endif()
  endif()

  # Avoid paths in Windows format
  if(PYTHON_SITELIB)
    file(TO_CMAKE_PATH "${PYTHON_SITELIB}" PYTHON_SITELIB)
  endif()

  message(STATUS "Python site lib: ${PYTHON_SITELIB}")
  message(STATUS "Python include dirs: ${PYTHON_INCLUDE_DIRS}")

  # Get PYTHON_SOABI We should be in favor of using PYTHON_EXT_SUFFIX in future
  # for better portability. However we keep it here for backward compatibility.
  set(PYTHON_SOABI "")
  if(PYTHON_VERSION_MAJOR EQUAL 3 AND NOT WIN32)
    execute_process(
      COMMAND
        "${PYTHON_EXECUTABLE}" "-c"
        "from sysconfig import get_config_var; print('.' + get_config_var('SOABI'))"
      OUTPUT_VARIABLE PYTHON_SOABI
    )
    string(STRIP ${PYTHON_SOABI} PYTHON_SOABI)
  endif()

  # Get PYTHON_EXT_SUFFIX
  set(PYTHON_EXT_SUFFIX "")
  if(PYTHON_VERSION_MAJOR EQUAL 3)
    execute_process(
      COMMAND
        "${PYTHON_EXECUTABLE}" "-c"
        "from sysconfig import get_config_var; print(get_config_var('EXT_SUFFIX'))"
      OUTPUT_VARIABLE PYTHON_EXT_SUFFIX
    )
    string(STRIP ${PYTHON_EXT_SUFFIX} PYTHON_EXT_SUFFIX)
  endif()
  if("${PYTHON_EXT_SUFFIX}" STREQUAL "")
    if(WIN32)
      set(PYTHON_EXT_SUFFIX ".pyd")
    else()
      set(PYTHON_EXT_SUFFIX ".so")
    endif()
  endif()

  if(PYTHON_EXPORT_DEPENDENCY)
    INSTALL_JRL_CMAKEMODULES_FILE("python.cmake")
    INSTALL_JRL_CMAKEMODULES_FILE("python-helpers.cmake")
    string(
      CONCAT
      PYTHON_EXPORT_DEPENDENCY_MACROS
      "list(APPEND PYTHON_COMPONENTS ${PYTHON_COMPONENTS})\n"
      "list(REMOVE_DUPLICATES PYTHON_COMPONENTS)\n"
      "if(NOT FINDPYTHON_ALREADY_CALLED)\n"
      "FINDPYTHON()\n"
      "endif()\n"
    )
  endif()

  if(SEARCH_FOR_NUMPY)
    FIND_NUMPY()
    if(PYTHON_EXPORT_DEPENDENCY)
      set(
        PYTHON_EXPORT_DEPENDENCY_MACROS
        "set(SEARCH_FOR_NUMPY TRUE)\n${PYTHON_EXPORT_DEPENDENCY_MACROS}"
      )
    endif()
  endif()

  if(SEARCH_FOR_NUMPY)
    message(STATUS "NumPy include dir: ${NUMPY_INCLUDE_DIRS}")
    list(APPEND NUMPY_INCLUDE_DIRS)
  endif()

  # Log Python variables
  list(
    APPEND
    LOGGING_WATCHED_VARIABLES
    PYTHONINTERP_FOUND
    PYTHONLIBS_FOUND
    PYTHON_LIBRARY_DIRS
    PYTHONLIBS_VERSION_STRING
    PYTHON_EXECUTABLE
    PYTHON_SOABI
    PYTHON_EXT_SUFFIX
  )
endmacro(FINDPYTHON)

# .rst: .. command:: DYNAMIC_GRAPH_PYTHON_MODULE ( SUBMODULENAME LIBRARYNAME
# TARGETNAME INSTALL_INIT_PY=1
# SOURCE_PYTHON_MODULE=cmake/dynamic_graph/python-module-py.cc)
#
# Add a python submodule to dynamic_graph
#
# :param SUBMODULENAME: the name of the submodule (can be foo/bar),
#
# :param LIBRARYNAME:   library to link the submodule with.
#
# :param TARGETNAME:     name of the target: should be different for several
# calls to the macro.
#
# :param INSTALL_INIT_PY: if set to 1 install and generated a __init__.py file.
# Set to 1 by default.
#
# :param SOURCE_PYTHON_MODULE: Location of the cpp file for the python module in
# the package. Set to cmake/dynamic_graph/python-module-py.cc by default.
#
# .. note:: Before calling this macro, set variable NEW_ENTITY_CLASS as the list
# of new Entity types that you want to be bound. Entity class name should match
# the name referencing the type in the factory.
#
macro(DYNAMIC_GRAPH_PYTHON_MODULE SUBMODULENAME LIBRARYNAME TARGETNAME)
  set(options DONT_INSTALL_INIT_PY)
  set(oneValueArgs SOURCE_PYTHON_MODULE MODULE_HEADER)
  cmake_parse_arguments(
    ARG
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  # By default the __init__.py file is installed.
  if(NOT DEFINED ARG_SOURCE_PYTHON_MODULE)
    set(DYNAMICGRAPH_MODULE_HEADER ${ARG_MODULE_HEADER})
    configure_file(
      ${PROJECT_JRL_CMAKE_MODULE_DIR}/dynamic_graph/python-module-py.cc.in
      ${PROJECT_BINARY_DIR}/src/dynamic_graph/${SUBMODULENAME}/python-module-py.cc
      @ONLY
    )
    set(
      ARG_SOURCE_PYTHON_MODULE
      "${PROJECT_BINARY_DIR}/src/dynamic_graph/${SUBMODULENAME}/python-module-py.cc"
    )
  endif()

  if(NOT eigenpy_DIR)
    find_package(eigenpy 2.7.10 REQUIRED)
  endif()

  set(PYTHON_MODULE ${TARGETNAME})

  add_library(${PYTHON_MODULE} MODULE ${ARG_SOURCE_PYTHON_MODULE})

  file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/src/dynamic_graph/${SUBMODULENAME})

  set(PYTHON_INSTALL_DIR "${PYTHON_SITELIB}/dynamic_graph/${SUBMODULENAME}")
  string(
    REGEX REPLACE
    "[^/]+"
    ".."
    PYTHON_INSTALL_DIR_REVERSE
    ${PYTHON_INSTALL_DIR}
  )

  set_target_properties(
    ${PYTHON_MODULE}
    PROPERTIES
      PREFIX ""
      OUTPUT_NAME dynamic_graph/${SUBMODULENAME}/wrap
      BUILD_RPATH
        "${DYNAMIC_GRAPH_PLUGINDIR}:\$ORIGIN/${PYTHON_INSTALL_DIR_REVERSE}/${DYNAMIC_GRAPH_PLUGINDIR}"
  )

  if(UNIX AND NOT APPLE)
    target_link_libraries(${PYTHON_MODULE} PUBLIC "-Wl,--no-as-needed")
  endif()
  target_link_libraries(
    ${PYTHON_MODULE}
    PUBLIC ${LIBRARYNAME} dynamic-graph::dynamic-graph
  )
  TARGET_LINK_BOOST_PYTHON(${PYTHON_MODULE} PUBLIC)
  if(PROJECT_NAME STREQUAL "dynamic-graph-python")
    target_link_libraries(${PYTHON_MODULE} PUBLIC dynamic-graph-python)
  else()
    target_link_libraries(
      ${PYTHON_MODULE}
      PUBLIC dynamic-graph-python::dynamic-graph-python
    )
  endif()

  target_include_directories(
    ${PYTHON_MODULE}
    SYSTEM
    PRIVATE ${PYTHON_INCLUDE_DIRS}
  )

  #
  # Installation
  #

  install(TARGETS ${PYTHON_MODULE} DESTINATION ${PYTHON_INSTALL_DIR})

  set(ENTITY_CLASS_LIST "")
  foreach(ENTITY ${NEW_ENTITY_CLASS})
    set(ENTITY_CLASS_LIST "${ENTITY_CLASS_LIST}${ENTITY}('')\n")
  endforeach(ENTITY ${NEW_ENTITY_CLASS})

  # Install if not DONT_INSTALL_INIT_PY
  if(NOT DONT_INSTALL_INIT_PY)
    configure_file(
      ${PROJECT_JRL_CMAKE_MODULE_DIR}/dynamic_graph/submodule/__init__.py.cmake
      ${PROJECT_BINARY_DIR}/src/dynamic_graph/${SUBMODULENAME}/__init__.py
    )

    install(
      FILES ${PROJECT_BINARY_DIR}/src/dynamic_graph/${SUBMODULENAME}/__init__.py
      DESTINATION ${PYTHON_INSTALL_DIR}
    )
  endif()
endmacro(DYNAMIC_GRAPH_PYTHON_MODULE SUBMODULENAME)

# .rst: .. command:: FIND_NUMPY()
#
# Detect numpy module and define the variable NUMPY_INCLUDE_DIRS if it is not
# already set.
#

macro(FIND_NUMPY)
  # Detect numpy.
  message(STATUS "Checking for NumPy")
  execute_process(
    COMMAND "${PYTHON_EXECUTABLE}" "-c" "import numpy; print (True)"
    OUTPUT_VARIABLE IS_NUMPY
    ERROR_QUIET
  )
  if(NOT IS_NUMPY)
    message(FATAL_ERROR "Failed to detect numpy")
  else()
    if(NOT NUMPY_INCLUDE_DIRS)
      execute_process(
        COMMAND
          "${PYTHON_EXECUTABLE}" "-c"
          "import numpy; print (numpy.get_include())"
        OUTPUT_VARIABLE NUMPY_INCLUDE_DIRS
        ERROR_QUIET
      )
      string(REGEX REPLACE "\n$" "" NUMPY_INCLUDE_DIRS "${NUMPY_INCLUDE_DIRS}")
      file(TO_CMAKE_PATH "${NUMPY_INCLUDE_DIRS}" NUMPY_INCLUDE_DIRS)
    endif()
    message(STATUS "  NUMPY_INCLUDE_DIRS=${NUMPY_INCLUDE_DIRS}")
    # Retrive NUMPY_VERSION
    execute_process(
      COMMAND
        "${PYTHON_EXECUTABLE}" "-c" "import numpy; print (numpy.__version__)"
      OUTPUT_VARIABLE NUMPY_VERSION
      ERROR_QUIET
    )
    string(REGEX REPLACE "\n$" "" NUMPY_VERSION "${NUMPY_VERSION}")
    message(STATUS "  NUMPY_VERSION=${NUMPY_VERSION}")
  endif()
endmacro()

# .rst: .. command:: FIND_SCIPY()
#
# Detect scipy module.
#
macro(FIND_SCIPY)
  message(STATUS "Checking for SciPy")
  execute_process(
    COMMAND "${PYTHON_EXECUTABLE}" "-c" "import scipy; print (True)"
    OUTPUT_VARIABLE IS_SCIPY
    ERROR_QUIET
  )

  if(NOT IS_SCIPY)
    message(FATAL_ERROR "Failed to detect scipy")
  else()
    # Retrive SCIPY_VERSION
    execute_process(
      COMMAND
        "${PYTHON_EXECUTABLE}" "-c" "import scipy; print (scipy.__version__)"
      OUTPUT_VARIABLE SCIPY_VERSION
      ERROR_QUIET
    )
    string(REGEX REPLACE "\n$" "" SCIPY_VERSION "${SCIPY_VERSION}")
    message(STATUS "  SCIPY_VERSION=${SCIPY_VERSION}")
  endif()
endmacro()

include(${CMAKE_CURRENT_LIST_DIR}/python-helpers.cmake)
