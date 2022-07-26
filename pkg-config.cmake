# Copyright (C) 2008-2020 LAAS-CNRS, JRL AIST-CNRS INRIA.
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

include(${CMAKE_CURRENT_LIST_DIR}/shared-library.cmake)

find_package(PkgConfig)

# For CMake >= 3.12, this can be replace by list(JOIN ${${var_in}} ${sep} out)
function(_list_join var_in sep var_out)
  if(CMAKE_VERSION VERSION_GREATER 3.12)
    list(JOIN ${var_in} ${sep} out)
  else()
    set(first TRUE)
    foreach(el ${${var_in}})
      if(first)
        set(out "${el}")
        set(first FALSE)
      else()
        set(out "${out}${sep}${el}")
      endif()
    endforeach()
  endif()
  set(${var_out}
      ${out}
      PARENT_SCOPE)
endfunction()

# Additional pkg-config variables whose value will be imported during the
# dependency check.
set(PKG_CONFIG_ADDITIONAL_VARIABLES bindir pkglibdir datarootdir pkgdatarootdir
                                    docdir doxygendocdir)

# .rst: .. ifmode:: internal
#
# .. command:: _SETUP_PROJECT_PKG_CONFIG
#
# Prepare pkg-config pc file generation step.
#
# This file will be named ${PROJECT_NAME}.pc, or
# ${CUSTOM_PKG_CONFIG_FILENAME}.pc if it is defined
#
macro(_SETUP_PROJECT_PKG_CONFIG)
  # Pkg-config related commands.
  set(_PKG_CONFIG_PREFIX
      "\${pcfiledir}/../.."
      CACHE INTERNAL "")
  set(_PKG_CONFIG_EXEC_PREFIX
      "${_PKG_CONFIG_PREFIX}"
      CACHE INTERNAL "")
  set(_PKG_CONFIG_LIBDIR
      "${_PKG_CONFIG_PREFIX}/${CMAKE_INSTALL_LIBDIR}"
      CACHE INTERNAL "")
  set(_PKG_CONFIG_BINDIR
      "${_PKG_CONFIG_PREFIX}/${CMAKE_INSTALL_BINDIR}"
      CACHE INTERNAL "")
  set(_PKG_CONFIG_PKGLIBDIR
      "${_PKG_CONFIG_PREFIX}/${CMAKE_INSTALL_PKGLIBDIR}"
      CACHE INTERNAL "")
  set(_PKG_CONFIG_INCLUDEDIR
      "${_PKG_CONFIG_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}"
      CACHE INTERNAL "")
  set(_PKG_CONFIG_DATAROOTDIR
      "${_PKG_CONFIG_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}"
      CACHE INTERNAL "")
  set(_PKG_CONFIG_PKGDATAROOTDIR
      "${_PKG_CONFIG_PREFIX}/${CMAKE_INSTALL_DATADIR}"
      CACHE INTERNAL "")
  if(INSTALL_DOCUMENTATION)
    set(_PKG_CONFIG_DOCDIR
        "${_PKG_CONFIG_PREFIX}/${CMAKE_INSTALL_DOCDIR}"
        CACHE INTERNAL "")
    set(_PKG_CONFIG_DOXYGENDOCDIR
        "${_PKG_CONFIG_DOCDIR}/doxygen-html"
        CACHE INTERNAL "")
  else(INSTALL_DOCUMENTATION)
    set(_PKG_CONFIG_DOCDIR
        ""
        CACHE INTERNAL "")
    set(_PKG_CONFIG_DOXYGENDOCDIR
        ""
        CACHE INTERNAL "")
  endif(INSTALL_DOCUMENTATION)

  if(DEFINED PROJECT_DEBUG_POSTFIX)
    if(DEFINED CMAKE_CONFIGURATION_TYPES)
      set(_PKG_CONFIG_PROJECT_NAME_NOPOSTFIX
          "${PROJECT_NAME}"
          CACHE INTERNAL "")
      set(_PKG_CONFIG_PROJECT_NAME
          "${PROJECT_NAME}${PKGCONFIG_POSTFIX}"
          CACHE INTERNAL "")
    else()
      set(_PKG_CONFIG_PROJECT_NAME
          "${PROJECT_NAME}${PKGCONFIG_POSTFIX}"
          CACHE INTERNAL "")
    endif()
  else()
    set(_PKG_CONFIG_PROJECT_NAME
        "${PROJECT_NAME}"
        CACHE INTERNAL "")
  endif()
  set(_PKG_CONFIG_DESCRIPTION
      "${PROJECT_DESCRIPTION}"
      CACHE INTERNAL "")
  set(_PKG_CONFIG_URL
      "${PROJECT_URL}"
      CACHE INTERNAL "")
  set(_PKG_CONFIG_VERSION
      "${PROJECT_VERSION}"
      CACHE INTERNAL "")
  set(_PKG_CONFIG_REQUIRES
      ""
      CACHE INTERNAL "")
  set(_PKG_CONFIG_REQUIRES_DEBUG
      ""
      CACHE INTERNAL "")
  set(_PKG_CONFIG_REQUIRES_OPTIMIZED
      ""
      CACHE INTERNAL "")
  set(_PKG_CONFIG_COMPILE_TIME_REQUIRES
      ""
      CACHE INTERNAL "")
  set(_PKG_CONFIG_CONFLICTS
      ""
      CACHE INTERNAL "")
  set(_PKG_CONFIG_LIBS
      ""
      CACHE INTERNAL "")
  set(_PKG_CONFIG_LIBS_DEBUG
      "${LIBDIR_KW}\${libdir}"
      CACHE INTERNAL "")
  set(_PKG_CONFIG_LIBS_OPTIMIZED
      "${LIBDIR_KW}\${libdir}"
      CACHE INTERNAL "")
  set(_PKG_CONFIG_LIBS_PRIVATE
      ""
      CACHE INTERNAL "")
  set(_PKG_CONFIG_CFLAGS
      "-I\${includedir}"
      CACHE INTERNAL "")
  set(_PKG_CONFIG_CFLAGS_DEBUG
      ""
      CACHE INTERNAL "")
  set(_PKG_CONFIG_CFLAGS_OPTIMIZED
      ""
      CACHE INTERNAL "")
  set(_PKG_CONFIG_FILENAME
      "${PROJECT_NAME}.pc"
      CACHE INTERNAL "")

  set(PKG_CONFIG_EXTRA "")

  # Where to install the pkg-config file?
  set(_PKG_CONFIG_DIR
      "${_PKG_CONFIG_LIBDIR}/pkgconfig"
      CACHE INTERNAL "")

  # Watch variables.
  list(
    APPEND
    LOGGING_WATCHED_VARIABLES
    _PKG_CONFIG_FOUND
    PKG_CONFIG_EXECUTABLE
    _PKG_CONFIG_PREFIX
    _PKG_CONFIG_EXEC_PREFIX
    _PKG_CONFIG_LIBDIR
    _PKG_CONFIG_BINDIR
    _PKG_CONFIG_PKGLIBDIR
    _PKG_CONFIG_INCLUDEDIR
    _PKG_CONFIG_DATAROOTDIR
    _PKG_CONFIG_PKGDATAROOTDIR
    _PKG_CONFIG_DOCDIR
    _PKG_CONFIG_DOXYGENDOCDIR
    _PKG_CONFIG_PROJECT_NAME
    _PKG_CONFIG_DESCRIPTION
    _PKG_CONFIG_URL
    _PKG_CONFIG_VERSION
    _PKG_CONFIG_REQUIRES
    _PKG_CONFIG_REQUIRES_DEBUG
    _PKG_CONFIG_REQUIRES_OPTIMIZED
    _PKG_CONFIG_COMPILE_TIME_REQUIRES
    _PKG_CONFIG_CONFLICTS
    _PKG_CONFIG_LIBS
    _PKG_CONFIG_LIBS_DEBUG
    _PKG_CONFIG_LIBS_OPTIMIZED
    _PKG_CONFIG_LIBS_PRIVATE
    _PKG_CONFIG_CFLAGS
    _PKG_CONFIG_CFLAGS_DEBUG
    _PKG_CONFIG_CFLAGS_OPTIMIZED
    _PKG_CONFIG_FILENAME
    PKG_CONFIG_EXTRA)
