#
# Copyright 2021 INRIA
#
# Author: Rohan Budhiraja
#

# SEARCH_FOR_SDFORMAT
# ----------------------------------
# Try to quietly find SDFormat, and when found, add dependency. REQUIRED
# (Optional):  if REQUIRED is given as argument, and SDFormat is not found,
# FATAL_ERROR is generated.
#
macro(SEARCH_FOR_SDFORMAT)
  set(SDF_VERSIONS "12" "11" "10" "9")
  list(APPEND SDF_VERSIONS "")
  set(P_REQUIRED False)
  set(variadic_args ${ARGN})
  list(LENGTH variadic_args variadic_count)
  if(${variadic_count} GREATER 0)
    list(GET variadic_args 0 optional_arg)
    if(${optional_arg} STREQUAL "REQUIRED")
      set(P_REQUIRED True)
    else()
      message(
        STATUS
          "Got an unknown optional arg: ${optional_arg}. Only REQUIRED is recognized."
      )
    endif()
  endif()
  foreach(version IN LISTS SDF_VERSIONS)
    find_package(SDFormat${version} QUIET)
    if(SDFormat${version}_FOUND)
      set(SDFormat_FOUND True)
      add_project_dependency(SDFormat${version})
      message(STATUS "SDFormat${version} Found")
      break()
    endif()
  endforeach(version)
  if(NOT SDFormat_FOUND)
    if(P_REQUIRED)
      message(
        FATAL_ERROR
          "SDFormat required but not found. Accepted versions: ${SDF_VERSIONS}")
    else()
      message(STATUS "SDFormat not found. Accepted versions: ${SDF_VERSIONS}")
    endif()
  endif()
endmacro(SEARCH_FOR_SDFORMAT)
