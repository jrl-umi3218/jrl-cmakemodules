cmake_minimum_required(VERSION 3.22)

project(expected_targets_invalid VERSION 1.0.0)

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)
jrl_configure_defaults()

# Eigen3 imports Eigen3::Eigen. Using a different expected target must fail
# and report the imported targets list in the error message.
jrl_find_package(Eigen3 CONFIG REQUIRED EXPECTED_TARGETS Eigen3::DoesNotExist)
