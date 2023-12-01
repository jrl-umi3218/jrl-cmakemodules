#
# Copyright 2023 CNRS
#
# Author: Guilhem Saurel
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with this program.  If not, see <https://www.gnu.org/licenses/>.
#

# Try to find CoinUtils in standard prefixes and in ${CoinUtils_PREFIX} Once
# done this will define CoinUtils_FOUND - System has CoinUtils
# CoinUtils_INCLUDE_DIRS - The CoinUtils include directories CoinUtils_LIBRARIES
# - The libraries needed to use CoinUtils CoinUtils::CoinUtils - A target to use
# for relocatable packages

find_path(
  CoinUtils_INCLUDE_DIR
  NAMES coin/CoinBuild.hpp
  PATHS ${CoinUtils_PREFIX})
find_library(
  CoinUtils_LIBRARY
  NAMES libCoinUtils.so
  PATHS ${CoinUtils_PREFIX})

set(CoinUtils_LIBRARIES ${CoinUtils_LIBRARY})
set(CoinUtils_INCLUDE_DIRS ${CoinUtils_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CoinUtils DEFAULT_MSG CoinUtils_LIBRARY
                                  CoinUtils_INCLUDE_DIR)
mark_as_advanced(CoinUtils_INCLUDE_DIR CoinUtils_LIBRARY)

if(CoinUtils_FOUND AND NOT TARGET CoinUtils::CoinUtils)
  add_library(CoinUtils::CoinUtils SHARED IMPORTED)
  set_target_properties(
    CoinUtils::CoinUtils PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
                                    "${CoinUtils_INCLUDE_DIR}")
  set_target_properties(
    CoinUtils::CoinUtils PROPERTIES IMPORTED_LOCATION_RELEASE
                                    "${CoinUtils_LIBRARY}")
  set_property(
    TARGET CoinUtils::CoinUtils
    APPEND
    PROPERTY IMPORTED_CONFIGURATIONS "RELEASE")
  message(
    STATUS
      "CoinUtils found (include: ${CoinUtils_INCLUDE_DIR}, lib: ${CoinUtils_LIBRARY})"
  )
endif()
