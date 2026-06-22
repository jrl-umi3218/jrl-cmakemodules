cmake_minimum_required(VERSION 3.22)

# We named it CamelCase to verify that CamelCase project/target
# names are supported by jrl-cmakemodules.
# When exporting files,
# <project-name>-config.cmake does not support camel case
# But <ProjectName>Config.cmake supports CamelCase.
project(CamelCase-library VERSION 1.2.3)

find_package(jrl-cmakemodules REQUIRED)

add_library(CamelCase-library INTERFACE)

jrl_configure_defaults()
jrl_add_export_component(NAME AllComponents TARGETS CamelCase-library)
jrl_export_package()
