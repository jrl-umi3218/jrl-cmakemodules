# Copyright (C) 2008-2019 LAAS-CNRS, JRL AIST-CNRS, INRIA
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

# .rst: .. command:: SEARCH_FOR_BOOST_COMPONENT
#
# :param boost_python_name: :param found:
#
# This function returns found to TRUE if the boost_python_name has been found,
# FALSE otherwise. This function is for internal use only.
#
function(SEARCH_FOR_BOOST_COMPONENT boost_python_name found)
  set(${found} FALSE PARENT_SCOPE)
  find_package(
    Boost
    ${BOOST_REQUIRED}
    QUIET
    OPTIONAL_COMPONENTS ${boost_python_name}
  )
  string(TOUPPER ${boost_python_name} boost_python_name_UPPER)
  if(Boost_${boost_python_name_UPPER}_FOUND)
    set(${found} TRUE PARENT_SCOPE)
  endif()
endfunction(SEARCH_FOR_BOOST_COMPONENT boost_python_name found)

if(CMAKE_VERSION VERSION_LESS "3.12")
  set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/boost ${CMAKE_MODULE_PATH})
  message(
    STATUS
    "CMake versions older than 3.12 may warn when looking to Boost components. Custom macros are used to find it."
  )
endif(CMAKE_VERSION VERSION_LESS "3.12")

# .rst: .. command:: SET_BOOST_DEFAULT_OPTIONS
#
# This function allows to set up the default options for detecting Boost
# components.
#
macro(SET_BOOST_DEFAULT_OPTIONS)
  set(Boost_USE_STATIC_LIBS OFF)
  set(Boost_USE_MULTITHREADED ON)
  set(Boost_NO_BOOST_CMAKE ON)
endmacro(SET_BOOST_DEFAULT_OPTIONS)

# .rst: .. command:: EXPORT_BOOST_DEFAULT_OPTIONS
#
# This function allows to export the default options for detecting Boost
# components.
#
macro(EXPORT_BOOST_DEFAULT_OPTIONS)
  list(
    INSERT
    ${PROJECT_NAME}_PACKAGE_CONFIG_DEPENDENCIES_FIND_PACKAGE
    0
    "SET(Boost_USE_STATIC_LIBS OFF);SET(Boost_USE_MULTITHREADED ON);SET(Boost_NO_BOOST_CMAKE ON)"
  )
  list(
    INSERT
    ${PROJECT_NAME}_PACKAGE_CONFIG_DEPENDENCIES_FIND_DEPENDENCY
    0
    "SET(Boost_USE_STATIC_LIBS OFF);SET(Boost_USE_MULTITHREADED ON);SET(Boost_NO_BOOST_CMAKE ON)"
  )
endmacro(EXPORT_BOOST_DEFAULT_OPTIONS)

#
# .rst .. command:: SEARCH_FOR_BOOST_PYTHON([REQUIRED])
#
# Find boost-python component. For boost >= 1.67.0, FindPython macro should be
# called first in order to automatically detect the right boost-python component
# version according to the Python version (2.7 or 3.x).
#

