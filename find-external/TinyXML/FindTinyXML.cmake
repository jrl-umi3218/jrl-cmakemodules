#
# Copyright 2019 CNRS
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

# Try to find TinyXML in standard prefixes and in ${TinyXML_PREFIX} Once done
# this will define TinyXML_FOUND - System has TinyXML TinyXML_INCLUDE_DIRS - The
# TinyXML include directories TinyXML_LIBRARIES - The libraries needed to use
# TinyXML TinyXML_DEFINITIONS - Compiler switches required for using TinyXML

find_path(
  TinyXML_INCLUDE_DIR
  NAMES tinyxml.h
  PATHS ${TinyXML_PREFIX}
  PATH_SUFFIXES include/tinyxml
)
find_library(TinyXML_LIBRARY NAMES tinyxml PATHS ${TinyXML_PREFIX})

set(TinyXML_LIBRARIES ${TinyXML_LIBRARY})
set(TinyXML_INCLUDE_DIRS ${TinyXML_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  TinyXML
  DEFAULT_MSG
  TinyXML_LIBRARY
  TinyXML_INCLUDE_DIR
)
mark_as_advanced(TinyXML_INCLUDE_DIR TinyXML_LIBRARY)
