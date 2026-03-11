cmake_minimum_required(VERSION 3.22)

project(jrl-cmakemodules-find-package-test-v2 VERSION 1.0.0 LANGUAGES CXX)

# v1 api is available starting at 1.2.0
find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)
jrl_configure_defaults()

file(GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/a.cpp CONTENT "int main() { return 0; }")
add_executable(a ${CMAKE_CURRENT_BINARY_DIR}/a.cpp)
install(TARGETS a DESTINATION bin)