macro(SEARCH_FOR_BOOST_PYTHON)
  set(options REQUIRED)
  set(oneValueArgs NAME)
  set(multiValueArgs)
  cmake_parse_arguments(
    SEARCH_FOR_BOOST_PYTHON_ARGS
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )
  cmake_parse_arguments(_BOOST_PYTHON_REQUIRED "REQUIRED" "" "" ${ARGN})
  set(BOOST_PYTHON_NAME "python")
  set(BOOST_PYTHON_REQUIRED "")
  if(SEARCH_FOR_BOOST_PYTHON_ARGS_REQUIRED)
    set(BOOST_PYTHON_REQUIRED REQUIRED)
  endif(SEARCH_FOR_BOOST_PYTHON_ARGS_REQUIRED)

  SET_BOOST_DEFAULT_OPTIONS()

  if(NOT PYTHON_EXECUTABLE)
    message(
      FATAL_ERROR
      "Python has not been found. You should first call FindPython before calling SEARCH_FOR_BOOST_PYTHON macro."
    )
  endif(NOT PYTHON_EXECUTABLE)

  if(SEARCH_FOR_BOOST_PYTHON_ARGS_NAME)
    set(BOOST_PYTHON_NAME ${SEARCH_FOR_BOOST_PYTHON_ARGS_NAME})
  else()
    # Test: pythonX, pythonXY and python-pyXY
    set(
      BOOST_PYTHON_COMPONENT_LIST
      "python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}"
      "python${PYTHON_VERSION_MAJOR}"
      "python-py${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}"
    )
    set(BOOST_PYTHON_FOUND FALSE)
    foreach(BOOST_PYTHON_COMPONENT ${BOOST_PYTHON_COMPONENT_LIST})
      SEARCH_FOR_BOOST_COMPONENT(${BOOST_PYTHON_COMPONENT} BOOST_PYTHON_FOUND)
      if(BOOST_PYTHON_FOUND)
        set(BOOST_PYTHON_NAME ${BOOST_PYTHON_COMPONENT})
        break()
      endif(BOOST_PYTHON_FOUND)
    endforeach(BOOST_PYTHON_COMPONENT ${BOOST_PYTHON_COMPONENT_LIST})

    # If boost-python has not been found, warn the user, and look for just
    # "python"
    if(NOT BOOST_PYTHON_FOUND)
      message(
        WARNING
        "Impossible to check Boost.Python version. Trying with 'python'."
      )
    endif(NOT BOOST_PYTHON_FOUND)
  endif()

  if(PYTHON_EXPORT_DEPENDENCY)
    INSTALL_JRL_CMAKEMODULES_DIR("boost")
    INSTALL_JRL_CMAKEMODULES_FILE("boost.cmake")
    set(
      PYTHON_EXPORT_DEPENDENCY_MACROS
      "${PYTHON_EXPORT_DEPENDENCY_MACROS}\nSEARCH_FOR_BOOST_PYTHON(${BOOST_PYTHON_REQUIRED} NAME ${BOOST_PYTHON_NAME})"
    )
  endif()
  find_package(Boost ${BOOST_PYTHON_REQUIRED} COMPONENTS ${BOOST_PYTHON_NAME})
  string(TOUPPER ${BOOST_PYTHON_NAME} UPPERCOMPONENT)

  list(
    APPEND
    LOGGING_WATCHED_VARIABLES
    Boost_${UPPERCOMPONENT}_FOUND
    Boost_${UPPERCOMPONENT}_LIBRARY
    Boost_${UPPERCOMPONENT}_LIBRARY_DEBUG
    Boost_${UPPERCOMPONENT}_LIBRARY_RELEASE
  )

  set(Boost_PYTHON_LIBRARY ${Boost_${UPPERCOMPONENT}_LIBRARY})
  list(APPEND Boost_PYTHON_LIBRARIES ${Boost_PYTHON_LIBRARY})
  list(APPEND LOGGING_WATCHED_VARIABLES Boost_PYTHON_LIBRARY)
endmacro(SEARCH_FOR_BOOST_PYTHON)

