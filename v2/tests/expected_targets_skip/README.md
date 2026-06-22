# expected_targets_skip

Here we check a superbuild/workspace scenario where a project above might have already imported the package.
We expect `jrl_find_package(... EXPECTED_TARGETS ...)` to **skip** the actual call to `find_package`,
but still internally fill the json file, so that the jrl_export_package() works as expected.
