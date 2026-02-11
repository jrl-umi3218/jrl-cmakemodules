cmake_minimum_required(VERSION 3.22)

project(myproj VERSION 1.0.0 LANGUAGES NONE)

# Find the jrl-cmakemodules package
find_package(jrl-cmakemodules 0.1.0 CONFIG REQUIRED)

# Example finding an external package
jrl_find_package(jrl-cmakemodules 0.1.0 CONFIG REQUIRED)
if(NOT DEFINED jrl-cmakemodules_VERSION)
    message(FATAL_ERROR "jrl-cmakemodules_VERSION is not defined")
endif()

# Testing one of the functions provided by jrl-cmakemodules
jrl_print_banner()
