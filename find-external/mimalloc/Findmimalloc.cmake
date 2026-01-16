# Copyright 2026 Inria

# This finder can be used on Ubuntu 22.04 where mimallocConfig.cmake is not distributed

find_library(mimalloc_LIBRARY NAMES mimalloc libmimalloc REQUIRED)
find_path(mimalloc_INCLUDE_DIR mimalloc.h REQUIRED)

mark_as_advanced(mimalloc_LIBRARY mimalloc_INCLUDE_DIR)

# read the version from the mimalloc.h file
if(NOT TARGET mimalloc)
  file(READ "${mimalloc_INCLUDE_DIR}/mimalloc.h" mimalloc_h)
  string(
    REGEX MATCH
    "#define[ \t]+MI_MALLOC_VERSION[ \t]+([0-9])([0-9])2"
    _
    ${mimalloc_h}
  )
  set(MIMALLOC_MAJOR_VERSION "${CMAKE_MATCH_1}")
  set(MIMALLOC_MINOR_VERSION "${CMAKE_MATCH_2}")
  set(MIMALLOC_PATCH_VERSION 0)
  set(
    mimalloc_VERSION
    ${MIMALLOC_MAJOR_VERSION}.${MIMALLOC_MINOR_VERSION}.${MIMALLOC_RELEASE_LEVEL}
  )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  mimalloc
  REQUIRED_VARS mimalloc_LIBRARY mimalloc_INCLUDE_DIR
  VERSION_VAR mimalloc_VERSION
)

if(NOT TARGET mimalloc)
  add_library(mimalloc UNKNOWN IMPORTED)
  set_target_properties(
    mimalloc
    PROPERTIES
      IMPORTED_LOCATION ${mimalloc_LIBRARY}
      VERSION ${mimalloc_VERSION}
      INCLUDE_DIRECTORIES ${mimalloc_INCLUDE_DIR}
  )
endif()
