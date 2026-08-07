# link_with_build_interface

Checks that a dependency linked only through `$<BUILD_INTERFACE:...>` is not exported by
`jrl_export_package()`.
