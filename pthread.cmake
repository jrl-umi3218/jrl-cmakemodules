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

include(FindThreads)

# SEARCH_FOR_PTHREAD
# ------------------
#
# Check for pthread support on Linux. This does nothing on Windows.
#
macro(SEARCH_FOR_PTHREAD)
  if(UNIX)
    if(CMAKE_USE_PTHREADS_INIT)
      add_definitions(-pthread)
    else(CMAKE_USE_PTHREADS_INIT)
      message(FATAL_ERROR "Pthread is required on Unix, but "
                          ${CMAKE_THREAD_LIBS_INIT} " has been detected.")
    endif(CMAKE_USE_PTHREADS_INIT)
  elseif(WIN32)
    # Nothing to do.
  else(UNIX)
    message(FATAL_ERROR "Thread support for this platform is not implemented.")
  endif(UNIX)

  list(
    APPEND
    LOGGING_WATCHED_VARIABLES
    CMAKE_THREAD_LIBS_INIT
    CMAKE_USE_SPROC_INIT
    CMAKE_USE_WIN32_THREADS_INIT
    CMAKE_USE_PTHREADS_INIT
    CMAKE_HP_PTHREADS_INIT)
endmacro(SEARCH_FOR_PTHREAD)
