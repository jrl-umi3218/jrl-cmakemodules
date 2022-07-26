# Copyright (C) 2008-2014 LAAS-CNRS, JRL AIST-CNRS.
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

# .rst: .. command:: SEARCH_FOR_EIGEN
#
# This macro gets eigen include path from pkg-config file, and adds it include
# directories. If there is no pkg-config for Eigen, we fall back to a manual
# search.
#
# If no version requirement argument is passed to the macro, it looks for the
# variable Eigen_REQUIRED. If this variable is not defined before calling the
# method SEARCH_FOR_EIGEN, the minimum version requirement is 3.0.0 by default.
macro(SEARCH_FOR_EIGEN)
  # ref https://github.com/jrl-umi3218/jrl-cmakemodules/issues/319
  message(
    AUTHOR_WARNING
      "SEARCH_FOR_EIGEN is deprecated and will be removed in the future")
  set(_Eigen_FOUND 0)
  if(${ARGC} GREATER 0)
    set(Eigen_REQUIRED ${ARGV0})
  elseif(NOT Eigen_REQUIRED)
    set(Eigen_REQUIRED "eigen3 >= 3.0.0")
  endif()

  # looking for .pc
  pkg_check_modules(_Eigen ${Eigen_REQUIRED})

  if(${_Eigen_FOUND})
    set(${PROJECT_NAME}_CXX_FLAGS
        "${${PROJECT_NAME}_CXX_FLAGS} ${_Eigen_CFLAGS_OTHER}")
    set(${PROJECT_NAME}_LINK_FLAGS
        "${${PROJECT_NAME}_LINK_FLAGS} ${_Eigen_LDFLAGS_OTHER}")

    include_directories(SYSTEM ${_Eigen_INCLUDE_DIRS})
    _add_to_list(_PKG_CONFIG_REQUIRES "${Eigen_REQUIRED}" ",")
  else()
    # fallback: search for the signature_of_eigen3_matrix_library file
    find_path(
      Eigen_INCLUDE_DIR
      NAMES signature_of_eigen3_matrix_library
      PATHS ${CMAKE_INSTALL_PREFIX}/include
      PATH_SUFFIXES eigen3 eigen)
    include_directories(SYSTEM ${Eigen_INCLUDE_DIR})
    pkg_config_append_cflags(-I"${Eigen_INCLUDE_DIR}")
  endif()
endmacro(SEARCH_FOR_EIGEN)
