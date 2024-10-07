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
  find_package(PkgConfig QUIET)
  if(NOT PKG_CONFIG_FOUND)
    message(FATAL_ERROR "pkg-config not found!")
  endif()
  pkg_check_modules(Ipopt REQUIRED ipopt)

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(
    Ipopt
    FAIL_MESSAGE DEFAULT_MSG
    REQUIRED_VARS Ipopt_INCLUDE_DIRS Ipopt_LIBRARIES
    VERSION_VAR Ipopt_VERSION)

  message(STATUS "  Ipopt library dirs: ${Ipopt_LIBRARY_DIRS}")
  message(STATUS "  Ipopt include dirs: ${Ipopt_INCLUDE_DIRS}")
  add_library(ipopt SHARED IMPORTED)
  find_library(
    ipopt_lib_path
    NAMES ipopt
    PATHS ${Ipopt_LIBRARY_DIRS})
  message(STATUS "  Ipopt library ipopt found at ${ipopt_lib_path}")
  set_target_properties(ipopt PROPERTIES IMPORTED_LOCATION ${ipopt_lib_path})
  target_include_directories(ipopt INTERFACE ${Ipopt_INCLUDE_DIRS})

  if(${CMAKE_CXX_COMPILER_ID} STREQUAL "MSVC")

  else()
    target_compile_definitions(ipopt INTERFACE HAVE_CSTDDEF)
  endif()
  target_compile_options(ipopt INTERFACE ${Ipopt_CFLAGS_OTHER})

  add_library(Ipopt::Ipopt ALIAS ipopt)
endif()
