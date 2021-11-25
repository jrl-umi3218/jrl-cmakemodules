#
#   Copyright 2021 INRIA
#
#   Author: Rohan Budhiraja
#
# Try to quietly find SDFormat, and when found, add dependency.



MACRO(SEARCH_FOR_SDFORMAT)
  SET(SDF_VERSIONS "12" "11" "10" "9")
  LIST(APPEND SDF_VERSIONS "")
  MESSAGE(STATUS "${SDF_VERSIONS}")
  FOREACH(version IN LISTS SDF_VERSIONS)
    FIND_PACKAGE(SDFormat${version} QUIET)
    IF (SDFormat${version}_FOUND)
      SET(SDFormat_FOUND True)
      ADD_PROJECT_DEPENDENCY(SDFormat${version})
      MESSAGE(STATUS "SDFormat${version} Found")
      BREAK()
    ENDIF()
  ENDFOREACH(version)
ENDMACRO(SEARCH_FOR_SDFORMAT)
