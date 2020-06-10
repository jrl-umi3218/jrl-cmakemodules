#
#   Copyright 2020 CNRS
#
#   Author: Guilhem Saurel
#

# Try to find CppAD
# in standard prefixes and in ${CppAD_PREFIX}
# Once done this will define
#  CppAD_FOUND - System has CppAD
#  CppAD_INCLUDE_DIRS - The CppAD include directories
#  CppAD_LIBRARIES - The libraries needed to use CppAD
#  CppAD_DEFINITIONS - Compiler switches required for using CppAD

FIND_PATH(CppAD_INCLUDE_DIR
  NAMES cppad/configure.hpp
  PATHS ${CppAD_PREFIX}
  )
FIND_LIBRARY(CppAD_LIBRARY
  NAMES cppad_lib
  PATHS ${CppAD_PREFIX}
  )

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(CppAD DEFAULT_MSG CppAD_LIBRARY CppAD_INCLUDE_DIR)
mark_as_advanced(CppAD_INCLUDE_DIR CppAD_LIBRARY)
