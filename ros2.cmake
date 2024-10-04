# Copyright (C) 2024 LAAS-CNRS, JRL AIST-CNRS.
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

# This macro creates 3 files which are allowing a package to be found using the
# AMENT system present in ros 2 Setting BUILDING_ROS2_PACKAGE is enough to
# trigger this behavior. _install_project_ros2_ament_files()
macro(_install_project_ros2_ament_files)
  if(BUILDING_ROS2_PACKAGE)
    message(STATUS "Create files for AMENT (ROS 2)")
    # Allows Colcon to find non-Ament packages when using workspace underlays
    file(
      WRITE
      ${CMAKE_CURRENT_BINARY_DIR}/share/ament_index/resource_index/packages/${PROJECT_NAME}
      "")
    install(
      FILES
        ${CMAKE_CURRENT_BINARY_DIR}/share/ament_index/resource_index/packages/${PROJECT_NAME}
      DESTINATION share/ament_index/resource_index/packages)
    file(
      WRITE
      ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/hook/ament_prefix_path.dsv
      "prepend-non-duplicate;AMENT_PREFIX_PATH;")
    install(
      FILES
        ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/hook/ament_prefix_path.dsv
      DESTINATION share/${PROJECT_NAME}/hook)
    file(WRITE
         ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/hook/python_path.dsv
         "prepend-non-duplicate;PYTHONPATH;${PYTHON_SITELIB}")
    install(
      FILES
        ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/hook/python_path.dsv
      DESTINATION share/${PROJECT_NAME}/hook)
  endif(BUILDING_ROS2_PACKAGE)
endmacro(_install_project_ros2_ament_files)
