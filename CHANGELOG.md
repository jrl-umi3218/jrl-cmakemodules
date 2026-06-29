# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

## [2.0.0] - 2026-06-29

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


[Unreleased]: https://github.com/coal-library/coal/compare/v1.1.2...HEAD
[1.1.2]: https://github.com/jrl-umi3218/jrl-cmakemodules/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/jrl-umi3218/jrl-cmakemodules/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/jrl-umi3218/jrl-cmakemodules/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/jrl-umi3218/jrl-cmakemodules/releases/tag/v1.0.0
