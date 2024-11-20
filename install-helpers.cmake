# Copyright (C) 2024 INRIA.
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

# .rst:
# ~~~
# .. command:: ADD_INSTALL_TARGET (
#   NAME <name>
#   COMPONENT <component>)
# ~~~
#
# This function add a custom target named install-<name> that will run cmake
# install for a specific <component>.
#
# :param name: Target name suffix (install-<name>).
#
# :param component: component to install.
function(ADD_INSTALL_TARGET)
  set(options)
  set(oneValueArgs NAME COMPONENT)
  set(multiValueArgs)
  cmake_parse_arguments(
    ARGS
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )
  set(target_name install-${ARGS_NAME})
  set(component ${ARGS_COMPONENT})

  add_custom_target(
    ${target_name}
    COMMAND
      ${CMAKE_COMMAND} -DCOMPONENT=${component} -P
      ${PROJECT_BINARY_DIR}/cmake_install.cmake
  )
endfunction()
