#
#   Copyright 2020 CNRS INRIA
#
#   Author: Guilhem Saurel
#

# Try to find cppadcg
# in standard prefixes and in ${cppadcg_PREFIX}
# Once done this will define
#  cppadcg_FOUND - System has cppadcg
#  cppadcg_INCLUDE_DIR - The cppadcg include directories

FIND_PATH(cppadcg_INCLUDE_DIR
  NAMES cppad/cg.hpp
  PATHS ${cppadcg_PREFIX}
  )

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(cppadcg DEFAULT_MSG cppadcg_INCLUDE_DIR)
mark_as_advanced(cppadcg_INCLUDE_DIR)
