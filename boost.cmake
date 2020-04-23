# Copyright (C) 2008-2019 LAAS-CNRS, JRL AIST-CNRS, INRIA
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

#.rst:
# .. command:: SEARCH_FOR_BOOST_COMPONENT
#
#   :param boost_python_name:
#   :param found:
#
#  This function returns found to TRUE if the boost_python_name has been found, FALSE otherwise.
#  This function is for internal use only.
#
FUNCTION(SEARCH_FOR_BOOST_COMPONENT boost_python_name found)
  SET(found FALSE PARENT_SCOPE)
  FIND_PACKAGE(Boost ${BOOST_REQUIRED} QUIET OPTIONAL_COMPONENTS ${boost_python_name}) 
  STRING(TOUPPER ${boost_python_name} boost_python_name_UPPER)
  IF(Boost_${boost_python_name_UPPER}_FOUND)
    SET(${found} TRUE PARENT_SCOPE)
  ENDIF()
ENDFUNCTION(SEARCH_FOR_BOOST_COMPONENT boost_python_name found)

#.rst:
# .. variable:: BOOST_COMPONENTS
#
#  Controls the components to be detected.  
#  If this variable is not defined, it defaults to the following component
#  list:
#
#  - Filesystem
#  - Program_options
#  - System
#  - Thread
#  - Unit_test_framework
#
# .. command:: SEARCH_FOR_BOOST
#
#  This macro deals with Visual Studio Fortran incompatibilities
#  and add detected flags to the pkg-config file automatically.
#
#  The components to be detected is controlled by :variable:`BOOST_COMPONENTS`.
#
#  A special treatment must be done for the boost-python component. 
#  For boost >= 1.67.0, FindPython macro should be called first in order
#  to automatically detect the right boost-python component version according
#  to the Python version (2.7 or 3.x).
#

IF(CMAKE_VERSION VERSION_LESS "3.12")
  SET(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/boost ${CMAKE_MODULE_PATH})
  MESSAGE(STATUS "CMake versions older than 3.12 may warn when looking to Boost components. Custom macros are used to find it.")
ENDIF(CMAKE_VERSION VERSION_LESS "3.12")

