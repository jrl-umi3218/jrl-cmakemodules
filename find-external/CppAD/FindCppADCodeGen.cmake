#
#   Copyright 2020 CNRS
#
#   Author: Guilhem Saurel
#

# Try to find CppADCodeGen
# in standard prefixes and in ${CppADCodeGen_PREFIX}
# Once done this will define
#  CppADCodeGen_FOUND - System has CppADCodeGen
#  CppADCodeGen_INCLUDE_DIRS - The CppADCodeGen include directories

FIND_PATH(CppADCodeGen_INCLUDE_DIR
  NAMES cppad/cg.hpp
  PATHS ${CppADCodeGen_PREFIX}
  )

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(CppADCodeGen DEFAULT_MSG CppADCodeGen_INCLUDE_DIR)
mark_as_advanced(CppADCodeGen_INCLUDE_DIR)
