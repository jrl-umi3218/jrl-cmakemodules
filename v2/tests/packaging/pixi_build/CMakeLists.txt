cmake_minimum_required(VERSION 3.22...4.1)

project(myproj VERSION 1.0.0 LANGUAGES NONE)

# Find the jrl-cmakemodules package
find_package(jrl-cmakemodules 0.1.0 CONFIG REQUIRED)

# Example finding an external package
jrl_find_package(jrl-cmakemodules 0.1.0 CONFIG REQUIRED)
jrl_check_var_defined(jrl-cmakemodules_VERSION)

# Testing one of the functions provided by jrl-cmakemodules
jrl_include_ctest()