endmacro(_SETUP_PROJECT_PKG_CONFIG)

# _SETUP_PROJECT_PKG_CONFIG_FINALIZE_DEBUG
# ----------------------------------
#
# Post-processing of the pkg-config step.
#
# The pkg-config file has to be generated at the end to allow end-user defined
# variables replacement.
#
# This macro adds _PKG_CONFIG_LIBS_DEBUG to _PKG_CONFIG_LIBS and
# _PKGCONFIG_CFLAGS_DEBUG to _PKG_CONFIG_CFLAGS
#
macro(_SETUP_PROJECT_PKG_CONFIG_FINALIZE_DEBUG)
  # Setup altered variables
  set(TEMP_CFLAGS ${_PKG_CONFIG_CFLAGS})
  set(_PKG_CONFIG_CFLAGS "${_PKG_CONFIG_CFLAGS_DEBUG} ${_PKG_CONFIG_CFLAGS}")
  set(TEMP_LIBS ${_PKG_CONFIG_LIBS})
  set(_PKG_CONFIG_LIBS "${_PKG_CONFIG_LIBS_DEBUG} ${_PKG_CONFIG_LIBS}")
  set(TEMP_REQUIRES ${_PKG_CONFIG_REQUIRES})
  if(_PKG_CONFIG_REQUIRES_DEBUG)
    list(APPEND _PKG_CONFIG_REQUIRES "${_PKG_CONFIG_REQUIRES_DEBUG}")
  endif()
  _list_join(_PKG_CONFIG_REQUIRES ", " _PKG_CONFIG_REQUIRES_LIST)
  configure_file(
    "${PROJECT_JRL_CMAKE_MODULE_DIR}/pkg-config.pc.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}${PKGCONFIG_POSTFIX}.pc")
  # Restore altered variables
  set(_PKG_CONFIG_CFLAGS ${TEMP_CFLAGS})
  set(_PKG_CONFIG_LIBS ${TEMP_LIBS})
  set(_PKG_CONFIG_REQUIRES ${TEMP_REQUIRES})

  install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}${PKGCONFIG_POSTFIX}.pc"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
    PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE)
endmacro(_SETUP_PROJECT_PKG_CONFIG_FINALIZE_DEBUG)

# _SETUP_PROJECT_PKG_CONFIG_FINALIZE_OPTIMIZED
# ----------------------------------
#
# Post-processing of the pkg-config step.
#
# The pkg-config file has to be generated at the end to allow end-user defined
# variables replacement.
#
# This macro adds _PKG_CONFIG_LIBS_OPTIMIZED to _PKG_CONFIG_LIBS and
# _PKGCONFIG_CFLAGS_OPTIMIZED to _PKG_CONFIG_CFLAGS
#
macro(_SETUP_PROJECT_PKG_CONFIG_FINALIZE_OPTIMIZED)
  # Setup altered variables
  set(TEMP_PROJECT_NAME ${_PKG_CONFIG_PROJECT_NAME})
  set(_PKG_CONFIG_PROJECT_NAME ${_PKG_CONFIG_PROJECT_NAME_NOPOSTFIX})
  set(TEMP_CFLAGS ${_PKG_CONFIG_CFLAGS})
  set(_PKG_CONFIG_CFLAGS
      "${_PKG_CONFIG_CFLAGS_OPTIMIZED} ${_PKG_CONFIG_CFLAGS}")
  set(TEMP_LIBS ${_PKG_CONFIG_LIBS})
  set(_PKG_CONFIG_LIBS "${_PKG_CONFIG_LIBS_OPTIMIZED} ${_PKG_CONFIG_LIBS}")
  set(TEMP_REQUIRES ${_PKG_CONFIG_REQUIRES})
  if(_PKG_CONFIG_REQUIRES_OPTIMIZED)
    list(APPEND _PKG_CONFIG_REQUIRES "${_PKG_CONFIG_REQUIRES_OPTIMIZED}")
  endif()
  _list_join(_PKG_CONFIG_REQUIRES ", " _PKG_CONFIG_REQUIRES_LIST)
  if(DEFINED CUSTOM_PKG_CONFIG_FILENAME)
    set(_PKG_CONFIG_FILENAME
        "${CUSTOM_PKG_CONFIG_FILENAME}.pc"
        CACHE INTERNAL "")
  endif(DEFINED CUSTOM_PKG_CONFIG_FILENAME)
  # Generate the pkg-config file.
  configure_file("${PROJECT_JRL_CMAKE_MODULE_DIR}/pkg-config.pc.cmake"
                 "${CMAKE_CURRENT_BINARY_DIR}/${_PKG_CONFIG_FILENAME}")
  # Restore altered variables
  set(_PKG_CONFIG_PROJECT_NAME ${TEMP_PROJECT_NAME})
  set(_PKG_CONFIG_CFLAGS ${TEMP_CFLAGS})
  set(_PKG_CONFIG_LIBS ${TEMP_LIBS})
  set(_PKG_CONFIG_REQUIRES ${TEMP_REQUIRES})

  install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/${_PKG_CONFIG_FILENAME}"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
    PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE)
endmacro(_SETUP_PROJECT_PKG_CONFIG_FINALIZE_OPTIMIZED)

# _SETUP_PROJECT_PKG_CONFIG_FINALIZE
# ----------------------------------
#
# Post-processing of the pkg-config step.
#
# The pkg-config file has to be generated at the end to allow end-user defined
# variables replacement.
#
macro(_SETUP_PROJECT_PKG_CONFIG_FINALIZE)
  # Single build type generator
  if(DEFINED CMAKE_BUILD_TYPE)
    string(TOLOWER "${CMAKE_BUILD_TYPE}" cmake_build_type)
    if(${cmake_build_type} MATCHES debug)
      _setup_project_pkg_config_finalize_debug()
    else()
      _setup_project_pkg_config_finalize_optimized()
    endif()
    # Multiple build types generator
  else()
    if(DEFINED PROJECT_DEBUG_POSTFIX)
      _setup_project_pkg_config_finalize_debug()
      _setup_project_pkg_config_finalize_optimized()
    else()
      _setup_project_pkg_config_finalize_optimized()
    endif()
  endif()
