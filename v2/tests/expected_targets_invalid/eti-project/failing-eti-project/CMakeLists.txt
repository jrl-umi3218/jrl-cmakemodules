cmake_minimum_required(VERSION 3.22)

project(failing-eti-project VERSION 1.0.0)

find_package(jrl-cmakemodules 2.0.0 CONFIG REQUIRED)
jrl_configure_defaults()

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Dummy provides Dummy::A and Dummy::B. Requesting a non-existent target must
# fail and report the actually-imported targets in the error message.
jrl_find_package(Dummy REQUIRED EXPECTED_TARGETS Dummy::DoesNotExist)
