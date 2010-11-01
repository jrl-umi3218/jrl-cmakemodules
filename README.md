Shared CMake submodule
======================

This repository is meant to be used as a submodule for any project
from CNRS LAAS/HPP or JRL.

It factorizes CMake mechanisms to provide a uniform look'n feel for
all packages.


## What is and is not this package

This package **implements** the JRL/LAAS coding style and packagement
policies.

In practice, it means that these tools makes the assumption that the
package which is using it is respecting the JRL/LAAS rules.

This package is **NOT** generic and cannot be used in a package which
does not respect our rules.

Furthermore, no patches aiming at making this package more generic (in
the sense, allowing non-recommended practices) will be considered.


## How to use this package?

This package is designed as a submodule of a CMake package.

It means that this repository does not have use by itself, it has to
be inserted into a full package by typing:

```sh
git submodule add git://github.com/jrl-umi3218/jrl-cmakemodules.git cmake
```

Make sure to use the public URL using the git protocol so one does not
have to subscribe to github to clone the software.


Then, edit your `CMakeLists.txt` to include the files you need:

```sh
INCLUDE(cmake/base.cmake)
```

See comments in each file for more information.

See also


## How to synchronize a package against a newer jrl-cmakemodules?

When a commit is done in this repository, it will not be taken into
account by a package using this repository as a submodule as long as it
does not have been re-synchronized.

I.e. each git commit of a package is associated to a commit of
jrl-cmakemodules and it will not be updated automatically.

To synchronize the submodule, follow these commands step-by-step:
```sh
# Go to the cmake working copy.
cd cmake

# Fetch the updates.
git fetch origin

# Go the last commit.
git reset --hard origin/master

# Go back to the package.
cd ..

# Synchronize.
git add cmake
git commit -m 'Synchronize.'

# You may then want to push your commit.
```


## How to commit in this package?

The easiest way is to change the content of the `cmake` working copy
in place, like any other directory of your project.

When you are done with your modification, please realize a _separate_
commit in the `cmake` subdirectory (using `git add` and `git commit`
as usual).

However, you will not be able to directly push your commit as the
`cmake` repository has been cloned using the git protocol (it is the
case even if your main package has been cloned using ssh or http).

To solve this problem, add another remote pointing to the gihut Git
repository but using the ssh or http protocol:

```sh
# Add another remote.
# Please note that the URL may be different for you, check
# the correct URL at:
# http://github.com/jrl-umi3218/jrl-cmakemodules
git remote add github-ssh git@github.com:jrl-umi3218/jrl-cmakemodules.git

# Push the commit
git push github-ssh master
```

You then have to synchronize the main package.
