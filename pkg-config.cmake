# Copyright (C) 2010 Thomas Moulard, JRL, CNRS/AIST.
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

INCLUDE(cmake/shared-library.cmake)

FIND_PACKAGE(PkgConfig)

# Additional pkg-config variables whose value will be imported
# during the dependency check.
SET(PKG_CONFIG_ADDITIONAL_VARIABLES docdir doxygendocdir)

# _SETUP_PROJECT_PKG_CONFIG
# -------------------------
#
# Prepare pkg-config pc file generation step.
#
MACRO(_SETUP_PROJECT_PKG_CONFIG)
  # Pkg-config related commands.
  SET(PKG_CONFIG_PREFIX "${CMAKE_INSTALL_PREFIX}")
  SET(PKG_CONFIG_EXEC_PREFIX "${PKG_CONFIG_PREFIX}")
  SET(PKG_CONFIG_LIBDIR "${PKG_CONFIG_EXEC_PREFIX}/lib")
  SET(PKG_CONFIG_INCLUDEDIR "${PKG_CONFIG_PREFIX}/include")
  SET(PKG_CONFIG_DATAROOTDIR "${PKG_CONFIG_PREFIX}/share")
  SET(PKG_CONFIG_DOCDIR "${PKG_CONFIG_DATAROOTDIR}/doc/${PROJECT_NAME}")
  SET(PKG_CONFIG_DOXYGENDOCDIR "${PKG_CONFIG_DOCDIR}/doxygen-html")

  SET(PKG_CONFIG_PROJECT_NAME "${PROJECT_NAME}")
  SET(PKG_CONFIG_DESCRIPTION "${PROJECT_DESCRIPTION}")
  SET(PKG_CONFIG_URL "${PROJECT_URL}")
  SET(PKG_CONFIG_VERSION "${PROJECT_VERSION}")
  SET(PKG_CONFIG_REQUIRES "")
  SET(PKG_CONFIG_CONFLICTS "")
  SET(PKG_CONFIG_LIBS "${LIBDIR_KW}${CMAKE_INSTALL_PREFIX}/lib")
  SET(PKG_CONFIG_LIBS_PRIVATE "")
  SET(PKG_CONFIG_CFLAGS "-I${CMAKE_INSTALL_PREFIX}/include")

  SET(PKG_CONFIG_EXTRA "")

  # Where to install the pkg-config file?
  SET(PKG_CONFIG_DIR "${PKG_CONFIG_LIBDIR}/pkgconfig")

  # Watch variables.
  LIST(APPEND LOGGING_WATCHED_VARIABLES
    PKG_CONFIG_FOUND
    PKG_CONFIG_EXECUTABLE
    PKG_CONFIG_PREFIX
    PKG_CONFIG_EXEC_PREFIX
    PKG_CONFIG_LIBDIR
    PKG_CONFIG_INCLUDEDIR
    PKG_CONFIG_DATAROOTDIR
    PKG_CONFIG_DOCDIR
    PKG_CONFIG_DOXYGENDOCDIR
    PKG_CONFIG_PROJECT_NAME
    PKG_CONFIG_DESCRIPTION
    PKG_CONFIG_URL
    PKG_CONFIG_VERSION
    PKG_CONFIG_REQUIRES
    PKG_CONFIG_CONFLICTS
    PKG_CONFIG_LIBS
    PKG_CONFIG_LIBS_PRIVATE
    PKG_CONFIG_CFLAGS
    PKG_CONFIG_EXTRA
    )

  # Install it.
  INSTALL(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc"
    DESTINATION "${PKG_CONFIG_DIR}"
    PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE)
ENDMACRO(_SETUP_PROJECT_PKG_CONFIG)


# _SETUP_PROJECT_PKG_CONFIG_FINALIZE
# ----------------------------------
#
# Post-processing of the pkg-config step.
#
# The pkg-config file has to be generated at the end to allow end-user
# defined variables replacement.
#
MACRO(_SETUP_PROJECT_PKG_CONFIG_FINALIZE)
  # Generate the pkg-config file.
  CONFIGURE_FILE(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/pkg-config.pc.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc"
    )
ENDMACRO(_SETUP_PROJECT_PKG_CONFIG_FINALIZE)


# ADD_DEPENDENCY(PREFIX P_REQUIRED PKGCONFIG_STRING)
# ------------------------------------------------
#
# Check for a dependency using pkg-config. Fail if the package cannot
# be found.
#
# P_REQUIRED : if set to 1 the package is required, otherwise it consider
#              as optional. 
#              WARNING for optional package: 
#              if the package is detected its compile
#              and linking options are still put in the required fields
#              of the generated pc file. Indeed from the binary viewpoint
#              the package becomes required.
#
# PKG_CONFIG_STRING	: string passed to pkg-config to check the version.
#			  Typically, this string looks like:
#                         ``my-package >= 0.5''
#

