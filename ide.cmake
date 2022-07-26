# Copyright (C) 2017-2019 LAAS-CNRS, JRL AIST-CNRS, INRIA.
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.

function(LARGEST_COMMON_PREFIX a b prefix)
  string(LENGTH ${a} len_a)
  string(LENGTH ${b} len_b)

  if(${len_a} LESS ${len_b})
    set(len ${len_a})
  else()
    set(len ${len_b})
  endif()

  set(${prefix}
      ""
      PARENT_SCOPE)
  foreach(size RANGE 1 ${len})
    string(SUBSTRING ${a} 0 ${size} sub_a)
    string(SUBSTRING ${b} 0 ${size} sub_b)

    if(${sub_a} STREQUAL ${sub_b})
      set(${prefix}
          ${sub_a}
          PARENT_SCOPE)
    else()
      break()
    endif()
  endforeach()
endfunction()

function(ADD_GROUP GROUP_NAME FILENAMES)
  set(REDUCED_FILENAMES)
  foreach(filename ${${FILENAMES}})
    get_filename_component(filenamePath ${filename} PATH)
    get_filename_component(filenameName ${filename} NAME)
    string(REGEX REPLACE "${PROJECT_BINARY_DIR}" "" filenamePath
                         "${filenamePath}/")
    string(REGEX REPLACE "${PROJECT_SOURCE_DIR}" "" filenamePath
                         "${filenamePath}/")
    string(REGEX REPLACE "//" "/" filenamePath ${filenamePath})
    list(APPEND REDUCED_FILENAMES ${filenamePath})
  endforeach()

  # Find the largest common prefix
  list(LENGTH REDUCED_FILENAMES num_files)
  math(EXPR max_id "${num_files}-1")
  if(${num_files} GREATER 2)
    list(GET REDUCED_FILENAMES 0 str_a)
    foreach(id RANGE 1 ${max_id})
      list(GET REDUCED_FILENAMES ${id} str_b)
      largest_common_prefix(${str_a} ${str_b} prefix)
      set(str_a ${prefix})
      if("${str_a}" STREQUAL "")
        break()
      endif()
    endforeach()
  else()
    set(prefix "")
  endif()

  foreach(id RANGE 0 ${max_id})
    list(GET ${FILENAMES} ${id} filename)
    list(GET REDUCED_FILENAMES ${id} filenamePath)
    if(NOT ("${prefix}" STREQUAL ""))
      string(REGEX REPLACE "${prefix}" "" filenamePath "${filenamePath}")
    endif()
    if(NOT ("${filenamePath}" STREQUAL ""))
      string(REGEX REPLACE "/" "\\\\" filenamePath ${filenamePath})
      source_group("${GROUP_NAME}\\${filenamePath}" FILES ${filename})
    else()
      source_group("${GROUP_NAME}" FILES ${filename})
    endif()
  endforeach()
endfunction(ADD_GROUP)

# ADD_HEADER_GROUP
# ----------------
#
# Add FILENAMES to "Header Files" group when using IDE Cmake Generator
#
macro(ADD_HEADER_GROUP FILENAMES)
  add_group("Header Files" ${FILENAMES})
endmacro(ADD_HEADER_GROUP FILENAMES)

# ADD_SOURCE_GROUP
# ----------------
#
# Add FILENAMES to "Source Files" group when using IDE Cmake Generator
#
macro(ADD_SOURCE_GROUP FILENAMES)
  add_group("Source Files" ${FILENAMES})
endmacro(ADD_SOURCE_GROUP FILENAMES)
