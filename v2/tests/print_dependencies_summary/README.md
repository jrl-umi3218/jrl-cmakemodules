# print_dependencies_summary

Regression test for `jrl_print_dependencies_summary()` against the CMP0026 / `LOCATION` edge case,
which can be triggered in workspace/superbuild scenarios.
Example: B depends on A, imports A with jrl_find_package(A REQUIRED), but this is a superproject where A and B are part
of 1 CMake workspace add_subdirectory(A) + add_subdirectory(B). In this case, A is not an imported target, and the LOCATION property cannot be read from it.