MACRO(ADD_DEPENDENCY P_REQUIRED PKG_CONFIG_STRING)
  # Retrieve the left part of the equation to get package name.
  STRING(REGEX MATCH "[^<>= ]+" LIBRARY_NAME "${PKG_CONFIG_STRING}")
  # And transform it into a valid variable prefix.
  # 1. replace invalid characters into underscores.
  STRING(REGEX REPLACE "[^a-zA-Z0-9]" "_" PREFIX "${LIBRARY_NAME}")
  # 2. make it uppercase.
  STRING(TOUPPER "${PREFIX}" "PREFIX")

  # Force redetection each time CMake is launched.
  # Rationale: these values are *NEVER* manually set, so information is never
  # lost by overriding them. Moreover, changes in the pkg-config files are
  # not seen as long as the cache is not destroyed, even if the .pc file
  # is changed. This is a BAD behavior.
  SET(${PREFIX}_FOUND 0)

  # Search for the package.
  IF(${P_REQUIRED})
    MESSAGE(STATUS "${PKG_CONFIG_STRING} is required.")
    PKG_CHECK_MODULES("${PREFIX}" REQUIRED "${PKG_CONFIG_STRING}")
  ELSEIF(${P_REQUIRED})
    MESSAGE(STATUS "${PKG_CONFIG_STRING} is optional.")
    PKG_CHECK_MODULES("${PREFIX}" OPTIONAL "${PKG_CONFIG_STRING}")
  ENDIF(${P_REQUIRED})

  # Watch variables.
  LIST(APPEND LOGGING_WATCHED_VARIABLES
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
    )

  # Get the values of additional variables.
  FOREACH(VARIABLE ${PKG_CONFIG_ADDITIONAL_VARIABLES})
    # Upper-case version of the variable for CMake variable generation.
    STRING(TOUPPER "${VARIABLE}" "VARIABLE_UC")
    EXEC_PROGRAM(
      "${PKG_CONFIG_EXECUTABLE}" ARGS
      "--variable=${VARIABLE}" "${LIBRARY_NAME}"
      OUTPUT_VARIABLE "${PREFIX}_${VARIABLE_UC}")

    # Watch additional variables.
    LIST(APPEND LOGGING_WATCHED_VARIABLES ${PREFIX}_${VARIABLE_UC})
  ENDFOREACH(VARIABLE)

  #FIXME: spaces are replaced by semi-colon by mistakes, revert the change.
  #I cannot see why CMake is doing that...
  STRING(REPLACE ";" " " PKG_CONFIG_STRING "${PKG_CONFIG_STRING}")

  # Add the package to the dependency list.
  _ADD_TO_LIST(PKG_CONFIG_REQUIRES "${PKG_CONFIG_STRING}" ",")

  MESSAGE(STATUS
    "Pkg-config module ${LIBRARY_NAME} v${${PREFIX}_VERSION}"
    " has been detected with success.")
ENDMACRO(ADD_DEPENDENCY)

# ADD_REQUIRED_DEPENDENCY(PREFIX PKGCONFIG_STRING)
# ------------------------------------------------
#
# Check for a dependency using pkg-config. Fail if the package cannot
# be found.
#
# PKG_CONFIG_STRING	: string passed to pkg-config to check the version.
#			  Typically, this string looks like:
#                         ``my-package >= 0.5''
#
MACRO(ADD_REQUIRED_DEPENDENCY PKG_CONFIG_STRING)
  ADD_DEPENDENCY(1 ${PKG_CONFIG_STRING})
ENDMACRO(ADD_REQUIRED_DEPENDENCY)

# ADD_OPTIONAL_DEPENDENCY(PREFIX PKGCONFIG_STRING)
# ------------------------------------------------
#
# Check for a dependency using pkg-config. Quiet if the package cannot
# be found.
#
# PKG_CONFIG_STRING	: string passed to pkg-config to check the version.
#			  Typically, this string looks like:
#                         ``my-package >= 0.5''
#
MACRO(ADD_OPTIONAL_DEPENDENCY PKG_CONFIG_STRING)
  ADD_DEPENDENCY(0 ${PKG_CONFIG_STRING})
ENDMACRO(ADD_OPTIONAL_DEPENDENCY)

# PKG_CONFIG_APPEND_LIBRARY_DIR
# -----------------------------
#
# This macro adds library directories in a portable way
# into the CMake file.
MACRO(PKG_CONFIG_APPEND_LIBRARY_DIR DIRS)
  FOREACH(DIR ${DIRS})
    IF(DIR)
      SET(PKG_CONFIG_LIBS "${PKG_CONFIG_LIBS} ${LIBDIR_KW}${DIR}")
    ENDIF(DIR)
  ENDFOREACH(DIR ${DIRS})
ENDMACRO(PKG_CONFIG_APPEND_LIBRARY_DIR DIR)


# PKG_CONFIG_APPEND_CFLAGS
# ------------------------
#
# This macro adds CFLAGS in a portable way into the pkg-config file.
#
MACRO(PKG_CONFIG_APPEND_CFLAGS FLAGS)
  FOREACH(FLAG ${FLAGS})
    IF(FLAG)
      SET(PKG_CONFIG_CFLAGS "${PKG_CONFIG_CFLAGS} ${FLAG}")
    ENDIF(FLAG)
  ENDFOREACH(FLAG ${FLAGS})
ENDMACRO(PKG_CONFIG_APPEND_CFLAGS)


# PKG_CONFIG_APPEND_LIBS_RAW
# ----------------------------
#
# This macro adds raw value in the "Libs:" into the pkg-config file.
#
MACRO(PKG_CONFIG_APPEND_LIBS_RAW LIBS)
  FOREACH(LIB ${LIBS})
    IF(LIB)
      SET(PKG_CONFIG_LIBS "${PKG_CONFIG_LIBS} ${LIB}")
    ENDIF(LIB)
  ENDFOREACH(LIB ${LIBS})
ENDMACRO(PKG_CONFIG_APPEND_LIBS_RAW)


# PKG_CONFIG_APPEND_LIBS
# ----------------------
#
# This macro adds libraries in a portable way into the pkg-config
# file.
#
# Library prefix and suffix is automatically added.
#
MACRO(PKG_CONFIG_APPEND_LIBS LIBS)
  FOREACH(LIB ${LIBS})
    IF(LIB)
      SET(PKG_CONFIG_LIBS "${PKG_CONFIG_LIBS} ${LIBINCL_KW}${LIB}${LIB_EXT}")
    ENDIF(LIB)
  ENDFOREACH(LIB ${LIBS})
ENDMACRO(PKG_CONFIG_APPEND_LIBS)