endmacro(_SETUP_PROJECT_PKG_CONFIG_FINALIZE)

# _PARSE_PKG_CONFIG_STRING (PKG_CONFIG_STRING _PKG_LIB_NAME_VAR _PKG_PREFIX_VAR
# _PKG_CONFIG_STRING_NOSPACE_VAR)
# ----------------------------------------------------------
#
# Retrieve from the pkg-config string: - the library name, - the prefix used for
# CMake variable names, - a variant without spaces around the operator (if there
# is an operator), as expected by cmake's CHECK_PKG_MODULE. . For instance,
# `my-package > 0.4` results in - _PKG_LIB_NAME_VAR <- my-package -
# _PKG_PREFIX_VAR <- MY_PACKAGE - _PKG_CONFIG_STRING_NOSPACE_VAR <-
# `my-package>0.4` `my-package` results in - _PKG_LIB_NAME_VAR <- my-package -
# _PKG_PREFIX_VAR <- MY_PACKAGE - _PKG_CONFIG_STRING_NOSPACE_VAR <- `my-package`
macro(_PARSE_PKG_CONFIG_STRING PKG_CONFIG_STRING _PKG_LIB_NAME_VAR
      _PKG_PREFIX_VAR _PKG_CONFIG_NOSPACE_VAR)
  # Decompose the equation
  string(REGEX MATCH "([^ ]+)( (>|>=|=|<=|<) (.*))?" _UNUSED
               "${PKG_CONFIG_STRING}")
  # Reconstruct the equation, without the space around the operator
  set(${_PKG_CONFIG_NOSPACE_VAR}
      "${CMAKE_MATCH_1}${CMAKE_MATCH_3}${CMAKE_MATCH_4}")
  # The left part of the equation is the package name
  set(${_PKG_LIB_NAME_VAR} "${CMAKE_MATCH_1}")
  # Transform it into a valid variable prefix. 1. replace invalid characters
  # into underscores.
  string(REGEX REPLACE "[^a-zA-Z0-9]" "_" ${_PKG_PREFIX_VAR}
                       "${${_PKG_LIB_NAME_VAR}}")
  # 1. make it uppercase.
  string(TOUPPER "${${_PKG_PREFIX_VAR}}" ${_PKG_PREFIX_VAR})
endmacro()

