cmake_minimum_required(VERSION 3.22)

project(
    rfp
    VERSION 1.0.0
    DESCRIPTION "A package that uses regular find_package to export its targets"
)

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)
jrl_configure_defaults()

# User forgets to call jrl_find_package()
find_package(Eigen3 CONFIG REQUIRED)

add_library(t INTERFACE)
target_link_libraries(t INTERFACE Eigen3::Eigen)

jrl_add_export_component(NAME t TARGETS t)
jrl_export_package()
