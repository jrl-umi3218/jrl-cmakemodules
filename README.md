# JRL CMake Modules

[![Documentation Status](https://readthedocs.org/projects/jrl-cmakemodules/badge/?version=master)](https://jrl-cmakemodules.readthedocs.io/en/master/?badge=master)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/jrl-umi3218/jrl-cmakemodules/master.svg)](https://results.pre-commit.ci/latest/github/jrl-umi3218/jrl-cmakemodules/master)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

`jrl-cmakemodules` provide functions to factorize and write more reliable CMake code.

It is used by teams at CNRS, LAAS/HPP, JRL and Inria, but can be integrated in any project.

## v2 API

The new modules available in the [v2](v2) folder aims to modernize the current approach by providing a set of utility functions (opt-in) instead of a framework approach.

The API documentation for the v2 api is available [here](v2/docs/api.md).

## Release Tool (`jrl-release`)

We provide a Python version management script to automate version synchronization across your project files (such as `package.xml`, `pyproject.toml`, `pixi.toml`, `CMakeLists.txt`, `CHANGELOG.md`, etc.).

### Installation

To install `jrl-release` globally using `uv`:
```bash
uv tool install jrl-cmakemodules-scripts --from git+https://github.com/jrl-umi3218/jrl-cmakemodules.git
```

Alternatively, if you have cloned the repository locally, run this from the repo root:
```bash
uv tool install --editable .
```
or with pip:
```bash
pip install -e .
```

### Usage

Once installed, run `jrl-release` from the root of your project:
```bash
# Check if version files agree
jrl-release --check-version

# Bump the patch, minor, or major version
jrl-release --bump patch
jrl-release --bump minor

# Update version to a specific string
jrl-release --update-version 1.2.3
```


## v1 API

Please see the documentation on the [wiki] for more information.

You can also checkout the more complete [documentation] of the modules.

[wiki]: http://github.com/jrl-umi3218/jrl-cmakemodules/wiki

[documentation]: http://jrl-cmakemodules.readthedocs.io/en/master/

## Supported CMake versions

We currently support CMake >= 3.22

## pre-commit

This project use [pre-commit](https://pre-commit.com) and [pre-commit.ci](https://pre-commit.ci).

You can get a nice documentation directly on those 2 projects, but here is a quickstart:

```
# install pre-commit:
python -m pip install pre-commit

# run all hooks on all files:
pre-commit run -a

# run automatically the hooks on the added / modified files, when you try to commit:
pre-commit install
```
