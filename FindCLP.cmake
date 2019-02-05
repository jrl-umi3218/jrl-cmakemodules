# Try to find CLP
# in standard prefixes and in ${CLP_PREFIX}
# Once done this will define
#  CLP_FOUND - System has CLP
#  CLP_INCLUDE_DIRS - The CLP include directories
#  CLP_LIBRARIES - The libraries needed to use CLP
#  CLP_DEFINITIONS - Compiler switches required for using CLP

FIND_PATH(CLP_INCLUDE_DIR
  NAMES coin/ClpSimplex.hpp
  PATHS ${CLP_PREFIX}
  )
FIND_LIBRARY(CLP_LIBRARY
  NAMES libclp.so
  PATHS ${CLP_PREFIX}
  )

SET(CLP_LIBRARIES ${CLP_LIBRARY})
SET(CLP_INCLUDE_DIRS ${CLP_INCLUDE_DIR})

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(CLP DEFAULT_MSG CLP_LIBRARY CLP_INCLUDE_DIR)
MARK_AS_ADVANCED(CLP_INCLUDE_DIR CLP_LIBRARY)
