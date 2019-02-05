# Try to find qpOASES
# in standard prefixes and in ${qpOASES_PREFIX}
# Once done this will define
#  qpOASES_FOUND - System has qpOASES
#  qpOASES_INCLUDE_DIRS - The qpOASES include directories
#  qpOASES_LIBRARIES - The libraries needed to use qpOASES
#  qpOASES_DEFINITIONS - Compiler switches required for using qpOASES

FIND_PATH(qpOASES_INCLUDE_DIR
  NAMES qpOASES.hpp
  PATHS ${qpOASES_PREFIX}
  )
FIND_LIBRARY(qpOASES_LIBRARY
  NAMES libqpOASES.so
  PATHS ${qpOASES_PREFIX}
  )

SET(qpOASES_LIBRARIES ${qpOASES_LIBRARY})
SET(qpOASES_INCLUDE_DIRS ${qpOASES_INCLUDE_DIR})

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(qpOASES DEFAULT_MSG qpOASES_LIBRARY qpOASES_INCLUDE_DIR)
mark_as_advanced(qpOASES_INCLUDE_DIR qpOASES_LIBRARY)
