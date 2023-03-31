#
# Copyright (C) 2023 LAAS-CNRS
#
# Author: Guilhem Saurel
#

# .rst: .. ifmode:: user
#
# .. command:: REL_INSTALL_PATH(FILE VARIABLE)
#
# Compute the relative path from the installation prefix to FILE. Works for
# relative and absolute FILE, except for absolute paths outside of
# CMAKE_INSTALL_PREFIX.
#
macro(REL_INSTALL_PATH FILE VARIABLE)
  if(IS_ABSOLUTE ${FILE})
    file(RELATIVE_PATH _VARIABLE "${FILE}" ${CMAKE_INSTALL_PREFIX})
    string(REGEX REPLACE "/$" "" ${VARIABLE} "${_VARIABLE}")
  else()
    string(REGEX REPLACE "[^/]+" ".." ${VARIABLE} "${FILE}")
  endif()
endmacro()

# .rst: .. ifmode:: user
#
# .. command:: GET_RELATIVE_RPATH(TARGET_INSTALL_DIR VARIABLE)
#
# Provide INSTALL_RPATH from TARGET_INSTALL_DIR to CMAKE_INSTALL_LIBDIR as
# relative to $ORIGIN / @loader_path. Works for relative and absolute
# TARGET_INSTALL_DIR and CMAKE_INSTALL_LIBDIR, except for absolute paths outside
# of CMAKE_INSTALL_PREFIX. Only on UNIX systems (including APPLE).
#
macro(GET_RELATIVE_RPATH TARGET_INSTALL_DIR VARIABLE)
  if(UNIX)
    if(APPLE)
      set(ORIGIN "@loader_path")
    else()
      set(ORIGIN "\$ORIGIN")
    endif()
    rel_install_path("${TARGET_INSTALL_DIR}" _TGT_INV_REL)
    if(IS_ABSOLUTE ${CMAKE_INSTALL_LIBDIR})
      file(RELATIVE_PATH _LIB_REL "${CMAKE_INSTALL_PREFIX}"
           ${CMAKE_INSTALL_LIBDIR})
    else()
      set(_LIB_REL ${CMAKE_INSTALL_LIBDIR})
    endif()
    set(${VARIABLE} "${ORIGIN}/${_TGT_INV_REL}/${_LIB_REL}")
  endif()
endmacro()