MACRO(SEARCH_FOR_BOOST)
  SET(Boost_USE_STATIC_LIBS OFF)
  SET(Boost_USE_MULTITHREAD ON)

  # First try to find Boost to get the version
  FIND_PACKAGE(Boost ${BOOST_REQUIRED})
  STRING(REPLACE "_" "." Boost_SHORT_VERSION ${Boost_LIB_VERSION})
  IF("${Boost_SHORT_VERSION}" VERSION_GREATER "1.70" OR "${Boost_SHORT_VERSION}" VERSION_EQUAL "1.70")
    SET(BUILD_SHARED_LIBS ON)
    SET(Boost_NO_BOOST_CMAKE ON)
  ENDIF("${Boost_SHORT_VERSION}" VERSION_GREATER "1.70" OR "${Boost_SHORT_VERSION}" VERSION_EQUAL "1.70")

  IF(NOT DEFINED BOOST_COMPONENTS)
    SET(BOOST_COMPONENTS
      filesystem system thread program_options unit_test_framework)
  ENDIF(NOT DEFINED BOOST_COMPONENTS)

  # Check if python is in the list and adjust the version according to the current Python version.
  # This is made mandatory if for Boost version greater than 1.67.0
  LIST(FIND BOOST_COMPONENTS python PYTHON_IN_BOOST_COMPONENTS)
  IF(${PYTHON_IN_BOOST_COMPONENTS} GREATER -1)
    # 1st step: check if Python has been found
    IF(NOT PYTHONLIBS_FOUND)
      MESSAGE(FATAL_ERROR "PYTHON has not been found. You should first call FindPython before calling SEARCH_FOR_BOOST macro.")   
    ENDIF(NOT PYTHONLIBS_FOUND)

    # 2nd step: copy BOOST_COMPONENTS
    SET(BOOST_COMPONENTS_ ${BOOST_COMPONENTS})

    # 3rd step: check BOOST_VERSION 
    SET(BOOST_PYTHON_WITH_PYTHON_VERSION_NAMING FALSE)
    IF("${Boost_SHORT_VERSION}" VERSION_GREATER "1.69" OR "${Boost_SHORT_VERSION}" VERSION_EQUAL "1.69")
      SET(BOOST_PYTHON_WITH_PYTHON_VERSION_NAMING TRUE)
    ELSE("${Boost_SHORT_VERSION}" VERSION_GREATER "1.69" OR "${Boost_SHORT_VERSION}" VERSION_EQUAL "1.69")
      IF(${PYTHON_VERSION_MAJOR} EQUAL 3) 
        SET(BOOST_PYTHON_WITH_PYTHON_VERSION_NAMING TRUE)
      ENDIF(${PYTHON_VERSION_MAJOR} EQUAL 3) 
    ENDIF("${Boost_SHORT_VERSION}" VERSION_GREATER "1.69" OR "${Boost_SHORT_VERSION}" VERSION_EQUAL "1.69")

    # 4th step: retrive BOOST_PYTHON_MODULE naming
    IF(BOOST_PYTHON_WITH_PYTHON_VERSION_NAMING)
      LIST(REMOVE_AT BOOST_COMPONENTS_ ${PYTHON_IN_BOOST_COMPONENTS})

      SET(BOOST_PYTHON_COMPONENT_LIST)
      # Test: python2 or python3
      LIST(APPEND BOOST_PYTHON_COMPONENT_LIST "python${PYTHON_VERSION_MAJOR}") 
      # Test: python2x or python3x
      LIST(APPEND BOOST_PYTHON_COMPONENT_LIST "python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}") 
      # Test: python-py2x or python-py3x
      LIST(APPEND BOOST_PYTHON_COMPONENT_LIST "python-py${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}") 

      SET(BOOST_PYTHON_FOUND FALSE)
      FOREACH(BOOST_PYTHON_COMPONENT ${BOOST_PYTHON_COMPONENT_LIST})
        SEARCH_FOR_BOOST_COMPONENT(${BOOST_PYTHON_COMPONENT} BOOST_PYTHON_FOUND)
        IF(BOOST_PYTHON_FOUND)
          LIST(APPEND BOOST_COMPONENTS_ ${BOOST_PYTHON_COMPONENT})
          BREAK()
        ENDIF(BOOST_PYTHON_FOUND)
      ENDFOREACH(BOOST_PYTHON_COMPONENT ${BOOST_PYTHON_COMPONENT_LIST})

      # If boost-python has not been found, then force warning from FIND_PACKAGE directly
      IF(NOT BOOST_PYTHON_FOUND)
        LIST(APPEND BOOST_COMPONENTS_ "python")
      ENDIF(NOT BOOST_PYTHON_FOUND)
      
    ENDIF(BOOST_PYTHON_WITH_PYTHON_VERSION_NAMING)

    SET(BOOST_COMPONENTS ${BOOST_COMPONENTS_})
  ENDIF(${PYTHON_IN_BOOST_COMPONENTS} GREATER -1)

  FIND_PACKAGE(Boost ${BOOST_REQUIRED} COMPONENTS ${BOOST_COMPONENTS} REQUIRED)

  IF(NOT Boost_FOUND)
    MESSAGE(
      FATAL_ERROR "Failed to detect Boost with the following components:\n"
      ${COMPONENTS})
  ENDIF(NOT Boost_FOUND)

  PKG_CONFIG_APPEND_CFLAGS("-I${Boost_INCLUDE_DIR}")

  LIST(APPEND LOGGING_WATCHED_VARIABLES
    Boost_USE_MULTITHREADED
    Boost_USE_STATIC_LIBS
    Boost_ADDITIONAL_VERSIONS
    Boost_DEBUG
    Boost_COMPILER
    BOOST_ROOT
    BOOSTROOT
    BOOST_INCLUDEDIR
    BOOST_LIBRARYDIR
    Boost_FOUND
    Boost_INCLUDE_DIRS
    Boost_INCLUDE_DIR
    Boost_LIBRARIES
    Boost_LIBRARY_DIRS
    Boost_VERSION
    Boost_LIB_VERSION
    Boost_MAJOR_VERSION
    Boost_MINOR_VERSION
    Boost_SUBMINOR_VERSION
    Boost_LIB_DIAGNOSTIC_DEFINITIONS
    )
  FOREACH(COMPONENT ${BOOST_COMPONENTS})
    STRING(TOUPPER ${COMPONENT} UPPERCOMPONENT)
    LIST(APPEND LOGGING_WATCHED_VARIABLES
      Boost_${UPPERCOMPONENT}_FOUND
      Boost_${UPPERCOMPONENT}_LIBRARY
      Boost_${UPPERCOMPONENT}_LIBRARY_DEBUG
      Boost_${UPPERCOMPONENT}_LIBRARY_RELEASE
      )
    # Detect if component has python as a substring
    STRING(FIND ${COMPONENT} "python" python_comp_pos)

    # If the substring starts with python zero if the result
    # and the test fails. Thus test greater than 1.
    IF(${python_comp_pos} GREATER -1)
      SET(Boost_PYTHON_LIBRARY ${Boost_${UPPERCOMPONENT}_LIBRARY})
      MESSAGE(STATUS "Boost_PYTHON_LIBRARY: ${Boost_PYTHON_LIBRARY}")
      LIST(APPEND Boost_PYTHON_LIBRARIES
        ${Boost_PYTHON_LIBRARY})
            LIST(APPEND LOGGING_WATCHED_VARIABLES
        python_comp_pos
        Boost_${UPPERCOMPONENT}_LIBRARY
        Boost_PYTHON_LIBRARY
        )
    ENDIF()

  ENDFOREACH()

  # On darwin systems, we must link againt boost_python with unresolved symbols.
  # We then remove boost_python from the global Boost_LIBRARIES list to handle it with specific care.
  IF(Boost_PYTHON_LIBRARY)
    LIST(REMOVE_ITEM Boost_LIBRARIES ${Boost_PYTHON_LIBRARY})
  ENDIF(Boost_PYTHON_LIBRARY)

