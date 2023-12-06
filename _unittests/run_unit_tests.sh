#!/bin/bash

set -e
set -x

unittests="python cpp dependency catkin"

# Code for running a specific unit test
# For unit test foo, function `run_foo` is executed if defined.
# Otherwise, a default procedure is run.

# function run_foo
# {
#   echo "run_foo"
# }

function run_default()
{
  $CMAKE_BIN ${cmake_options} "$1"
  make all
  make install
}

function run_cpp()
{
  run_default $here/cpp
}

function run_catkin()
{
  $CMAKE_BIN ${cmake_options} -DFORCE_DOT_CATKIN_CREATION=ON "${here}/catkin"
  make install
  if [[ ! -f ${here}/install/.catkin ]]; then
    echo ".catkin file should have been created"
    exit 1
  fi
  make uninstall
  if [[ -f ${here}/install/.catkin ]]; then
    echo ".catkin file should have been removed"
    exit 1
  fi
  cd ${here}/build/
  rm -rf ${here}/build/catkin/
  mkdir -p ${here}/build/catkin/
  cd catkin
  touch ${here}/install/.catkin
  $CMAKE_BIN ${cmake_options} -DFORCE_DOT_CATKIN_CREATION=OFF "${here}/catkin"
  make install
  make uninstall
  if [[ ! -f ${here}/install/.catkin ]]; then
    echo ".catkin file should NOT have been removed"
    exit 1
  fi
}

# The code below run all the unit tests
here="`pwd`"
rm -rf build install
mkdir build install

if [[ -z "${CMAKE_BIN}" ]]; then
  CMAKE_BIN=cmake
fi
cmake_options="-DCMAKE_INSTALL_PREFIX='${here}/install'"
export CMAKE_PREFIX_PATH=$here/install

for unittest in ${unittests}; do
  mkdir build/${unittest}
  cd build/${unittest}
  if [[ "$(type -t run_${unittest})" == "function" ]]; then
    run_${unittest}
  else
    run_default "$here/$unittest"
  fi
  cd "$here"
done
