# Copyright (C) 2010 Thomas Moulard, JRL, CNRS/AIST.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

INCLUDE(FindThreads)

# SEARCH_FOR_PTHREAD
# ------------------
#
# Check for pthread support on Linux. This does nothing on Windows.
#
MACRO(SEARCH_FOR_PTHREAD)
  IF(UNIX)
    IF(CMAKE_USE_PTHREADS_INIT)
      ADD_DEFINITIONS(-pthread)
    ELSE(CMAKE_USE_PTHREADS_INIT)
      MESSAGE(FATAL_ERROR
	"Pthread is required on Unix, but "
	${CMAKE_THREAD_LIBS_INIT} " has been detected.")
    ENDIF(CMAKE_USE_PTHREADS_INIT)
  ELSEIF(WIN32)
    # Nothing to do.
  ELSE(UNIX)
    MESSAGE(FATAL_ERROR "Thread support for this platform is not implemented.")
  ENDIF(UNIX)
ENDMACRO(SEARCH_FOR_PTHREAD)
