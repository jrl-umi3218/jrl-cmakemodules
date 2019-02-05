# Try to find libcdd
# in standard prefixes and in ${CDD_PREFIX}
# Once done this will define
#  CDD_FOUND - System has CDD
#  CDD_INCLUDE_DIRS - The CDD include directories
#  CDD_LIBRARIES - The libraries needed to use CDD
#  CDD_DEFINITIONS - Compiler switches required for using CDD

FIND_PATH(CDD_INCLUDE_DIR
  NAMES cdd.h cddmp.h
  PATHS ${CDD_PREFIX}
  PATH_SUFFIXES include/cdd include/cddlib
  )
FIND_LIBRARY(CDD_LIBRARY
  NAMES libcdd.so
  PATHS ${CDD_PREFIX}
  )

SET(CDD_LIBRARIES ${CDD_LIBRARY})
SET(CDD_INCLUDE_DIRS ${CDD_INCLUDE_DIR})

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(CDD DEFAULT_MSG CDD_LIBRARY CDD_INCLUDE_DIR)
mark_as_advanced(CDD_INCLUDE_DIR CDD_LIBRARY)
