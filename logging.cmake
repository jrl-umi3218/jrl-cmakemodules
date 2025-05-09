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

# ##############################################################################
# README #
# ##############################################################################
#
# This file implements an Autotools-like config.log logging file. This file is
# generated at each project configuration and contains all information about the
# system, the environment variables, the flags passed to CMake, etc.
#

# Logging file.
set(JRL_CMAKEMODULE_LOGGING_FILENAME "${CMAKE_CURRENT_BINARY_DIR}/config.log")
get_directory_property(has_parent_scope PARENT_DIRECTORY)
if(has_parent_scope)
  set(
    JRL_CMAKEMODULE_LOGGING_FILENAME
    ${JRL_CMAKEMODULE_LOGGING_FILENAME}
    PARENT_SCOPE
  )
endif(has_parent_scope)

# Watched variables list. All watched variables final value will be displayed in
# the logging file.
set(LOGGING_WATCHED_VARIABLES "")

# Watched targets list. All watched target properties will be displayed in the
# logging file.
set(LOGGING_WATCHED_TARGETS "")

# Watched targets properties list.
set(
  LOGGING_WATCHED_TARGETS_PROPERTIES
  COMPILE_DEFINITIONS
  COMPILE_FLAGS
  DEFINE_SYMBOL
  ENABLE_EXPORTS
  EXCLUDE_FROM_ALL
  LINK_FLAGS
  SOVERSION
  VERSION
)

# Define character separating values in a portable way.
if(UNIX)
  set(LIST_SEPARATOR ":")
elseif(WIN32)
  set(LIST_SEPARATOR ";")
else(UNIX)
  message(FATAL_ERROR "Your platform is not supported.")
endif(UNIX)

# LOGGING_INITIALIZE()
# --------------
#
# This initializes the logging process by: - cleaning any previous config.log -
# writing global information.
#
function(LOGGING_INITIALIZE)
  # Retrieve interesting information.
  site_name(HOSTNAME)

  # Write logging file.
  file(REMOVE ${JRL_CMAKEMODULE_LOGGING_FILENAME})

  file(
    APPEND
    ${JRL_CMAKEMODULE_LOGGING_FILENAME}
    "This file contains any messages produced by compilers while\n"
    "running CMake, to aid debugging if configure makes a mistake.\n\n"
  )

  file(
    APPEND
    ${JRL_CMAKEMODULE_LOGGING_FILENAME}
    "It was created by ${CMAKE_PROJECT_NAME} CMake configuration process "
    "${PROJECT_VERSION}, which was\n"
    "generated by CMake ${CMAKE_VERSION}.\n\n"
  )

  file(
    APPEND
    ${JRL_CMAKEMODULE_LOGGING_FILENAME}
    "## --------- ##\n"
    "## Platform. ##\n"
    "## --------- ##\n"
    "\n"
    "hostname = ${HOSTNAME}\n"
    "system = ${CMAKE_SYSTEM}\n"
    "processor = ${CMAKE_SYSTEM_PROCESSOR}\n"
    "generator = ${CMAKE_GENERATOR}\n"
    "\n"
  )

  if(NOT "$ENV{PATH}" STREQUAL "")
    string(REPLACE "${LIST_SEPARATOR}" "\nPATH " PATH "$ENV{PATH}")
  else()
    set(PATH undefined)
  endif()
  file(APPEND ${JRL_CMAKEMODULE_LOGGING_FILENAME} "PATH " ${PATH} "\n\n")

  if(NOT "$ENV{PKG_CONFIG_PATH}" STREQUAL "")
    string(
      REPLACE
      "${LIST_SEPARATOR}"
      "\nPKG_CONFIG_PATH "
      PKG_CONFIG_PATH
      "$ENV{PKG_CONFIG_PATH}"
    )
  else()
    set(PKG_CONFIG_PATH "undefined")
  endif()
  file(
    APPEND
    ${JRL_CMAKEMODULE_LOGGING_FILENAME}
    "PKG_CONFIG_PATH "
    ${PKG_CONFIG_PATH}
    "\n\n"
  )
endfunction(LOGGING_INITIALIZE)

