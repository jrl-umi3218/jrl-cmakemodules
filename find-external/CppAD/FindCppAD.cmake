#
#   Copyright 2020 CNRS INRIA
#
#   Author: Guilhem Saurel
#

# Try to find cppad
# in standard prefixes and in ${cppad_PREFIX}
# Once done this will define
#  cppad_FOUND - System has cppad
#  cppad_INCLUDE_DIR - The cppad include directories
#  cppad_LIBRARY - The libraries needed to use cppad
#  cppad_DEFINITIONS - Compiler switches required for using cppad

FIND_PATH(cppad_INCLUDE_DIR
  NAMES cppad/configure.hpp
  PATHS ${cppad_PREFIX}
  )
FIND_LIBRARY(cppad_LIBRARY
  NAMES cppad_lib
  PATHS ${cppad_PREFIX}
  )

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(cppad DEFAULT_MSG cppad_LIBRARY cppad_INCLUDE_DIR)
mark_as_advanced(cppad_INCLUDE_DIR cppad_LIBRARY)
