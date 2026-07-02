# output_dirs

Verifies that `jrl_configure_defaults()` redirects a project's own binary output to the root `build/bin`/`build/lib`, without affecting (or being affected by) plain-CMake sibling projects in the same workspace, and that an explicit per-target output directory (e.g. for Python bindings) still overrides it.
