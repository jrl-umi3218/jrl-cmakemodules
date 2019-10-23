cmake_minimum_required(VERSION 2.8)

# These variables have to be defined before running SETUP_PROJECT
set(PROJECT_NAME hpp-project-example)
set(PROJECT_DESCRIPTION "A HPP project example")

# hpp.cmake includes base.cmake.
include(cmake/hpp.cmake)

# Tell CMake that we compute the PROJECT_VERSION manually.
CMAKE_POLICY(SET CMP0048 OLD)
project(${PROJECT_NAME} CXX)

# Configure the build of your project here
# add_subdirectory(src)
