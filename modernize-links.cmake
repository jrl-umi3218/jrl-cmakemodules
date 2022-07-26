#
# Copyright (C) 2022 LAAS-CNRS
#
# Author: Guilhem Saurel
#

# .rst: .. ifmode:: user
#
# .. command:: MODERNIZE_TARGET_LINK_LIBRARIES(target SCOPE
# <INTERFACE|PUBLIC|PRIVATE> TARGETS [targets...] LIBRARIES [libraries...]
# INCLUDE_DIRS [include_dirs...])
#
# link "target" to modern "targets" if they are already defined, or fall back to
# old-school "libraries" and "include_dirs"
#

macro(MODERNIZE_TARGET_LINK_LIBRARIES target)
  set(options)
  set(oneValueArgs SCOPE)
  set(multiValueArgs TARGETS LIBRARIES INCLUDE_DIRS)
  cmake_parse_arguments(MODERNIZE_LINK "${options}" "${oneValueArgs}"
                        "${multiValueArgs}" ${ARGN})

  set(_targets_available TRUE)
  foreach(_tgt ${MODERNIZE_LINK_TARGETS})
    if(NOT TARGET ${_tgt})
      message(
        VERBOSE
        "${_tgt} is not available. Falling back to old-school links to libraries / include_dirs"
      )
      set(_targets_available FALSE)
    endif()
  endforeach()

  if(_targets_available)
    target_link_libraries(${target} ${MODERNIZE_LINK_SCOPE}
                          ${MODERNIZE_LINK_TARGETS})
  else()
    target_link_libraries(${target} ${MODERNIZE_LINK_SCOPE}
                          ${MODERNIZE_LINK_LIBRARIES})
    target_include_directories(${target} SYSTEM ${MODERNIZE_LINK_SCOPE}
                               ${MODERNIZE_LINK_INCLUDE_DIRS})
  endif()
endmacro()
