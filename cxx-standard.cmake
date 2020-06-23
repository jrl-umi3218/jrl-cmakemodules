#
# Copyright (C) 2020 LAAS-CNRS
#
# Author: Guilhem Saurel
#

set(_CXX_STANDARD_SOURCE "${CMAKE_CURRENT_LIST_DIR}/cxx-standard.cpp")

#.rst:
# .. ifmode:: user
#
# .. command:: SET_MINIMAL_CXX_STANDARD
#
#    Ensure that a minimal C++ standard will be used.
#
#    This will check the default standard of the current compiler,
#    and set CMAKE_CXX_STANDARD if necessary. Multiple calls to this
#    macro will keep the highest standard.
#
#    Supported values are 98, 11, 14, 17, and 20.
#
macro(SET_MINIMAL_CXX_STANDARD STANDARD)
  # Get compiler default cxx standard, by printing "__cplusplus" (only once)
  if(NOT DEFINED _COMPILER_DEFAULT_CXX_STANDARD)
    try_run(_cxx_standard_run_status _cxx_standard_build_status
      ${CMAKE_CURRENT_BINARY_DIR} ${_CXX_STANDARD_SOURCE}
      RUN_OUTPUT_VARIABLE _COMPILER_DEFAULT_CXX_STANDARD)
    message(STATUS "current compiler default C++ standard: ${_COMPILER_DEFAULT_CXX_STANDARD}")
  endif()

  # Check if we need to upgrade the current minimum
  if(NOT DEFINED _MINIMAL_CXX_STANDARD
      OR (NOT ${STANDARD} EQUAL "98"
        AND (_MINIMAL_CXX_STANDARD EQUAL "98" OR _MINIMAL_CXX_STANDARD LESS ${STANDARD})))
    set(_MINIMAL_CXX_STANDARD "${STANDARD}" CACHE INTERNAL "")
    message(STATUS "minimal C++ standard upgraded to ${_MINIMAL_CXX_STANDARD}")
  endif()

  # Check if a non-trivial minimum has been requested
  if(DEFINED _MINIMAL_CXX_STANDARD AND NOT _MINIMAL_CXX_STANDARD EQUAL 98)
    # Check that the requested minimum is higher than the compiler default
    # ref https://en.cppreference.com/w/cpp/preprocessor/replace#Predefined_macros for constants
    if(_COMPILER_DEFAULT_CXX_STANDARD EQUAL 199711
        OR (_COMPILER_DEFAULT_CXX_STANDARD EQUAL 201103 AND _MINIMAL_CXX_STANDARD GREATER 11)
        OR (_COMPILER_DEFAULT_CXX_STANDARD EQUAL 201402 AND _MINIMAL_CXX_STANDARD GREATER 14)
        OR (_COMPILER_DEFAULT_CXX_STANDARD EQUAL 201703 AND _MINIMAL_CXX_STANDARD GREATER 17))
      # Check that the requested minimum is higher than any pre-existing CMAKE_CXX_STANDARD
      if(NOT CMAKE_CXX_STANDARD OR CMAKE_CXX_STANDARD EQUAL 98 OR CMAKE_CXX_STANDARD LESS _MINIMAL_CXX_STANDARD)
        set(CMAKE_CXX_STANDARD ${STANDARD})
        message(STATUS "CMAKE_CXX_STANDARD upgraded to ${CMAKE_CXX_STANDARD}")
      endif()
    endif()
  endif()
endmacro()
