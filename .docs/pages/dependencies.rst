Dependencies
************

pkg-config dependencies
=======================

This set of macros allow to specifiy dependencies on packages that use
pkg-config to specifiy their own dependencies, compilation flags and link
flags. In particular, it allows to specify dependencies towards other projects built using the JRL CMake modules.

.. setmode:: import

.. cmakemodule:: ../../pkg-config.cmake

pkg-config generation
=====================

.. setmode:: export

.. cmakemodule:: ../../pkg-config.cmake

.. setmode:: user

External dependencies
=====================

Eigen
-----
.. cmakemodule:: ../../eigen.cmake
Boost
-----
.. cmakemodule:: ../../boost.cmake
Python
------
.. cmakemodule:: ../../python.cmake

Advanced
========

pkg-config dependencies
-----------------------

.. setmode:: import-advanced

.. cmakemodule:: ../../pkg-config.cmake

pkg-config generation
---------------------

.. setmode:: export-advanced

.. cmakemodule:: ../../pkg-config.cmake

.. setmode:: user