# ADD_DEPENDENCY(PREFIX P_REQUIRED COMPILE_TIME_ONLY PKGCONFIG_STRING)
# ------------------------------------------------
#
# Check for a dependency using pkg-config. Fail if the package cannot be found.
#
# P_REQUIRED : if set to 1 the package is required, otherwise it consider as
# optional. WARNING for optional package: if the package is detected its compile
# and linking options are still put in the required fields of the generated pc
# file. Indeed from the binary viewpoint the package becomes required.
#
# COMPILE_TIME_ONLY : if set to 1, the package is only requiered at compile time
# and won't appear as a dependency inside the *.pc file.
#
# PKG_CONFIG_STRING       : string passed to pkg-config to check the version.
# Typically, this string looks like: ``my-package >= 0.5''
#
macro(ADD_DEPENDENCY P_REQUIRED COMPILE_TIME_ONLY PKG_CONFIG_STRING
      PKG_CONFIG_DEBUG_STRING)
  _parse_pkg_config_string("${PKG_CONFIG_STRING}" LIBRARY_NAME PREFIX
                           PKG_CONFIG_STRING_NOSPACE)
  if(NOT ${PKG_CONFIG_DEBUG_STRING} STREQUAL "")
    _parse_pkg_config_string("${PKG_CONFIG_DEBUG_STRING}" LIBRARY_DEBUG_NAME
                             ${PREFIX}_DEBUG PKG_CONFIG_DEBUG_STRING_NOSPACE)
  endif()

  # Force redetection each time CMake is launched. Rationale: these values are
  # *NEVER* manually set, so information is never lost by overriding them.
  # Moreover, changes in the pkg-config files are not seen as long as the cache
  # is not destroyed, even if the .pc file is changed. This is a BAD behavior.
  set(${PREFIX}_FOUND 0)
  if(DEFINED ${PREFIX}_DEBUG)
    set(${PREFIX}_DEBUG_FOUND 0)
  endif()

  # This makes the debug dependency optional when building in release and
  # vice-versa, this only applies to single build type generators
  set(PP_REQUIRED ${P_REQUIRED}) # Work-around macro limitation
  if(DEFINED ${PREFIX}_DEBUG)
    set(P_DEBUG_REQUIRED ${P_REQUIRED})
    if(${P_REQUIRED})
      # Single build type generators
      if(DEFINED CMAKE_BUILD_TYPE)
        string(TOLOWER "${CMAKE_BUILD_TYPE}" cmake_build_type)
        if("${cmake_build_type}" MATCHES "debug")
          set(PP_REQUIRED 0)
        else()
          set(P_DEBUG_REQUIRED 0)
        endif()
      endif()
    endif()
  endif()

  # Search for the package.
  if(${PP_REQUIRED})
    message(STATUS "${PKG_CONFIG_STRING} is required.")
    pkg_check_modules("${PREFIX}" REQUIRED "${PKG_CONFIG_STRING_NOSPACE}")
  else(${PP_REQUIRED})
    message(STATUS "${PKG_CONFIG_STRING} is optional.")
    pkg_check_modules("${PREFIX}" "${PKG_CONFIG_STRING_NOSPACE}")
  endif(${PP_REQUIRED})

  # Search for the debug package
  if(DEFINED ${PREFIX}_DEBUG)
    if(${P_DEBUG_REQUIRED})
      message(STATUS "${PKG_CONFIG_DEBUG_STRING} is required")
      pkg_check_modules("${PREFIX}_DEBUG" REQUIRED
                        "${PKG_CONFIG_DEBUG_STRING_NOSPACE}")
    else(${P_DEBUG_REQUIRED})
      message(STATUS "${PKG_CONFIG_DEBUG_STRING} is optional")
      pkg_check_modules("${PREFIX}_DEBUG" "${PKG_CONFIG_DEBUG_STRING_NOSPACE}")
    endif(${P_DEBUG_REQUIRED})
  endif()

  # Fix for ld >= 2.24.90: -l:/some/absolute/path.so is no longer supported. See
  # shared-library.cmake.
  if(UNIX AND NOT ${LD_VERSION} VERSION_LESS "2.24.90")
    string(REPLACE ":/" "/" "${PREFIX}_LIBRARIES" "${${PREFIX}_LIBRARIES}")
    string(REPLACE "-l:/" "/" "${PREFIX}_LDFLAGS" "${${PREFIX}_LDFLAGS}")

    if(DEFINED ${PREFIX}_DEBUG)
      string(REPLACE ":/" "/" "${PREFIX}_DEBUG_LIBRARIES"
                     "${${PREFIX}_DEBUG_LIBRARIES}")
      string(REPLACE "-l:/" "/" "${PREFIX}_DEBUG_LDFLAGS"
                     "${${PREFIX}_DEBUG_LDFLAGS}")
    endif()
  endif()

  # Watch variables.
  list(
    APPEND
    LOGGING_WATCHED_VARIABLES
    ${PREFIX}_FOUND
    ${PREFIX}_LIBRARIES
    ${PREFIX}_LIBRARY_DIRS
    ${PREFIX}_LDFLAGS
    ${PREFIX}_LDFLAGS_OTHER
    ${PREFIX}_INCLUDE_DIRS
    ${PREFIX}_CFLAGS
    ${PREFIX}_CFLAGS_OTHER
    ${PREFIX}
    ${PREFIX}_STATIC
    ${PREFIX}_VERSION
    ${PREFIX}_PREFIX
    ${PREFIX}_INCLUDEDIR
    ${PREFIX}_LIBDIR
    ${PREFIX}_PKGLIBDIR
    ${PREFIX}_BINDIR
    ${PREFIX}_DATAROOTDIR
    ${PREFIX}_PKGDATAROOTDIR
    ${PREFIX}_DOCDIR
    ${PREFIX}_DOXYGENDOCDIR)
  if(DEFINED ${PREFIX}_DEBUG)
    list(
      APPEND
      LOGGING_WATCHED_VARIABLES
      ${PREFIX}_DEBUG_FOUND
      ${PREFIX}_DEBUG_LIBRARIES
      ${PREFIX}_DEBUG_LIBRARY_DIRS
      ${PREFIX}_DEBUG_LDFLAGS
      ${PREFIX}_DEBUG_LDFLAGS_OTHER
      ${PREFIX}_DEBUG_INCLUDE_DIRS
      ${PREFIX}_DEBUG_CFLAGS
      ${PREFIX}_DEBUG_CFLAGS_OTHER
      ${PREFIX}_DEBUG
      ${PREFIX}_DEBUG_STATIC
      ${PREFIX}_DEBUG_VERSION
      ${PREFIX}_DEBUG_PREFIX_DEBUG
      ${PREFIX}_DEBUG_INCLUDEDIR
      ${PREFIX}_DEBUG_LIBDIR
      ${PREFIX}_DEBUG_PKGLIBDIR
      ${PREFIX}_DEBUG_BINDIR
      ${PREFIX}_DEBUG_DATAROOTDIR
      ${PREFIX}_DEBUG_PKGDATAROOTDIR
      ${PREFIX}_DEBUG_DOCDIR
      ${PREFIX}_DEBUG_DOXYGENDOCDIR)
  endif()

  # Get the values of additional variables.
  foreach(VARIABLE ${PKG_CONFIG_ADDITIONAL_VARIABLES})
    # Upper-case version of the variable for CMake variable generation.
    string(TOUPPER "${VARIABLE}" "VARIABLE_UC")
    execute_process(
      COMMAND "${PKG_CONFIG_EXECUTABLE}" "--variable=${VARIABLE}"
              "${LIBRARY_NAME}"
      OUTPUT_VARIABLE "${PREFIX}_${VARIABLE_UC}"
      ERROR_QUIET)
    string(REPLACE "\n" "" "${PREFIX}_${VARIABLE_UC}"
                   "${${PREFIX}_${VARIABLE_UC}}")
    # Watch additional variables.
    list(APPEND LOGGING_WATCHED_VARIABLES ${PREFIX}_${VARIABLE_UC})
    if(DEFINED ${PREFIX}_DEBUG)
      execute_process(
        COMMAND "${PKG_CONFIG_EXECUTABLE}" "--variable=${VARIABLE}"
                "${LIBRARY_DEBUG_NAME}"
        OUTPUT_VARIABLE "${PREFIX}_DEBUG_${VARIABLE_UC}"
        ERROR_QUIET)
      string(REPLACE "\n" "" "${PREFIX}_DEBUG_${VARIABLE_UC}"
                     "${${PREFIX}_DEBUG_${VARIABLE_UC}}")
      list(APPEND LOGGING_WATCHED_VARIABLES ${PREFIX}_DEBUG_${VARIABLE_UC})
    endif()
  endforeach(VARIABLE)

  # FIXME: spaces are replaced by semi-colon by mistakes, revert the change. I
  # cannot see why CMake is doing that...
  string(REPLACE ";" " " PKG_CONFIG_STRING "${PKG_CONFIG_STRING}")
  if(DEFINED ${PREFIX}_DEBUG)
    string(REPLACE ";" " " PKG_CONFIG_DEBUG_STRING "${PKG_CONFIG_DEBUG_STRING}")
  endif()

  if(DEFINED ${PREFIX}_DEBUG)
    if(${${PREFIX}_FOUND})
      set(PACKAGE_FOUND 1)
    elseif(${${PREFIX}_DEBUG_FOUND})
      set(PACKAGE_FOUND 1)
    else()
      set(PACKAGE_FOUND 0)
    endif()
  else()
    if(${${PREFIX}_FOUND})
      set(PACKAGE_FOUND 1)
    else()
      set(PACKAGE_FOUND 0)
    endif()
  endif()

  # Add the package to the dependency list if found and if dependency is
  # triggered not only for documentation
  if(${PACKAGE_FOUND})
    if(NOT ${COMPILE_TIME_ONLY})
      if(DEFINED PROJECT_DEBUG_POSTFIX AND DEFINED ${PREFIX}_DEBUG)
        _add_to_list_if_not_present(_PKG_CONFIG_REQUIRES_DEBUG
                                    "${PKG_CONFIG_DEBUG_STRING}")
        _add_to_list_if_not_present(_PKG_CONFIG_REQUIRES_OPTIMIZED
                                    "${PKG_CONFIG_STRING}")
      else()
        # Warn the user in case he/she is using alternative libraries for debug
        # but no postfix
        if(NOT DEFINED PROJECT_DEBUG_POSTFIX AND DEFINED ${PREFIX}_DEBUG)
          message(
            AUTHOR_WARNING
              "You are linking with different libraries in debug mode but the
             generated .pc cannot reflect that, it will default to release flags. Consider
             setting PROJECT_DEBUG_POSTFIX to generate different libraries and pc files in
             debug mode.")
        endif()
        _add_to_list_if_not_present(_PKG_CONFIG_REQUIRES "${PKG_CONFIG_STRING}")
      endif()
    else()
      _add_to_list_if_not_present(_PKG_CONFIG_COMPILE_TIME_REQUIRES
                                  "${PKG_CONFIG_STRING}")
    endif()
  endif()

  # Add the package to the cmake dependency list if cpack has been included.
  # This is likely to disappear when Ubuntu 8.04 will disappear.
  if(COMMAND ADD_CMAKE_DEPENDENCY)
    add_cmake_dependency(${PKG_CONFIG_STRING})
  endif(COMMAND ADD_CMAKE_DEPENDENCY)

  if(${${PREFIX}_FOUND})
    message(STATUS "Pkg-config module ${LIBRARY_NAME} v${${PREFIX}_VERSION}"
                   " has been detected with success.")
  endif()
  if(DEFINED ${PREFIX}_DEBUG AND "${${PREFIX}_DEBUG_FOUND}")
    message(
      STATUS
        "Pkg-config module ${LIBRARY_DEBUG_NAME} v${${PREFIX}_DEBUG_VERSION}"
        " has been detected with success.")
  endif()

endmacro(ADD_DEPENDENCY)

# .rst: .. ifmode:: internal
#
# .. command:: _GET_PKG_CONFIG_DEBUG_STRING
#
# Used in ADD_*_DEPENDENCY to get the PKG_CONFIG_DEBUG_STRING argument.  On
# WIN32, if the string is absent but PROJECT_DEBUG_POSTFIX is set, attempts to
# locate a package matching the PROJECT_DEBUG_POSTFIX for debug builds.
#
macro(_GET_PKG_CONFIG_DEBUG_STRING PKG_CONFIG_STRING)
  set(PKG_CONFIG_DEBUG_STRING "")
  foreach(ARG ${ARGN})
    set(PKG_CONFIG_DEBUG_STRING ${ARG})
  endforeach()
  if(WIN32
     AND DEFINED PROJECT_DEBUG_POSTFIX
     AND "${PKG_CONFIG_DEBUG_STRING}" STREQUAL "")
    _parse_pkg_config_string("${PKG_CONFIG_STRING}" LIBRARY_NAME PREFIX)
    string(REGEX
           REPLACE "${LIBRARY_NAME}" "${LIBRARY_NAME}${PROJECT_DEBUG_POSTFIX}"
                   LIBRARY_NAME "${PKG_CONFIG_STRING}")
    pkg_check_modules("${PREFIX}" "${LIBRARY_NAME}")
    if(${PREFIX}_FOUND)
      set(PKG_CONFIG_DEBUG_STRING "${LIBRARY_NAME}")
    endif()
  endif()
endmacro(_GET_PKG_CONFIG_DEBUG_STRING)

# .rst: .. ifmode:: import
#
# .. command:: ADD_REQUIRED_DEPENDENCY (PKG_CONFIG_STRING
# PKG_CONFIG_DEBUG_STRING)
#
# Check for a dependency using pkg-config. Fail if the package cannot be found.
#
# :PKG_CONFIG_STRING: string passed to pkg-config to check the version.
# Typically, this string looks like: ``my-package >= 0.5``
#
# :PKG_CONFIG_DEBUG_STRING: (optional) string passed to pkg-config to check the
# version. The package found this way will be used in place of the first
# provided if the build is happening in DEBUG mode. This string might look like:
# ``my-package_d >= 0.5``
#
# An optional argument can be passed to define an alternate PKG_CONFIG_STRING
# for debug builds. It should follow the same rule as PKG_CONFIG_STRING.
#
macro(ADD_REQUIRED_DEPENDENCY PKG_CONFIG_STRING)
  list(FIND _PKG_CONFIG_REQUIRES "${PKG_CONFIG_STRING}" _index)
  if(${_index} EQUAL -1)
    _get_pkg_config_debug_string("${PKG_CONFIG_STRING}" ${ARGN})
    add_dependency(1 0 ${PKG_CONFIG_STRING} "${PKG_CONFIG_DEBUG_STRING}")
  else()
    # Already found
    message(STATUS "Package ${PKG_CONFIG_STRING} already found.")
  endif()
endmacro(ADD_REQUIRED_DEPENDENCY)

# .rst: .. ifmode:: import
#
# .. command:: ADD_OPTIONAL_DEPENDENCY (PKG_CONFIG_STRING
# PKG_CONFIG_DEBUG_STRING)
#
# Check for a dependency using pkg-config. Quiet if the package cannot be found.
#
# :PKG_CONFIG_STRING: string passed to pkg-config to check the version.
# Typically, this string looks like: ``my-package >= 0.5``
#
# :PKG_CONFIG_DEBUG_STRING: (optional) string passed to pkg-config to check the
# version. The package found this way will be used in place of the first
# provided if the build is happening in DEBUG mode. This string might look like:
# ``my-package_d >= 0.5``
#
# An optional argument can be passed to define an alternate PKG_CONFIG_STRING
# for debug builds. It should follow the same rule as PKG_CONFIG_STRING.
#
macro(ADD_OPTIONAL_DEPENDENCY PKG_CONFIG_STRING)
  _get_pkg_config_debug_string("${PKG_CONFIG_STRING}" ${ARGN})
  add_dependency(0 0 ${PKG_CONFIG_STRING} "${PKG_CONFIG_DEBUG_STRING}")
endmacro(ADD_OPTIONAL_DEPENDENCY)

# .rst: .. ifmode:: import-advanced
#
# .. command:: ADD_COMPILE_DEPENDENCY (PKGCONFIG_STRING)
#
# Check for a dependency using pkg-config. Fail if the package cannot be found.
# The package won't appear as depency inside the \*.pc file of the PROJECT.
#
# :PKG_CONFIG_STRING: string passed to pkg-config to check the version.
# Typically, this string looks like: ``my-package >= 0.5``
#
# :PKG_CONFIG_DEBUG_STRING: (optional) string passed to pkg-config to check the
# version. The package found this way will be used in place of the first
# provided if the build is happening in DEBUG mode.  This string might look
# like: ``my-package_d >= 0.5``
#
macro(ADD_COMPILE_DEPENDENCY PKG_CONFIG_STRING)
  _get_pkg_config_debug_string("${PKG_CONFIG_STRING}" ${ARGN})
  add_dependency(1 1 ${PKG_CONFIG_STRING} "${PKG_CONFIG_DEBUG_STRING}")
endmacro(ADD_COMPILE_DEPENDENCY)

# .rst: .. ifmode:: import-advanced
#
# .. command:: ADD_DOC_DEPENDENCY (PKGCONFIG_STRING)
#
# Alias for :command:`ADD_COMPILE_DEPENDENCY`
#
macro(ADD_DOC_DEPENDENCY PKG_CONFIG_STRING)
  add_compile_dependency(${PKG_CONFIG_STRING})
endmacro(ADD_DOC_DEPENDENCY)

# .rst: .. ifmode:: export
#
# .. command:: PKG_CONFIG_APPEND_LIBRARY_DIR (DIRS)
#
# This macro adds library directories ``DIRS`` in a portable way into the CMake
# file.
#
macro(PKG_CONFIG_APPEND_LIBRARY_DIR DIRS)
  foreach(DIR ${DIRS})
    if(DIR)
      set(_PKG_CONFIG_LIBS
          "${_PKG_CONFIG_LIBS} ${LIBDIR_KW}${DIR}"
          CACHE INTERNAL "")
    endif(DIR)
  endforeach(DIR ${DIRS})
endmacro(PKG_CONFIG_APPEND_LIBRARY_DIR DIR)

# .rst: .. ifmode:: export-advanced
#
# .. command:: PKG_CONFIG_APPEND_CFLAGS_DEBUG (FLAGS)
#
# This macro adds ``FLAGS`` in a portable way into the pkg-config file of the
# debug library.
#
# As such the macro fails if ``PROJECT_DEBUG_POSTFIX`` is not set
#
macro(PKG_CONFIG_APPEND_CFLAGS_DEBUG FLAGS)
  if(NOT DEFINED PROJECT_DEBUG_POSTFIX)
    message(
      FATAL_ERROR
        "You are trying to use PKG_CONFIG_APPEND_CFLAGS_DEBUG on a package that does not have a debug library"
    )
  endif()
  foreach(FLAG ${FLAGS})
    if(FLAG)
      set(_PKG_CONFIG_CFLAGS_DEBUG
          "${_PKG_CONFIG_CFLAGS_DEBUG} ${FLAG}"
          CACHE INTERNAL "")
    endif(FLAG)
  endforeach(FLAG ${FLAGS})
endmacro(PKG_CONFIG_APPEND_CFLAGS_DEBUG FLAGS)

# .rst: .. ifmode:: export-advanced
#
# .. command:: PKG_CONFIG_APPEND_CFLAGS_OPTIMIZED (FLAGS)
#
# This macro adds ``FLAGS`` in a portable way into the pkg-config file of the
# optimized library.
#
# As such the macro fails if ``PROJECT_DEBUG_POSTFIX`` is not set
#
macro(PKG_CONFIG_APPEND_CFLAGS_OPTIMIZED FLAGS)
  if(NOT DEFINED PROJECT_DEBUG_POSTFIX)
    message(
      FATAL_ERROR
        "You are trying to use PKG_CONFIG_APPEND_CFLAGS_OPTIMIZED on a package that does not have a debug library"
    )
  endif()
  foreach(FLAG ${FLAGS})
    if(FLAG)
      set(_PKG_CONFIG_CFLAGS_OPTIMIZED
          "${_PKG_CONFIG_CFLAGS_OPTIMIZED} ${FLAG}"
          CACHE INTERNAL "")
    endif(FLAG)
  endforeach(FLAG ${FLAGS})
endmacro(PKG_CONFIG_APPEND_CFLAGS_OPTIMIZED FLAGS)

# .rst: .. ifmode:: export
#
# .. command:: PKG_CONFIG_APPEND_CFLAGS (FLAGS)
#
# This macro adds ``FLAGS`` in a portable way into the pkg-config file.
#
macro(PKG_CONFIG_APPEND_CFLAGS FLAGS)
  foreach(FLAG ${FLAGS})
    if(FLAG)
      set(_PKG_CONFIG_CFLAGS
          "${_PKG_CONFIG_CFLAGS} ${FLAG}"
          CACHE INTERNAL "")
    endif(FLAG)
  endforeach(FLAG ${FLAGS})
endmacro(PKG_CONFIG_APPEND_CFLAGS)

# .rst: .. ifmode:: export-advanced
#
# .. command:: PKG_CONFIG_APPEND_LIBS_RAW (LIBS)
#
# This macro adds raw value ``LIBS`` in the "Libs:" section of the pkg-config
# file.
#
# **Exception for mac OS X**
#
# In addition to the classical static and dynamic libraries (handled like unix
# does), mac systems can link against frameworks. Frameworks are directories
# gathering headers, libraries, shared resources...
#
# The syntax used to link with a framework is particular, hence a filter is
# added to convert the absolute path to a framework (e.g.
# /Path/to/Sample.framework) into the correct flags (-F/Path/to/ -framework
# Sample).
#
macro(PKG_CONFIG_APPEND_LIBS_RAW LIBS)
  foreach(LIB ${LIBS})
    if(LIB)
      if(APPLE AND ${LIB} MATCHES "\\.framework")
        get_filename_component(framework_PATH ${LIB} PATH)
        get_filename_component(framework_NAME ${LIB} NAME_WE)
        set(_PKG_CONFIG_LIBS
            "${_PKG_CONFIG_LIBS} -F${framework_PATH} -Wl,-framework,${framework_NAME}"
            CACHE INTERNAL "")
      else(APPLE AND ${LIB} MATCHES "\\.framework")
        set(_PKG_CONFIG_LIBS
            "${_PKG_CONFIG_LIBS} ${LIB}"
            CACHE INTERNAL "")
      endif(APPLE AND ${LIB} MATCHES "\\.framework")
    endif(LIB)
  endforeach(LIB ${LIBS})
  string(REPLACE "\n" "" _PKG_CONFIG_LIBS "${_PKG_CONFIG_LIBS}")
endmacro(PKG_CONFIG_APPEND_LIBS_RAW)

# .rst: .. ifmode:: export
#
# .. command:: PKG_CONFIG_APPEND_LIBS (LIBS)
#
# This macro adds libraries in a portable way into the pkg-config file.
#
# Library prefix and suffix is automatically added.
#
# .. note::
#
# If you use :variable:`PROJECT_DEBUG_POSTFIX`, this covers both debug and
# optimized configurations with the correct name for targets affected by the
# postfix.
#
macro(PKG_CONFIG_APPEND_LIBS LIBS)
  foreach(LIB ${LIBS})
    if(LIB)
      # Check if this project is building this library
      if(TARGET ${LIB})
        set(LIB_COMPLETE_NAME ${LIB})
        # If OUTPUT_NAME property is defined, use this for the library name.
        get_property(
          OUTPUT_NAME_SET
          TARGET ${LIB}
          PROPERTY OUTPUT_NAME
          SET)
        if(OUTPUT_NAME_SET)
          get_target_property(OUTPUT_LIB_NAME ${LIB} OUTPUT_NAME)
        endif(OUTPUT_NAME_SET)
        # If SUFFIX property is defined, use it for defining the library name.
        get_property(
          SUFFIX_SET
          TARGET ${LIB}
          PROPERTY SUFFIX
          SET)
        if(SUFFIX_SET)
          get_target_property(LIB_SUFFIX ${LIB} SUFFIX)
        endif(SUFFIX_SET)

        get_property(
          PREFIX_SET
          TARGET ${LIB}
          PROPERTY PREFIX
          SET)
        if(PREFIX_SET)
          get_target_property(LIB_PREFIX ${LIB} PREFIX)
        endif(PREFIX_SET)
        if(OUTPUT_NAME_SET)
          set(LIB_COMPLETE_NAME ${OUTPUT_LIB_NAME})
        else()
          set(LIB_COMPLETE_NAME ${LIB_PREFIX}${LIB}${LIB_SUFFIX})
        endif()
        # Remove lib extension if any
        if(UNIX OR APPLE)
          string(REPLACE ".so" "" LIB_COMPLETE_NAME ${LIB_COMPLETE_NAME})
          string(REPLACE ".dylib" "" LIB_COMPLETE_NAME ${LIB_COMPLETE_NAME})
        endif(UNIX OR APPLE)
        # Single build type generator
        if(DEFINED CMAKE_BUILD_TYPE)
          set(_PKG_CONFIG_LIBS
              "${_PKG_CONFIG_LIBS} ${LIBINCL_KW}${LIB_COMPLETE_NAME}${PKGCONFIG_POSTFIX}${LIB_EXT}"
              CACHE INTERNAL "")
          # Multiple build types generator
        else()
          set(_PKG_CONFIG_LIBS_DEBUG
              "${_PKG_CONFIG_LIBS_DEBUG} ${LIBINCL_KW}${LIB_COMPLETE_NAME}${PKGCONFIG_POSTFIX}${LIB_EXT}"
              CACHE INTERNAL "")
          string(STRIP ${_PKG_CONFIG_LIBS_DEBUG} _PKG_CONFIG_LIBS_DEBUG
          )# To address CMP0004
          set(_PKG_CONFIG_LIBS_OPTIMIZED
              "${_PKG_CONFIG_LIBS_OPTIMIZED} ${LIBINCL_KW}${LIB_COMPLETE_NAME}${LIB_EXT}"
              CACHE INTERNAL "")
          string(STRIP ${_PKG_CONFIG_LIBS_OPTIMIZED} _PKG_CONFIG_LIBS_OPTIMIZED
          )# To address CMP0004
        endif()
      else()
        if(IS_ABSOLUTE ${LIB})
          set(_PKG_CONFIG_LIBS
              "${_PKG_CONFIG_LIBS} ${LIBINCL_ABSKW}${LIB}"
              CACHE INTERNAL "")
        else()
          set(_PKG_CONFIG_LIBS
              "${_PKG_CONFIG_LIBS} ${LIBINCL_KW}${LIB}${LIB_EXT}"
              CACHE INTERNAL "")
        endif()
        string(STRIP ${_PKG_CONFIG_LIBS} _PKG_CONFIG_LIBS) # To address CMP0004
      endif()
    endif(LIB)
  endforeach(LIB ${LIBS})
endmacro(PKG_CONFIG_APPEND_LIBS)

# For internal use only. PKG_CONFIG_USE_LCOMPILE_DEPENDENCY(TARGET DEPENDENCY)
# --------------------------------------------
#
# For user look at PKG_CONFIG_USE_COMPILE_DEPENDENCY
#
# This macro changes the target properties to properly search for headers
# against the required shared libraries when using a dependency detected through
# pkg-config.
#
# I.e. PKG_CONFIG_USE_LCOMPILE_DEPENDENCY(my-binary my-package)
#
macro(PKG_CONFIG_USE_LCOMPILE_DEPENDENCY TARGET PREFIX NO_INCLUDE_SYSTEM)

  if(DEFINED ${PREFIX}_DEBUG_FOUND)
    foreach(FLAG ${${PREFIX}_DEBUG_CFLAGS_OTHER})
      target_compile_options(${TARGET} PUBLIC "$<$<CONFIG:Debug>:${FLAG}>")
    endforeach()
    foreach(FLAG ${${PREFIX}_CFLAGS_OTHER})
      target_compile_options(${TARGET}
                             PUBLIC "$<$<NOT:$<CONFIG:Debug>>:${FLAG}>")
    endforeach()
  else()
    foreach(FLAG ${${PREFIX}_CFLAGS_OTHER})
      target_compile_options(${TARGET} PUBLIC ${FLAG})
    endforeach()
  endif()

  # Include/libraries paths seems to be filtered on Linux, add paths again.
  set(SCOPE "PRIVATE")
  if(PROJECT_USE_KEYWORD_LINK_LIBRARIES)
    set(SCOPE "PUBLIC")
  endif()
  set(SYSTEM "SYSTEM")
  if(NO_INCLUDE_SYSTEM)
    set(SYSTEM "")
  endif()

  target_include_directories(${TARGET} ${SYSTEM} ${SCOPE}
                             ${${PREFIX}_INCLUDE_DIRS})
  if(DEFINED ${PREFIX}_DEBUG_FOUND)
    target_include_directories(${TARGET} ${SYSTEM} ${SCOPE}
                               ${${PREFIX}_DEBUG_INCLUDE_DIRS})
  endif()

endmacro(PKG_CONFIG_USE_LCOMPILE_DEPENDENCY)

macro(_FILTER_LINK_FLAGS TARGET IS_GENERAL IS_DEBUG FLAGS)
  foreach(FLAG ${FLAGS})
    string(FIND "${FLAG}" "/" STARTS_WITH_SLASH)
    string(FIND "${FLAG}" "-" STARTS_WITH_DASH)
    if(NOT WIN32 OR (NOT ${STARTS_WITH_DASH} EQUAL 0
                     AND NOT ${STARTS_WITH_SLASH} EQUAL 0))
      if(${IS_GENERAL})
        target_link_libraries(${TARGET} ${PUBLIC_KEYWORD} ${FLAG})
      elseif(${IS_DEBUG})
        target_link_libraries(${TARGET} ${PUBLIC_KEYWORD} debug ${FLAG})
      else()
        target_link_libraries(${TARGET} ${PUBLIC_KEYWORD} optimized ${FLAG})
      endif()
    endif()
  endforeach()
endmacro()

# Internal use only. _PKG_CONFIG_MANIPULATE_LDFLAGS(TARGET PREFIX CONFIG
# IS_GENERAL IS_DEBUG)
#
macro(_PKG_CONFIG_MANIPULATE_LDFLAGS TARGET PREFIX CONFIG IS_GENERAL IS_DEBUG)
  # Make sure we do not override previous flags
  get_target_property(LDFLAGS ${TARGET} LINK_FLAGS${CONFIG})

  # If there were no previous flags, get rid of the XYFLAGS-NOTFOUND in the
  # variables.
  if(NOT LDFLAGS)
    set(LDFLAGS "")
  endif()

  # Transform semi-colon seperated list in to space separated list.
  foreach(FLAG ${${PREFIX}_LDFLAGS})
    set(LDFLAGS "${LDFLAGS} ${FLAG}")
  endforeach()

  # Update the flags.
  set_target_properties(${TARGET} PROPERTIES LINK_FLAGS${CONFIG} "${LDFLAGS}")
  _filter_link_flags(${TARGET} ${IS_GENERAL} ${IS_DEBUG} "${${PREFIX}_LDFLAGS}")
  _filter_link_flags(${TARGET} ${IS_GENERAL} ${IS_DEBUG}
                     "${${PREFIX}_LDFLAGS_OTHER}")
endmacro(
  _PKG_CONFIG_MANIPULATE_LDFLAGS
  TARGET
  PREFIX
  CONFIG
  IS_GENERAL
  IS_DEBUG)

# Internal use only. PKG_CONFIG_USE_LLINK_DEPENDENCY(TARGET DEPENDENCY)
# --------------------------------------------
#
# For user look at PKG_CONFIG_USE_LINK_DEPENDENCY
#
# This macro changes the target properties to properly search for the required
# shared libraries when using a dependency detected through pkg-config.
#
# I.e. PKG_CONFIG_USE_LLINK_DEPENDENCY(my-binary my-package)
#
macro(PKG_CONFIG_USE_LLINK_DEPENDENCY TARGET PREFIX)

  if(NOT DEFINED ${PREFIX}_DEBUG_FOUND)
    _pkg_config_manipulate_ldflags(${TARGET} ${PREFIX} "" 1 0)
  else()
    # Single build type generators
    if(DEFINED CMAKE_BUILD_TYPE)
      string(TOLOWER "${CMAKE_BUILD_TYPE}" cmake_build_type)
      if("${cmake_build_type}" MATCHES "debug")
        _pkg_config_manipulate_ldflags(${TARGET} "${PREFIX}_DEBUG" "" 1 0)
      else()
        _pkg_config_manipulate_ldflags(${TARGET} ${PREFIX} "" 1 0)
      endif()
      # Multiple build types generators
    else()
      foreach(config ${CMAKE_CONFIGURATION_TYPES})
        string(TOUPPER "_${config}" config_in)
        if(${config_in} MATCHES "_DEBUG")
          _pkg_config_manipulate_ldflags(${TARGET} "${PREFIX}_DEBUG"
                                         "${config_in}" 0 1)
        else()
          _pkg_config_manipulate_ldflags(${TARGET} "${PREFIX}" "${config_in}" 0
                                         0)
        endif()
      endforeach()
    endif()
  endif()

  # Include/libraries paths seems to be filtered on Linux, add paths again.
  link_directories(${${PREFIX}_LIBRARY_DIRS})
  if(DEFINED ${PREFIX}_DEBUG_FOUND)
    link_directories(${${PREFIX}_DEBUG_LIBRARY_DIRS})
  endif()

endmacro(PKG_CONFIG_USE_LLINK_DEPENDENCY)

macro(BUILD_PREFIX_FOR_PKG DEPENDENCY PREFIX)

  # Transform the dependency into a valid variable prefix. 1. replace invalid
  # characters into underscores.
  string(REGEX REPLACE "[^a-zA-Z0-9]" "_" LPREFIX "${DEPENDENCY}")
  # 1. make it uppercase.
  string(TOUPPER "${LPREFIX}" "LPREFIX")

  # Make sure we search for a previously detected package.
  if(NOT DEFINED ${LPREFIX}_FOUND)
    message(
      FATAL_ERROR
        "The package ${DEPENDENCY} has not been detected correctly.\n"
        "Have you called ADD_REQUIRED_DEPENDENCY/ADD_OPTIONAL_DEPENDENCY?")
  endif()
  if(NOT (${LPREFIX}_FOUND OR ${LPREFIX}_DEBUG_FOUND))
    message(FATAL_ERROR "The package ${DEPENDENCY} has not been found.")
  endif()

  set(${PREFIX} ${LPREFIX})

endmacro(BUILD_PREFIX_FOR_PKG)

# .rst: .. ifmode:: import
#
# .. command:: PKG_CONFIG_USE_DEPENDENCY (TARGET DEPENDENCY [NO_INCLUDE_SYSTEM])
#
# This macro changes the target properties to properly search for headers,
# libraries and link against the required shared libraries when using a
# dependency detected through pkg-config. I.e.::
#
# PKG_CONFIG_USE_DEPENDENCY(my-binary my-package)
#
# :TARGET: Target that will be manipulated by this macro
#
# :DEPENDENCY: Dependency that will be used
#
# :NO_INCLUDE_SYSTEM: By default, includes are using the SYSTEM option, this
# option changes this behaviour
#

macro(PKG_CONFIG_USE_DEPENDENCY TARGET DEPENDENCY)
  set(options NO_INCLUDE_SYSTEM)
  set(oneValueArgs)
  set(multiValueArgs)
  cmake_parse_arguments(PKG_CONFIG_USE_DEPENDENCY "${options}"
                        "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  build_prefix_for_pkg(${DEPENDENCY} PREFIX)
  pkg_config_use_lcompile_dependency(
    ${TARGET} ${PREFIX} ${PKG_CONFIG_USE_DEPENDENCY_NO_INCLUDE_SYSTEM})
  pkg_config_use_llink_dependency(${TARGET} ${PREFIX})
endmacro(
  PKG_CONFIG_USE_DEPENDENCY
  TARGET
  DEPENDENCY)

# .rst: .. ifmode:: import-advanced
#
# .. command:: PKG_CONFIG_USE_COMPILE_DEPENDENCY (TARGET DEPENDENCY
# [NO_INCLUDE_SYSTEM])
#
# This macro changes the target properties to properly search for headers
# against the required shared libraries when using a dependency detected through
# pkg-config.
#
# :TARGET: Target that will be manipulated by this macro
#
# :DEPENDENCY: Dependency that will be used
#
# :NO_INCLUDE_SYSTEM: By default, includes are using the SYSTEM option, this
# option changes this behaviour
#
macro(PKG_CONFIG_USE_COMPILE_DEPENDENCY TARGET DEPENDENCY)
  set(options NO_INCLUDE_SYSTEM)
  set(oneValueArgs)
  set(multiValueArgs)
  cmake_parse_arguments(PKG_CONFIG_USE_DEPENDENCY "${options}"
                        "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  build_prefix_for_pkg(${DEPENDENCY} PREFIX)
  pkg_config_use_lcompile_dependency(
    ${TARGET} ${PREFIX} ${PKG_CONFIG_USE_COMPILE_DEPENDENCY_NO_INCLUDE_SYSTEM})
endmacro(
  PKG_CONFIG_USE_COMPILE_DEPENDENCY
  TARGET
  DEPENDENCY)

# .rst: .. ifmode:: import-advanced
#
# .. command:: PKG_CONFIG_USE_LINK_DEPENDENCY (TARGET DEPENDENCY)
#
# This macro changes the target properties to properly search for the required
# shared libraries when using a dependency detected through pkg-config.
#
macro(PKG_CONFIG_USE_LINK_DEPENDENCY TARGET DEPENDENCY)
  build_prefix_for_pkg(${DEPENDENCY} PREFIX)
  pkg_config_use_llink_dependency(${TARGET} ${PREFIX})
endmacro(
  PKG_CONFIG_USE_LINK_DEPENDENCY
  TARGET
  DEPENDENCY)

# .rst: .. ifmode:: import-advanced
#
# .. command:: PKG_CONFIG_ADD_COMPILE_OPTIONS (COMPILE_OPTIONS DEPENDENCY)
#
# This macro adds the compile-time options for a given pkg-config ``DEPENDENCY``
# to a given semi-colon-separated list: ``COMPILE_OPTIONS``. This can be used to
# provide options to CUDA_ADD_LIBRARY for instance, since it does not support
# SET_TARGET_PROPERTIES...
#
macro(PKG_CONFIG_ADD_COMPILE_OPTIONS COMPILE_OPTIONS DEPENDENCY)
  build_prefix_for_pkg(${DEPENDENCY} PREFIX)

  # If there were no previous options
  if(NOT ${COMPILE_OPTIONS})
    set(${COMPILE_OPTIONS} "")
  endif()

  # Append flags
  foreach(FLAG ${${PREFIX}_CFLAGS_OTHER})
    list(APPEND COMPILE_OPTIONS "${FLAG}")
  endforeach()
endmacro(
  PKG_CONFIG_ADD_COMPILE_OPTIONS
  COMPILE_OPTIONS
  DEPENDENCY)