ENDMACRO(SEARCH_FOR_BOOST)

#.rst:
# .. command:: TARGET_LINK_BOOST_PYTHON (TARGET <PRIVATE|PUBLIC|INTERFACE>)
#
#   Link target againt boost_python library.
#
#   :target: is either a library or an executable
#   :private,public,interface: The PUBLIC, PRIVATE and INTERFACE keywords can be used to specify both the link dependencies and the link interface.
#
#   On darwin systems, boost_python is not linked against any python library.
#   This linkage is resolved at execution time via the python interpreter.
#   We then need to stipulate that boost_python has unresolved symbols at compile time for a library target.
#   Otherwise, for executables we need to link to a specific version of python.
#
MACRO(TARGET_LINK_BOOST_PYTHON target)
  IF(${ARGC} GREATER 1)
    SET(PUBLIC_KEYWORD ${ARGV1})
  ENDIF()

  IF(APPLE)
    GET_TARGET_PROPERTY(TARGET_TYPE ${target} TYPE)

    IF(${TARGET_TYPE} MATCHES EXECUTABLE)
      TARGET_LINK_LIBRARIES(${target} ${PUBLIC_KEYWORD} ${Boost_PYTHON_LIBRARY})
    ELSE(${TARGET_TYPE} MATCHES EXECUTABLE)
      TARGET_LINK_LIBRARIES(${target} ${PUBLIC_KEYWORD} -Wl,-undefined,dynamic_lookup,${Boost_PYTHON_LIBRARIES})
    ENDIF(${TARGET_TYPE} MATCHES EXECUTABLE)

  ELSE(APPLE)
    TARGET_LINK_LIBRARIES(${target} ${PUBLIC_KEYWORD} ${Boost_PYTHON_LIBRARY})
  ENDIF(APPLE)
  LIST(APPEND LOGGING_WATCHED_VARIABLES
    Boost_PYTHON_LIBRARIES
    )
ENDMACRO(TARGET_LINK_BOOST_PYTHON)

#.rst:
# .. command:: PKG_CONFIG_APPEND_BOOST_LIBS
#
#   This macro appends Boost libraries to the pkg-config file. A list of Boost
#   components is expected, for instance::
#
#     PKG_CONFIG_APPEND_BOOST_LIBS(system filesystem)
#
MACRO(PKG_CONFIG_APPEND_BOOST_LIBS)
  PKG_CONFIG_APPEND_LIBRARY_DIR("${Boost_LIBRARY_DIRS}")

  FOREACH(COMPONENT ${ARGN})
    STRING(TOUPPER ${COMPONENT} UPPERCOMPONENT)
    STRING(TOLOWER ${COMPONENT} LOWERCOMPONENT)

    # See https://cmake.org/cmake/help/latest/module/FindBoost.html
    IF(CMAKE_BUILD_TYPE MATCHES DEBUG)
      SET(LIB_PATH ${Boost_${UPPERCOMPONENT}_LIBRARY_DEBUG})
    ELSE()
      SET(LIB_PATH ${Boost_${UPPERCOMPONENT}_LIBRARY_RELEASE})
    ENDIF()

    IF("${LIB_PATH}" STREQUAL "")
      SET(LIB_PATH ${Boost_${UPPERCOMPONENT}_LIBRARY})
    ENDIF("${LIB_PATH}" STREQUAL "")

    IF(APPLE)
      GET_FILENAME_COMPONENT(LIB_NAME ${LIB_PATH} NAME_WE)
      STRING(REGEX REPLACE "^lib" "" LIB_NAME "${LIB_NAME}")
      IF("${LOWERCOMPONENT}" MATCHES "python")
        PKG_CONFIG_APPEND_LIBS_RAW(-Wl,-undefined,dynamic_lookup,-l${LIB_NAME})
      ELSE("${LOWERCOMPONENT}" MATCHES "python")
        PKG_CONFIG_APPEND_LIBS_RAW(-l${LIB_NAME})
      ENDIF("${LOWERCOMPONENT}" MATCHES "python")
    ELSEIF(WIN32)
      GET_FILENAME_COMPONENT(LIB_NAME ${LIB_PATH} NAME)
      PKG_CONFIG_APPEND_LIBS_RAW("-l${LIB_NAME}")
    ELSE()
      GET_FILENAME_COMPONENT(LIB_NAME ${LIB_PATH} NAME_WE)
      STRING(REGEX REPLACE "^lib" "" LIB_NAME "${LIB_NAME}")
      PKG_CONFIG_APPEND_LIBS_RAW("-l${LIB_NAME}")
    ENDIF(APPLE)
  ENDFOREACH()
ENDMACRO(PKG_CONFIG_APPEND_BOOST_LIBS)
