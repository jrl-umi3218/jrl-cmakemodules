# Try to find glpk
# in standard prefixes and in ${glpk_PREFIX}
# Once done this will define
#  glpk_FOUND - System has glpk
#  glpk_INCLUDE_DIRS - The glpk include directories
#  glpk_LIBRARIES - The libraries needed to use glpk
#  glpk_DEFINITIONS - Compiler switches required for using glpk

FIND_PATH(glpk_INCLUDE_DIR
  NAMES glpk.h
  PATHS ${glpk_PREFIX}
  )
FIND_LIBRARY(glpk_LIBRARY
  NAMES libglpk.so
  PATHS ${glpk_PREFIX}
  PATH_SUFFIXES include/glpk
  )

SET(glpk_LIBRARIES ${glpk_LIBRARY})
SET(glpk_INCLUDE_DIRS ${glpk_INCLUDE_DIR})

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(glpk DEFAULT_MSG glpk_LIBRARY glpk_INCLUDE_DIR)
MARK_AS_ADVANCED(glpk_INCLUDE_DIR glpk_LIBRARY)
