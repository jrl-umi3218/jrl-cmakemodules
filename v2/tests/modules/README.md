# modules

Here we unit test api functions in pure CMake. This is different from the other tests, which are more end-to-end/integration tests.

Every test case is declared with `jrl_test_case()`, which has two modes:

- Without `STEPS`, it runs a block of CMake code in a single `cmake -P` process. This is the default: fast, isolated, and enough for anything that does not depend on the CMake cache being written to disk.
- With `STEPS`, it configures a generated project several times in the same build tree, with one real `cmake -S . -B build` invocation per step, each registered as its own CTest test. Use it when the behaviour under test only shows up across configures, e.g. an option that must not stay stuck at its fallback value, or hidden from `cmake-gui`/`ccmake`, once its `CONDITION` becomes true.
