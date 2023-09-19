# Copyright (C) 2018-2019 LAAS-CNRS, JRL AIST-CNRS, INRIA
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
# .. command:: PROJECT_USE_CXX11
#
# DEPRECATED. This macro set up the project to compile the whole project with
# C++11 standards.
#
macro(PROJECT_USE_CXX11)
  message(
    DEPRECATION
      "This macro is deprecated. Use CHECK_MINIMAL_CXX_STANDARD instead.")
  check_minimal_cxx_standard(11 REQUIRED)
endmacro(PROJECT_USE_CXX11)
