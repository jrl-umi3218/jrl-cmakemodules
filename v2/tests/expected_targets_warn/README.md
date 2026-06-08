# expected_targets_warn

Here we check a warning created to help users to migrate to `EXPECTED_TARGETS` in `jrl_find_package`.
Basically we simulate a user using jrl_find_package, then using target_link_libraries with the imported targets.
In order to support superbuild/workspace scenarios, we must have something similar to:
```cmake
if(NOT TARGET Dummy::Dummy)
    find_package(Dummy REQUIRED)
endif()
```
This is what `EXPECTED_TARGETS` does.
