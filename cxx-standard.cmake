#
# Copyright (C) 2020 LAAS-CNRS
#
# Author: Guilhem Saurel
#

#.rst:
# .. ifmode:: internal
#
#   .. variable:: ENFORCE_MINIMAL_CXX_STANDARD
#
#      When this is ON, every call to :cmake:command:`CHECK_MINIMAL_CXX_STANDARD` updates the :cmake:variable:`CMAKE_CXX_STANDARD`.
option(ENFORCE_MINIMAL_CXX_STANDARD "Set CMAKE_CXX_STANDARD if a dependency require it" OFF)

#.rst:
# .. ifmode:: user
#
#   .. command:: CHECK_MINIMAL_CXX_STANDARD(STANDARD [ENFORCE])
#
#      Ensure that a minimal C++ standard will be used.
#
#      This will check the default standard of the current compiler,
#      and set :cmake:variable:`CMAKE_CXX_STANDARD` if necessary, and `ENFORCE` is provided,
#      or :cmake:variable:`ENFORCE_MINIMAL_CXX_STANDARD` is `ON`.
#      Multiple calls to this macro will keep the highest standard.
#
#      Supported values are 98, 11, 14, 17, and 20.
#
macro(CHECK_MINIMAL_CXX_STANDARD STANDARD)
  set(options ENFORCE)
  set(oneValueArgs)
  set(multiValueArgs)
  cmake_parse_arguments(MINIMAL_CXX_STANDARD "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # Get compiler default cxx standard, by printing "__cplusplus" (only once)
  if(NOT DEFINED _COMPILER_DEFAULT_CXX_STANDARD AND (NOT CMAKE_CROSSCOMPILING OR (CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)))
    if(MSVC)
      # See https://devblogs.microsoft.com/cppblog/msvc-now-correctly-reports-__cplusplus/
      string(APPEND CMAKE_CXX_FLAGS " /Zc:__cplusplus")
    endif()
    write_file(${CMAKE_CURRENT_BINARY_DIR}/cmake/tmp-cxx-standard.cpp "#include <iostream>\nint main(){std::cout << __cplusplus << std::endl;return 0;}")
    try_run(_cxx_standard_run_status _cxx_standard_build_status
      ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_BINARY_DIR}/cmake/tmp-cxx-standard.cpp
      RUN_OUTPUT_VARIABLE _COMPILER_DEFAULT_CXX_STANDARD)
    if(_cxx_standard_run_status EQUAL FAILED_TO_RUN OR _cxx_standard_build_status EQUAL FALSE)
      message(WARNING "Impossible to build or run the script to retrive the _COMPILER_DEFAULT_CXX_STANDARD quantity from current compiler. Setting _COMPILER_DEFAULT_CXX_STANDARD to 199711")
      set(_COMPILER_DEFAULT_CXX_STANDARD "199711")
    endif()
    string(STRIP "${_COMPILER_DEFAULT_CXX_STANDARD}" _COMPILER_DEFAULT_CXX_STANDARD)
    message(STATUS "Default C++ standard: ${_COMPILER_DEFAULT_CXX_STANDARD}")
  endif()

  # Check if we need to upgrade the current minimum
  if(NOT DEFINED _MINIMAL_CXX_STANDARD
      OR (NOT ${STANDARD} EQUAL "98"
        AND (_MINIMAL_CXX_STANDARD EQUAL "98" OR _MINIMAL_CXX_STANDARD LESS ${STANDARD})))
    set(_MINIMAL_CXX_STANDARD "${STANDARD}" CACHE INTERNAL "")
    message(STATUS "Minimal C++ standard upgraded to ${_MINIMAL_CXX_STANDARD}")
  endif()

  # Check if a non-trivial minimum has been requested
  if(DEFINED _MINIMAL_CXX_STANDARD AND NOT _MINIMAL_CXX_STANDARD EQUAL 98)

    if (DEFINED CMAKE_CXX_STANDARD)
      set(_CURRENT_STANDARD ${CMAKE_CXX_STANDARD})
    elseif(DEFINED _COMPILER_DEFAULT_CXX_STANDARD)
      # ref https://en.cppreference.com/w/cpp/preprocessor/replace#Predefined_macros for constants
      if(_COMPILER_DEFAULT_CXX_STANDARD EQUAL 199711)
        set(_CURRENT_STANDARD 98)
      elseif(_COMPILER_DEFAULT_CXX_STANDARD EQUAL 201103)
        set(_CURRENT_STANDARD 11)
      elseif(_COMPILER_DEFAULT_CXX_STANDARD EQUAL 201402)
        set(_CURRENT_STANDARD 14)
      elseif(_COMPILER_DEFAULT_CXX_STANDARD EQUAL 201703)
        set(_CURRENT_STANDARD 17)
      # C++20: g++-9 defines c++2a with literal 201709, g++-11 & clang-10 define c++2a with literal 202002
      elseif(_COMPILER_DEFAULT_CXX_STANDARD EQUAL 201709 OR _COMPILER_DEFAULT_CXX_STANDARD EQUAL 202002)
        set(_CURRENT_STANDARD 20)
      else()
        message(FATAL_ERROR "Unknown current C++ standard ${_COMPILER_DEFAULT_CXX_STANDARD} while trying to check for >= ${_MINIMAL_CXX_STANDARD}")
      endif()
    else()
      set(_CURRENT_STANDARD 98)
    endif()

    # Check that the requested minimum is higher than the currently selected
    if(_CURRENT_STANDARD EQUAL 98 OR _CURRENT_STANDARD LESS _MINIMAL_CXX_STANDARD)
      message(STATUS "Incompatible C++ standard detected: upgrade required from ${_CURRENT_STANDARD} to >= ${_MINIMAL_CXX_STANDARD}")
      # Check that the requested minimum is higher than any pre-existing CMAKE_CXX_STANDARD
      if(NOT CMAKE_CXX_STANDARD OR CMAKE_CXX_STANDARD EQUAL 98 OR CMAKE_CXX_STANDARD LESS _MINIMAL_CXX_STANDARD)
        # Throw error if a specific version is required and the currently desired one is incompatible
        if(CMAKE_CXX_STANDARD_REQUIRED)
          message(FATAL_ERROR "CMAKE_CXX_STANDARD_REQUIRED set - cannot upgrade incompatible standard")
        endif()
        # Enforcing a standard version is required - check if we can upgrade automatically
        if(ENFORCE_MINIMAL_CXX_STANDARD OR MINIMAL_CXX_STANDARD_ENFORCE)
          set(CMAKE_CXX_STANDARD ${_MINIMAL_CXX_STANDARD})
          message(AUTHOR_WARNING "CMAKE_CXX_STANDARD automatically upgraded from ${_CURRENT_STANDARD} to ${CMAKE_CXX_STANDARD}")
        else()
          message(FATAL_ERROR "CMAKE_CXX_STANDARD upgrade from ${_CURRENT_STANDARD} to >= ${_MINIMAL_CXX_STANDARD} required")
        endif()
      endif()
    else()  # requested minimum is higher than the currently selected
      message(STATUS "C++ standard sufficient: Minimal required ${_MINIMAL_CXX_STANDARD}, currently defined: ${_CURRENT_STANDARD}")
    endif()  # requested minimum is higher than the currently selected
  endif()
endmacro()
