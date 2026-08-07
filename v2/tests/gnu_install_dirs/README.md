# gnu_install_dirs

Verifies that `jrl_configure_defaults()` leaves every `GNUInstallDirs` variable usable in the
caller's scope, including `CMAKE_INSTALL_DOCDIR`, `DATADIR`, `MANDIR`, `INFODIR`, `LOCALEDIR`
and all the `CMAKE_INSTALL_FULL_*`, which are not cache entries and are therefore lost if
`GNUInstallDirs` is included from inside a `function()`.
