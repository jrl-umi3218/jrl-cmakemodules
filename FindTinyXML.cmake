# Try to find TinyXML
# in standard prefixes and in ${TinyXML_PREFIX}
# Once done this will define
#  TinyXML_FOUND - System has TinyXML
#  TinyXML_INCLUDE_DIRS - The TinyXML include directories
#  TinyXML_LIBRARIES - The libraries needed to use TinyXML
#  TinyXML_DEFINITIONS - Compiler switches required for using TinyXML

FIND_PATH(TinyXML_INCLUDE_DIR
  NAMES tinyxml.h
  PATHS ${TinyXML_PREFIX}
  PATH_SUFFIXES include/tinyxml
  )
FIND_LIBRARY(TinyXML_LIBRARY
  NAMES tinyxml
  PATHS ${TinyXML_PREFIX}
  )

SET(TinyXML_LIBRARIES ${TinyXML_LIBRARY})
SET(TinyXML_INCLUDE_DIRS ${TinyXML_INCLUDE_DIR})

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(TinyXML DEFAULT_MSG TinyXML_LIBRARY TinyXML_INCLUDE_DIR)
MARK_AS_ADVANCED(TinyXML_INCLUDE_DIR TinyXML_LIBRARY)
