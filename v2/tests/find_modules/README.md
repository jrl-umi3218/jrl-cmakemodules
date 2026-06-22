# find_modules

Here we check that the "find modules" (i.e. the `Find*.cmake` files) provided by jrl-cmakemodules work as expected.
We also check that if the dependency is not installed, passing `QUIET` (or nothing) to `jrl_find_package()` does not cause a hard failure, but instead a soft one that allows the user to check the result of the call and react accordingly.
