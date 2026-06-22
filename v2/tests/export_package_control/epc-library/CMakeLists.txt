cmake_minimum_required(VERSION 3.22)
project(epc-library VERSION 1.2.3)

find_package(jrl-cmakemodules REQUIRED)

add_library(epc-library INTERFACE)

jrl_configure_defaults()
jrl_add_export_component(NAME AllComponents TARGETS epc-library)
jrl_export_package()

install(CODE "message(STATUS \"Fake install\")")
