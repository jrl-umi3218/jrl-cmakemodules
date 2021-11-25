#
#   Copyright 2021 INRIA
#
#   Author: Rohan Budhiraja
#
#

# SEARCH_FOR_SDFORMAT
# ----------------------------------
# Try to quietly find SDFormat, and when found, add dependency.
# REQUIRED (Optional):  if REQUIRED is given as argument, and SDFormat is not found,
#                       FATAL_ERROR is generated.
#
MACRO(SEARCH_FOR_SDFORMAT)
  SET(SDF_VERSIONS "12" "11" "10" "9")
  LIST(APPEND SDF_VERSIONS "")
  SET(P_REQUIRED False)
  SET (variadic_args ${ARGN})
  LIST(LENGTH variadic_args variadic_count)
  IF (${variadic_count} GREATER 0)
    LIST(GET variadic_args 0 optional_arg)
    IF(${optional_arg} STREQUAL "REQUIRED")
      SET(P_REQUIRED True)
    ELSE()
      MESSAGE (STATUS "Got an unknown optional arg: ${optional_arg}. Only REQUIRED is recognized.")
    ENDIF ()
  ENDIF()
  FOREACH(version IN LISTS SDF_VERSIONS)
    FIND_PACKAGE(SDFormat${version} QUIET)
    IF (SDFormat${version}_FOUND)
      SET(SDFormat_FOUND True)
      ADD_PROJECT_DEPENDENCY(SDFormat${version})
      MESSAGE(STATUS "SDFormat${version} Found")
      BREAK()
    ENDIF()
  ENDFOREACH(version)
  IF (NOT SDFormat_FOUND)
    IF(P_REQUIRED)
      MESSAGE(FATAL_ERROR "SDFormat required but not found. Accepted versions: ${SDF_VERSIONS}")
    ELSE()
      MESSAGE(STATUS "SDFormat not found. Accepted versions: ${SDF_VERSIONS}")
    ENDIF()
  ENDIF()
ENDMACRO(SEARCH_FOR_SDFORMAT)
