cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME jrl-cmakemodules-catkin)
set(PROJECT_VERSION 0.0.0)
set(PROJECT_DESCRIPTION "JRL CMake module - catkin")
set(PROJECT_URL http://jrl-cmakemodules.readthedocs.io)

include(../../base.cmake)

project(${PROJECT_NAME} LANGUAGES CXX)

# This project test the correct behavior of #622
#
# * If .catkin is already here when the project is configured it is not removed
# * Otherwise it is assumed it is created by the project and removed with the
#   uninstall target

option(FORCE_DOT_CATKIN_CREATION
       "Force creation of .catkin file in install destination" OFF)

if(FORCE_DOT_CATKIN_CREATION)
  install(
    CODE "execute_process(COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_INSTALL_PREFIX}/.catkin)"
  )
endif()
