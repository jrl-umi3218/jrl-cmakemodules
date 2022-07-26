# Copyright (C) 2008-2014 LAAS-CNRS, JRL AIST-CNRS. Olivier STASSE (LAAS,CNRS)
# macro inspired from Sébastien Barthélémy in laas/metapod
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

macro(ADD_METAPOD_FROM_URDF_MODEL model_name)

  set(robot_name "robot_${model_name}")
  set(lib_robot_name "metapod_${model_name}")
  set(dir_robot ${PROJECT_BINARY_DIR}/include/metapod/models/${model_name})
  set(robot_name_sources ${dir_robot}/${model_name}.hh
                         ${dir_robot}/${model_name}.cc)
  set(data_robot_dir ${METAPOD_PREFIX}/share/metapod/data/${model_name})
  set(config_file_robot ${data_robot_dir}/${model_name}.config)
  set(license_file_robot ${data_robot_dir}/${model_name}_license_file.txt)
  set(urdf_file_robot ${data_robot_dir}/${model_name}.urdf)

  add_custom_command(
    OUTPUT ${robot_name_sources}
    COMMAND
      metapodfromurdf --name ${model_name} --libname ${lib_robot_name}
      --directory ${dir_robot} --config-file ${config_file_robot}
      --license-file ${license_file_robot} ${urdf_file_robot})
endmacro(ADD_METAPOD_FROM_URDF_MODEL)