# .rst: .. command:: TARGET_LINK_BOOST_PYTHON (TARGET
# <PRIVATE|PUBLIC|INTERFACE>)
#
# Link target againt boost_python library.
#
# :target: is either a library or an executable :private,public,interface: The
# PUBLIC, PRIVATE and INTERFACE keywords can be used to specify both the link
# dependencies and the link interface.
#
# On darwin systems, boost_python is not linked against any python library. This
# linkage is resolved at execution time via the python interpreter. We then need
# to stipulate that boost_python has unresolved symbols at compile time for a
# library target. Otherwise, for executables we need to link to a specific
# version of python.
#
macro(TARGET_LINK_BOOST_PYTHON target)
  if(${ARGC} GREATER 1)
    set(PUBLIC_KEYWORD ${ARGV1})
  endif()

  if(TARGET Boost::python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR})
    target_link_libraries(
      ${target}
      ${PUBLIC_KEYWORD}
      Boost::python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}
    )
  else()
    if(APPLE)
      get_target_property(TARGET_TYPE ${target} TYPE)

      if(${TARGET_TYPE} MATCHES EXECUTABLE)
        target_link_libraries(
          ${target}
          ${PUBLIC_KEYWORD}
          ${Boost_PYTHON_LIBRARY}
        )
      else(${TARGET_TYPE} MATCHES EXECUTABLE)
        target_link_libraries(
          ${target}
          ${PUBLIC_KEYWORD}
          -Wl,-undefined,dynamic_lookup,${Boost_PYTHON_LIBRARIES}
        )
      endif(${TARGET_TYPE} MATCHES EXECUTABLE)

      target_include_directories(
        ${target}
        SYSTEM
        ${PUBLIC_KEYWORD}
        ${Boost_INCLUDE_DIR}
      )
    else(APPLE)
      target_link_libraries(
        ${target}
        ${PUBLIC_KEYWORD}
        ${Boost_PYTHON_LIBRARIES}
      )
      target_include_directories(
        ${target}
        SYSTEM
        ${PUBLIC_KEYWORD}
        ${Boost_INCLUDE_DIR}
        ${PYTHON_INCLUDE_DIR}
      )
    endif(APPLE)
    list(APPEND LOGGING_WATCHED_VARIABLES Boost_PYTHON_LIBRARIES)
  endif()
endmacro(TARGET_LINK_BOOST_PYTHON)

# .rst: .. command:: PKG_CONFIG_APPEND_BOOST_LIBS
#
# This macro appends Boost libraries to the pkg-config file. A list of Boost
# components is expected, for instance::
#
# PKG_CONFIG_APPEND_BOOST_LIBS(system filesystem)
#
macro(PKG_CONFIG_APPEND_BOOST_LIBS)
  PKG_CONFIG_APPEND_LIBRARY_DIR("${Boost_LIBRARY_DIRS}")

  foreach(COMPONENT ${ARGN})
    string(TOUPPER ${COMPONENT} UPPERCOMPONENT)
    string(TOLOWER ${COMPONENT} LOWERCOMPONENT)

    # See https://cmake.org/cmake/help/latest/module/FindBoost.html
    if(CMAKE_BUILD_TYPE MATCHES DEBUG)
      set(LIB_PATH ${Boost_${UPPERCOMPONENT}_LIBRARY_DEBUG})
    else()
      set(LIB_PATH ${Boost_${UPPERCOMPONENT}_LIBRARY_RELEASE})
    endif()

    if("${LIB_PATH}" STREQUAL "")
      set(LIB_PATH ${Boost_${UPPERCOMPONENT}_LIBRARY})
    endif("${LIB_PATH}" STREQUAL "")

    if(APPLE)
      get_filename_component(LIB_NAME ${LIB_PATH} NAME_WE)
      string(REGEX REPLACE "^lib" "" LIB_NAME "${LIB_NAME}")
      if("${LOWERCOMPONENT}" MATCHES "python")
        PKG_CONFIG_APPEND_LIBS_RAW(-Wl,-undefined,dynamic_lookup,-l${LIB_NAME})
      else("${LOWERCOMPONENT}" MATCHES "python")
        PKG_CONFIG_APPEND_LIBS_RAW(-l${LIB_NAME})
      endif("${LOWERCOMPONENT}" MATCHES "python")
    elseif(WIN32)
      get_filename_component(LIB_NAME ${LIB_PATH} NAME)
      PKG_CONFIG_APPEND_LIBS_RAW("-l${LIB_NAME}")
    else()
      get_filename_component(LIB_NAME ${LIB_PATH} NAME_WE)
      string(REGEX REPLACE "^lib" "" LIB_NAME "${LIB_NAME}")
      PKG_CONFIG_APPEND_LIBS_RAW("-l${LIB_NAME}")
    endif(APPLE)
  endforeach()
endmacro(PKG_CONFIG_APPEND_BOOST_LIBS)
