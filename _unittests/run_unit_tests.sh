#!/bin/bash

unittests="python"

# Code for running a specific unit test
# For unit test foo, function `run_foo` is executed if defined.
# Otherwise, a default procedure is run.

# function run_foo
# {
#   echo "run_foo"
# }


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
    $CMAKE_BIN ${cmake_options} "$here/$unittest"
    make all
    make install
  fi
  cd "$here"
done
