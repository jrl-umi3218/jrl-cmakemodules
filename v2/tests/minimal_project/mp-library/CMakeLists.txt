cmake_minimum_required(VERSION 3.22)
project(mp-library VERSION 1.2.3)

find_package(jrl-cmakemodules REQUIRED)

add_library(mp-library INTERFACE)

jrl_configure_defaults()
jrl_add_export_component(NAME AllComponents TARGETS mp-library)
jrl_export_package()
