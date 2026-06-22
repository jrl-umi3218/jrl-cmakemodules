cmake_minimum_required(VERSION 3.22)

project(pds-project VERSION 1.0.0 LANGUAGES CXX)

find_package(jrl-cmakemodules CONFIG REQUIRED)
jrl_configure_defaults()

# A non-imported in-tree target (as built via FetchContent / add_subdirectory): reading its LOCATION is forbidden by CMP0026.
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/in_tree_dep.cpp "int in_tree_dep() { return 42; }\n")
add_library(in_tree_dep STATIC ${CMAKE_CURRENT_BINARY_DIR}/in_tree_dep.cpp)
jrl_target_enforce_msvc_conformance(in_tree_dep PRIVATE)

# Here we simulate jrl_find_package(InTreeDep REQUIRED) that would fill the json dep property read by jrl_print_dependencies_summary
jrl_export_dependency(PACKAGE_NAME InTreeDep PACKAGE_TARGETS "in_tree_dep")

# Used to abort configuration with:
# CMake Error at .pixi/envs/default/share/cmake/jrl-cmakemodules/v2/modules/jrl.cmake:2062 (get_property):
#   The LOCATION property may not be read from target "eigenpy".  Use the
#   target name directly with add_custom_command, or use the generator
#   expression $<TARGET_FILE>, as appropriate.

# Test DEPENDS with a false condition (should return early and not print)
jrl_print_dependencies_summary(DEPENDS FALSE)

# Test DEPENDS with a false bracketed condition (should return early and not print)
jrl_print_dependencies_summary(DEPENDS [[DEFINED ENV{NON_EXISTENT_VAR_123456}]])

# Test DEPENDS with a true condition (should run normally)
set(MY_TRUE_VAR TRUE)
jrl_print_dependencies_summary(DEPENDS MY_TRUE_VAR)

# Test DEPENDS with a true env condition (should run normally)
set(ENV{MY_TRUE_ENV_VAR} TRUE)
jrl_print_dependencies_summary(DEPENDS [[DEFINED ENV{MY_TRUE_ENV_VAR}]])

# regular call (should run normally)
jrl_print_dependencies_summary()

# Add a fake install code
install(CODE "message(STATUS \"Fake install\")")
