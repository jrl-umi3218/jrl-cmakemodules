
If you would like to include python bindings, add something like the following to the CMakeLists.txt:

```
# Optional Python configuration
# Will not probe environment for Python configuration (which can abort the
# build process) unless you explicitly turn on PYTHON_BINDING.
OPTION(PYTHON_BINDING "Set when you want to build PYTHON_BINDING (Python bindings for the library)" ON)
IF(PYTHON_BINDING)
	SET(PYTHON_BINDING_PYTHON_VERSION "" CACHE STRING "Python version PYTHON_BINDING will use.")
	SET(Python_ADDITIONAL_VERSIONS 3 3.6 3.5 3.4 3.3 3.2 3.1 3.0 2.7 2.7.12 2.7.10 2.7.3 )
	SET_PROPERTY(CACHE PYTHON_BINDING_PYTHON_VERSION PROPERTY STRINGS ${Python_ADDITIONAL_VERSIONS})
	SET(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/build3/cmake ${CMAKE_MODULE_PATH})
	OPTION(EXACT_PYTHON_VERSION "Require Python and match PYTHON_BINDING_PYTHON_VERSION exactly, e.g. 2.7.12" OFF)
	IF(EXACT_PYTHON_VERSION)
	set(EXACT_PYTHON_VERSION_FLAG EXACT REQUIRED)
	ENDIF(EXACT_PYTHON_VERSION)
	# first find the python interpreter
	FIND_PACKAGE(PythonInterp ${PYTHON_BINDING_PYTHON_VERSION} ${EXACT_PYTHON_VERSION_FLAG})
	# python library should exactly match that of the interpreter
	# the following can result in fatal error if you don't have the right python configuration
	FIND_PACKAGE(PythonLibs ${PYTHON_VERSION_STRING} EXACT)
ENDIF(PYTHON_BINDING)
```

This will define the following CMake variables you should use to ensure installation is done on the correct python version:

```
#  PYTHONINTERP_FOUND               - Was the Python executable found
#  PYTHON_VERSION_STRING            - Python version found e.g. 2.5.2
#  PYTHON_VERSION_MAJOR             - Python major version found e.g. 2
#  PYTHON_VERSION_MINOR             - Python minor version found e.g. 5
#  PYTHON_VERSION_PATCH             - Python patch version found e.g. 2
#  PYTHON_EXECUTABLE                - path to the Python interpreter

#  PYTHONLIBS_FOUND                 - have the Python libs been found
#  PYTHON_LIBRARIES                 - path to the python library
#  PYTHON_INCLUDE_PATH              - path to where Python.h is found (deprecated)
#  PYTHON_INCLUDE_DIRS              - path to where Python.h is found
#  PYTHON_DEBUG_LIBRARIES           - path to the debug library (deprecated)
#  PYTHONLIBS_VERSION_STRING        - version of the Python libs found (since CMake 2.8.8)

#  PYTHON_LIBRARY                   - path to the python library
#  PYTHON_INCLUDE_DIR               - path to where Python.h is found

#  PYTHON_NUMPY_FOUND               - was NumPy found
#  PYTHON_NUMPY_VERSION             - the version of NumPy found as a string
#  PYTHON_NUMPY_VERSION_MAJOR       - the major version number of NumPy
#  PYTHON_NUMPY_VERSION_MINOR       - the minor version number of NumPy
#  PYTHON_NUMPY_VERSION_PATCH       - the patch version number of NumPy
#  PYTHON_NUMPY_VERSION_DECIMAL     - e.g. version 1.6.1 is 10601
#  PYTHON_NUMPY_INCLUDE_DIR         - path to the NumPy include files
#  PYTHON_NUMPY_FOUND               - was NumPy found
#  PYTHON_NUMPY_VERSION             - the version of NumPy found as a string
#  PYTHON_NUMPY_VERSION_MAJOR       - the major version number of NumPy
#  PYTHON_NUMPY_VERSION_MINOR       - the minor version number of NumPy
#  PYTHON_NUMPY_VERSION_PATCH       - the patch version number of NumPy
#  PYTHON_NUMPY_VERSION_DECIMAL     - e.g. version 1.6.1 is 10601
#  PYTHON_NUMPY_INCLUDE_DIR         - path to the NumPy include files
```