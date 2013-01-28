MACRO(ADD_ROSPACK_DEPENDENCY PKG)
  IF(PKG STREQUAL "")
    MESSAGE(FATAL_ERROR "ADD_ROS_DEPENDENCY invalid call.")
  ENDIF()

  # Transform package name into a valid variable prefix.
  # 1. replace invalid characters into underscores.
  STRING(REGEX REPLACE "[^a-zA-Z0-9]" "_" PREFIX "${PKG}")
  # 2. make it uppercase.
  STRING(TOUPPER "${PREFIX}" "PREFIX")

  SET(${PREFIX}_FOUND 0)

  FIND_PROGRAM(ROSPACK rospack)
  IF(NOT ROSPACK)
    MESSAGE(FATAL_ERROR "failed to find the rospack binary. Is ROS installed?")
  ENDIF()

  MESSAGE(STATUS "Looking for ${PKG} using rospack...")
  EXECUTE_PROCESS(
    COMMAND "${ROSPACK}" find "${PKG}"
    OUTPUT_VARIABLE "${PKG}_ROS_PREFIX"
    ERROR_QUIET)
  IF(NOT ${PKG}_ROS_PREFIX)
    MESSAGE(FATAL_ERROR "Failed to detect ${PKG}.")
  ENDIF()

  SET(${PREFIX}_FOUND 1)
  EXECUTE_PROCESS(
    COMMAND "${ROSPACK}" export "--lang=cpp" "--attrib=cflags" "${PKG}"
    OUTPUT_VARIABLE "${PREFIX}_CFLAGS"
    ERROR_QUIET)
  EXECUTE_PROCESS(
    COMMAND "${ROSPACK}" export "--lang=cpp" "--attrib=lflags" "${PKG}"
    OUTPUT_VARIABLE "${PREFIX}_LIBS"
    ERROR_QUIET)
  STRING(REPLACE "\n" "" ${PREFIX}_CFLAGS "${${PREFIX}_CFLAGS}")
  STRING(REPLACE "\n" "" ${PREFIX}_LIBS "${${PREFIX}_LIBS}")

  # Add flags to package pkg-config file.
  PKG_CONFIG_APPEND_CFLAGS ("${${PREFIX}_CFLAGS}")
  PKG_CONFIG_APPEND_LIBS_RAW ("${${PREFIX}_LIBS}")
ENDMACRO()

MACRO(ROSPACK_USE_DEPENDENCY TARGET PKG)
  IF(PKG STREQUAL "")
    MESSAGE(FATAL_ERROR "ROSPACK_USE_DEPENDENCY invalid call.")
  ENDIF()

  # Transform package name into a valid variable prefix.
  # 1. replace invalid characters into underscores.
  STRING(REGEX REPLACE "[^a-zA-Z0-9]" "_" PREFIX "${PKG}")
  # 2. make it uppercase.
  STRING(TOUPPER "${PREFIX}" "PREFIX")

  # Make sure we do not override previous flags.
  GET_TARGET_PROPERTY(CFLAGS "${TARGET}" COMPILE_FLAGS)
  GET_TARGET_PROPERTY(LDFLAGS "${TARGET}" LINK_FLAGS)

  # If there were no previous flags, get rid of the XYFLAGS-NOTFOUND
  # in the variables.
  IF(NOT CFLAGS)
    SET(CFLAGS "")
  ENDIF()
  IF(NOT LDFLAGS)
    SET(LDFLAGS "")
  ENDIF()

  # Filter out end of line in new flags.
  STRING(REPLACE "\n" "" ${PREFIX}_CFLAGS "${${PREFIX}_CFLAGS}")
  STRING(REPLACE "\n" "" ${PREFIX}_LIBS "${${PREFIX}_LIBS}")

  # Append new flags.
  SET(CFLAGS "${CFLAGS} ${${PREFIX}_CFLAGS}")
  SET(LDFLAGS "${LDFLAGS} ${${PREFIX}_LIBS}")

  # Update the flags.
  SET_TARGET_PROPERTIES("${TARGET}"
    PROPERTIES COMPILE_FLAGS "${CFLAGS}" LINK_FLAGS "${LDFLAGS}")
ENDMACRO()
