# Copyright 2024 CNRS INRIA
#
# Author: Wilson Jallet
#
# Adapted from:
# https://github.com/casadi/casadi/blob/main/cmake/FindIPOPT.cmake, LGPL 3.0
# License
#
# Uses the modern PkgConfig CMake module helpers to find an installed version of
# Ipopt, for which a CMake shared imported library target is created with the
# required includes and compile options in its link interface.
#
find_package(Ipopt CONFIG QUIET)

if(Ipopt_FOUND)
  message(DEBUG "Found Ipopt (using IpoptConfig.cmake or ipopt-config.cmake)")
else()
  find_package(PkgConfig REQUIRED)
  pkg_check_modules(Ipopt REQUIRED ipopt)

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(
    Ipopt
    FAIL_MESSAGE DEFAULT_MSG
    REQUIRED_VARS Ipopt_INCLUDE_DIRS Ipopt_LIBRARIES
    VERSION_VAR Ipopt_VERSION
  )

  message(STATUS "  Ipopt library dirs: ${Ipopt_LIBRARY_DIRS}")
  message(STATUS "  Ipopt include dirs: ${Ipopt_INCLUDE_DIRS}")
  add_library(ipopt SHARED IMPORTED)
  # On Windows, ipopt library is named ipopt-3
  find_library(
    ipopt_lib_path
    NAMES ipopt ipopt-3
    PATHS ${Ipopt_LIBRARY_DIRS}
    REQUIRED
  )
  message(STATUS "  Ipopt library found at ${ipopt_lib_path}")
  set_target_properties(
    ipopt
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${Ipopt_INCLUDE_DIRS}"
      INTERFACE_COMPILE_OPTIONS "${Ipopt_CFLAGS_OTHER}"
      IMPORTED_CONFIGURATIONS "RELEASE"
  )

  if(WIN32)
    set_target_properties(
      ipopt
      PROPERTIES IMPORTED_IMPLIB_RELEASE "${ipopt_lib_path}"
    )
  else()
    set_target_properties(
      ipopt
      PROPERTIES IMPORTED_LOCATION_RELEASE "${ipopt_lib_path}"
    )
  endif()

  add_library(Ipopt::Ipopt ALIAS ipopt)
endif()
