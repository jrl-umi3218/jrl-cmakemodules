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

# SEARCH_FOR_LAPACK
# -----------------
#
# Search for LAPACK in a portable way.
#
# This macro deals with Visual Studio Fortran incompatibilities and add detected
# flags to the pkg-config file automatically.
#
macro(SEARCH_FOR_LAPACK)
  if(NOT "${CMAKE_GENERATOR}" MATCHES "Visual Studio.*")
    enable_language(Fortran)
  endif(NOT "${CMAKE_GENERATOR}" MATCHES "Visual Studio.*")

  find_package(LAPACK REQUIRED)

  if(NOT LAPACK_FOUND)
    message(FATAL_ERROR "Failed to detect LAPACK.")
  endif(NOT LAPACK_FOUND)

  if(WIN32)
    # Enabling Fortran on Win32 causes the definition of variables that change
    # the name of the library built, add the prefix 'lib' These commands are
    # Counter CMake mesures:
    set(CMAKE_STATIC_LIBRARY_PREFIX "")
    set(CMAKE_SHARED_LIBRARY_PREFIX "")
    set(CMAKE_SHARED_MODULE_PREFIX "")
    set(CMAKE_LINK_LIBRARY_SUFFIX ".lib")
  endif(WIN32)

  pkg_config_append_libs_raw("${LAPACK_LINKER_FLAGS};${LAPACK_LIBRARIES}")

  # Watch variables.
  list(
    APPEND
    LOGGING_WATCHED_VARIABLES
    LAPACK_FOUND
    LAPACK_LINKER_FLAGS
    LAPACK_LIBRARIES
    LAPACK95_LIBRARIES
    LAPACK95_FOUND
    BLA_STATIC
    BLA_VENDOR
    BLA_F95)
endmacro(SEARCH_FOR_LAPACK)
