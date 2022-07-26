# Copyright (C) 2018 LAAS-CNRS Authors: Joseph Mirabel
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# 1. Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#[=============================================================================[.rst:
.. ifmode:: hpp

Mostly, this sets a few variables to some convenient default values and it sets a specific
layout for the documentation.

Minimal working example
-----------------------

.. literalinclude:: ../examples/minimal-hpp.cmake
  :language: cmake

Variables
---------

The varible :cmake:variable:`PROJECT_URL` is set to
`"https://github.com/${PROJECT_ORG}/${PROJECT_NAME}"`

.. variable:: PROJECT_ORG

  Set to `"humanoid-path-planner"` if not defined when including `hpp.cmake`.

.. variable:: HPP_DEBUG

  Enable logging of debug output in log files.

.. variable:: HPP_BENCHMARK

  Enable logging of benchmark output in log files.

#]=============================================================================]

if(NOT DEFINED PROJECT_ORG)
  set(PROJECT_ORG "humanoid-path-planner")
endif(NOT DEFINED PROJECT_ORG)

if(NOT DEFINED PROJECT_URL)
  set(PROJECT_URL "https://github.com/${PROJECT_ORG}/${PROJECT_NAME}")
endif(NOT DEFINED PROJECT_URL)

include(${CMAKE_CURRENT_LIST_DIR}/base.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/hpp/doc.cmake)

# Activate hpp-util logging if requested
set(HPP_DEBUG
    FALSE
    CACHE BOOL "trigger hpp-util debug output")
if(HPP_DEBUG)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DHPP_DEBUG")
endif()
# Activate hpp-util logging if requested
set(HPP_BENCHMARK
    FALSE
    CACHE BOOL "trigger hpp-util benchmark output")
if(HPP_BENCHMARK)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DHPP_ENABLE_BENCHMARK")
endif()
