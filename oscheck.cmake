# Copyright (C) 2008-2019 LAAS-CNRS, JRL AIST-CNRS, INRIA.
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

# .rst: .. ifmode:: user
#
# .. command:: CHECK_DEBIAN
#
# Checks is the current system is Debian based You can then use DEBIAN_FOUND
#
macro(CHECK_DEBIAN)
  find_file(DEBIAN_FOUND debian_version debconf.conf PATHS /etc)
endmacro(CHECK_DEBIAN)

# .rst: .. ifmode:: user
#
# .. command:: CHECK_NETBSD
#
# Checks is the current system is NetBSD You can then use NETBSD_FOUND
#
macro(CHECK_NETBSD)
  find_file(NETBSD_FOUND netbsd PATHS /)
endmacro(CHECK_NETBSD)

# .rst: .. ifmode:: user
#
# .. command:: CHECK_ARCHLINUX
#
# Checks is the current system is ArchLinux You can then use ARCHLINUX_FOUND
#
macro(CHECK_ARCHLINUX)
  find_file(ARCHLINUX_FOUND arch-release PATHS /etc)
endmacro(CHECK_ARCHLINUX)