# LOGGING_FINALIZE()
# --------------
#
# This finalizes the logging process by: - logging the watched variables
#
function(LOGGING_FINALIZE)
  file(
    APPEND
    ${JRL_CMAKEMODULE_LOGGING_FILENAME}
    "## ---------------- ##\n"
    "## CMake variables. ##\n"
    "## ---------------- ##\n"
    "\n"
    "CMAKE_ROOT = ${CMAKE_ROOT}\n"
    "CMAKE_INCLUDE_PATH = ${CMAKE_INCLUDE_PATH}\n"
    "CMAKE_LIBRARY_PATH = ${CMAKE_LIBRARY_PATH}\n"
    "CMAKE_PREFIX_PATH = ${CMAKE_PREFIX_PATH}\n"
    "CMAKE_INSTALL_ALWAYS = ${CMAKE_INSTALL_ALWAYS}\n"
    "CMAKE_SKIP_RPATH = ${CMAKE_SKIP_RPATH}\n"
    "CMAKE_SUPPRESS_REGENERATION = ${CMAKE_SUPPRESS_REGENERATION}\n"
    "BUILD_SHARED_LIBS = ${BUILD_SHARED_LIBS}\n"
    "\n"
    "CMAKE_INSTALL_PREFIX = ${CMAKE_INSTALL_PREFIX}\n"
    "PROJECT_SOURCE_DIR = ${PROJECT_SOURCE_DIR}\n"
    "PROJECT_SOURCE_DIR = ${PROJECT_SOURCE_DIR}\n"
    "PROJECT_BINARY_DIR = ${PROJECT_BINARY_DIR}\n"
    "CMAKE_BINARY_DIR = ${CMAKE_BINARY_DIR}\n"
    "\n"
    "CMAKE_AR = ${CMAKE_AR}\n"
    "CMAKE_RANLIB = ${CMAKE_RANLIB}\n"
    "CMAKE_BUILD_TYPE = ${CMAKE_BUILD_TYPE}\n"
    "CMAKE_CONFIGURATION_TYPES = ${CMAKE_CONFIGURATION_TYPES}\n"
    "CMAKE_SHARED_LINKER_FLAGS = ${CMAKE_SHARED_LINKER_FLAGS}\n"
    "\n"
    "CMAKE_C_COMPILER = ${CMAKE_C_COMPILER}\n"
    "CMAKE_C_FLAGS = ${CMAKE_C_FLAGS}\n"
    "CMAKE_C_FLAGS_DEBUG = ${CMAKE_C_FLAGS_DEBUG}\n"
    "CMAKE_C_FLAGS_RELEASE = ${CMAKE_C_FLAGS_RELEASE}\n"
    "CMAKE_CXX_COMPILER = ${CMAKE_CXX_COMPILER}\n"
    "CMAKE_CXX_FLAGS = ${CMAKE_CXX_FLAGS}\n"
    "CMAKE_CXX_FLAGS_DEBUG = ${CMAKE_CXX_FLAGS_DEBUG}\n"
    "CMAKE_CXX_FLAGS_RELEASE = ${CMAKE_CXX_FLAGS_RELEASE}\n"
    "CMAKE_CXX_FLAGS_RELWITHDEBINFO = ${CMAKE_CXX_FLAGS_RELWITHDEBINFO}\n"
    "\n"
    "CMAKE_STATIC_LIBRARY_PREFIX = ${CMAKE_STATIC_LIBRARY_PREFIX}\n"
    "CMAKE_STATIC_LIBRARY_SUFFIX = ${CMAKE_STATIC_LIBRARY_SUFFIX}\n"
    "CMAKE_SHARED_LIBRARY_PREFIX = ${CMAKE_SHARED_LIBRARY_PREFIX}\n"
    "CMAKE_SHARED_LIBRARY_SUFFIX = ${CMAKE_SHARED_LIBRARY_SUFFIX}\n"
    "CMAKE_SHARED_MODULE_PREFIX = ${CMAKE_SHARED_MODULE_PREFIX}\n"
    "CMAKE_SHARED_MODULE_SUFFIX = ${CMAKE_SHARED_MODULE_SUFFIX}\n"
    "\n"
  )

  file(
    APPEND
    ${JRL_CMAKEMODULE_LOGGING_FILENAME}
    "## ------------------ ##\n"
    "## Watched variables. ##\n"
    "## ------------------ ##\n"
    "\n"
  )

  list(REMOVE_DUPLICATES LOGGING_WATCHED_VARIABLES)
  foreach(VAR ${LOGGING_WATCHED_VARIABLES})
    if(NOT DEFINED ${VAR})
      set(${VAR} "undefined")
    endif()
    file(APPEND ${JRL_CMAKEMODULE_LOGGING_FILENAME} "${VAR} = ${${VAR}}\n")
  endforeach()

  file(
    APPEND
    ${JRL_CMAKEMODULE_LOGGING_FILENAME}
    "## ---------------- ##\n"
    "## Watched targets. ##\n"
    "## ---------------- ##\n"
    "\n"
  )

  list(REMOVE_DUPLICATES LOGGING_WATCHED_TARGETS)
  foreach(TARGET ${LOGGING_WATCHED_TARGETS})
    foreach(PROPERTY ${LOGGING_WATCHED_TARGETS_PROPERTIES})
      get_target_property(VALUE ${TARGET} ${PROPERTY})
      file(
        APPEND
        ${JRL_CMAKEMODULE_LOGGING_FILENAME}
        "${TARGET}_${PROPERTY} = ${VALUE}\n"
      )
    endforeach()
    file(APPEND ${JRL_CMAKEMODULE_LOGGING_FILENAME} "\n")
  endforeach()
endfunction(LOGGING_FINALIZE)
