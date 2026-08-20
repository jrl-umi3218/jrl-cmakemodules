# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

- jrl_release: add package.xml by @nim65s
- jrl_check_python_module: add version handling by @ahoarau
- jrl_option: fix condition handling on reconfigure and support parent project normal variables (CMP0077)
- v2: add cppad, cppadcg, GMP and MPFR find-modules by @ahoarau

## [2.2.4] - 2026-08-07

- fix pypi release for 2.2.4

## [2.2.3] - 2026-08-07

- jrl_release: fix archive signature

## [2.2.2] - 2026-08-07

- jrl_release: fix archive creation

## [2.2.1] - 2026-08-07

- jrl_release: improve logging

## [2.2.0] - 2026-08-07

- jrl_release: add `ConanFileVersionExtractor` by @arntanguy
- jrl_release: add `--check-version --check-tag vX.Y.Z` by @arntanguy
- jrl_release: add `DebianChangelogVersionExtractor` by @arntanguy
- jrl_release: update links `ChangelogVersionExtractor` by @nim65s
- jrl_release: add push tag, create archive, publish on github
- jrl_check_python_module: fall back to `importlib.metadata` when the module has no `__version__` by @ahoarau
- jrl: change jrl_configure_default_install_dirs() to macro to make GNUInstallDirs in caller's scope by @ahoarau
- jrl: fix resolution of `$<BUILD_INTERFACE` generator expressions during jrl_export_package

## [2.1.0] - 2026-07-03

- jrl_release: add `--sign-tag` to sign the tag by @ahoarau
- jrl_print_banner: update banner for v2.0.0
- jrl_target_headers: fix relative path when called from subdir
- jrl: make sure `CMAKE_<>_OUTPUT_DIRECTORY` does not leak into other projects
- README: fix install scripts doc

## [2.0.0] - 2026-06-29

- Rework everything from scratch in v2/ opt-in directory by @ahoarau
- Added jrl-cmakemodules-script python project by @ahoarau

## [1.1.2] - 2025-11-07

- Fixes for ROS:
    - Install this project exports in share
    - git-archive-all.py: explicit use of python 3

## [1.1.1] - 2025-11-06

- fix permissions of installed scripts
- ROS: document this package as architecture independent

## [1.1.0] - 2025-07-29

- Don't add a dependency added by ADD_PROJECT_DEPENDENCY macro if the dependency is not found in the generated CMake module
- Make package-config cached variable reentrant.
- Remove PACKAGE_EXTRA_MACROS from the INTERNAL CACHE since it's modified by user
- Fix support for CMake v4.1
- add AUTO_UNINSTALL option

## [1.0.0] - 2025-07-09

First release


[Unreleased]: https://github.com/coal-library/coal/compare/v2.2.4...HEAD
[2.2.4]: https://github.com/coal-library/coal/compare/v2.2.3...v2.2.4
[2.2.3]: https://github.com/coal-library/coal/compare/v2.2.2...v2.2.3
[2.2.2]: https://github.com/coal-library/coal/compare/v2.2.1...v2.2.2
[2.2.1]: https://github.com/coal-library/coal/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/coal-library/coal/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/jrl-umi3218/jrl-cmakemodules/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/jrl-umi3218/jrl-cmakemodules/compare/v1.1.2...v2.0.0
[1.1.2]: https://github.com/jrl-umi3218/jrl-cmakemodules/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/jrl-umi3218/jrl-cmakemodules/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/jrl-umi3218/jrl-cmakemodules/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/jrl-umi3218/jrl-cmakemodules/releases/tag/v1.0.0
