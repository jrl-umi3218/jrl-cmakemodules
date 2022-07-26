Shared CMake submodule
======================

[![Documentation Status](https://readthedocs.org/projects/jrl-cmakemodules/badge/?version=master)](https://jrl-cmakemodules.readthedocs.io/en/master/?badge=master)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/jrl-umi3218/jrl-cmakemodules/master.svg)](https://results.pre-commit.ci/latest/github/jrl-umi3218/jrl-cmakemodules/master)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

This repository is meant to be used as a submodule for any project
from CNRS LAAS/HPP or JRL.

It factorizes CMake mechanisms to provide a uniform look'n feel for
all packages.


Please see the documentation on the [wiki] for more information.

You can also checkout the more complete [documentation] of the modules.

[wiki]: http://github.com/jrl-umi3218/jrl-cmakemodules/wiki

[documentation]: http://jrl-cmakemodules.readthedocs.io/en/master/

# pre-commit

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
