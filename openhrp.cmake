# Copyright (C) 2008-2014 LAAS-CNRS, JRL AIST-CNRS, LIRMM-CNRS
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

# Search if openhrp3.1 is installed. Set the value GRX_PREFIX if found
macro(SEARCH_GRX)
  # Define additional options.
  find_path(
    GRX_PREFIX
    # Make sure bin/DynamicsSimulator exists (to validate that it is _really_
    # the prefix of an OpenHRP setup).
    include/rtm/idl/SDOPackage.hh
    HINTS /opt/grx/
    DOC "GRX software prefix (i.e. '/opt/grxX.Y')"
    NO_DEFAULT_PATH)
endmacro(SEARCH_GRX)

# Search if openhrp3.0(.7) is installed. Set the value GRX_PREFIX if found
macro(SEARCH_GRX3)
  find_path(
    GRX_PREFIX
    # Make sure bin/DynamicsSimulator exists (to validate that it is _really_
    # the prefix of an OpenHRP setup).
    OpenHRP/DynamicsSimulator/server/DynamicsSimulator
    HINTS /opt/grx3.0
    DOC "GRX software prefix (i.e. '/opt/grxX.Y')"
    NO_DEFAULT_PATH)
endmacro(SEARCH_GRX3)

# Check the robots installed in openhrp Args: the robot researched (and handled
# by the package). Return: the list GRX_ROBOTS Example:
# SEARCH_GRX_ROBOTS("robot1;robot2")
macro(SEARCH_GRX_ROBOTS HANDLED_ROBOTS)
  foreach(robot ${HANDLED_ROBOTS})
    if(!GRX_PREFIX)
      message(ERROR "Dit not find GRX_PREFIX")
    else(!GRX_PREFIX)
      # List of know robots.
      if(IS_DIRECTORY ${GRX_PREFIX}/${robot})
        list(APPEND GRX_ROBOTS ${robot})
      endif()
    endif(!GRX_PREFIX)
  endforeach(robot)

  if(NOT GRX_ROBOTS)
    message(
      FATAL_ERROR
        "None of the following robots (${HANDLED_ROBOTS}) were found in ${GRX_PREFIX}."
    )
  else()
    message("The following robots were found: ${GRX_ROBOTS}")
  endif()
  list(APPEND LOGGING_WATCHED_VARIABLES GRX_ROBOTS)
endmacro(SEARCH_GRX_ROBOTS)
