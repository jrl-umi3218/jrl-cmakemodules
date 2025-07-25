# Restore version information that might have been overriden by project() call
set(PROJECT_VERSION "${SAVED_PROJECT_VERSION}")
set(PROJECT_VERSION_MAJOR "${SAVED_PROJECT_VERSION_MAJOR}")
set(PROJECT_VERSION_MINOR "${SAVED_PROJECT_VERSION_MINOR}")
set(PROJECT_VERSION_PATCH "${SAVED_PROJECT_VERSION_PATCH}")

include(CMakeDependentOption)
include(${CMAKE_CURRENT_LIST_DIR}/GNUInstallDirs.cmake)
set(CMAKE_INSTALL_FULL_PKGLIBDIR ${CMAKE_INSTALL_FULL_LIBDIR}/${PROJECT_NAME})
set(CMAKE_INSTALL_PKGLIBDIR ${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME})

include(${CMAKE_CURRENT_LIST_DIR}/pkg-config.cmake)
if(DEFINED PROJECT_DEBUG_POSTFIX)
  set(CMAKE_DEBUG_POSTFIX ${PROJECT_DEBUG_POSTFIX})
  string(TOLOWER "${CMAKE_BUILD_TYPE}" cmake_build_type)
  if(${cmake_build_type} MATCHES debug)
    set(PKGCONFIG_POSTFIX ${PROJECT_DEBUG_POSTFIX})
  else()
    set(PKGCONFIG_POSTFIX "")
  endif()
  if(DEFINED CMAKE_CONFIGURATION_TYPES)
    set(PKGCONFIG_POSTFIX ${PROJECT_DEBUG_POSTFIX})
  endif()
endif()

if(NOT DEFINED PROJECT_USE_KEYWORD_LINK_LIBRARIES)
  set(PROJECT_USE_KEYWORD_LINK_LIBRARIES FALSE)
endif()
if(PROJECT_USE_KEYWORD_LINK_LIBRARIES)
  set(PUBLIC_KEYWORD PUBLIC)
else()
  set(PUBLIC_KEYWORD "")
endif()

if(${ARGC})
  set(CMAKE_VERBOSE_MAKEFILE ${ARGV0})
else(${ARGC})
  # Be verbose by default.
  set(CMAKE_VERBOSE_MAKEFILE TRUE)
endif(${ARGC})

option(BUILD_DOCUMENTATION "Build the documentation." ON)
cmake_dependent_option(
  INSTALL_DOCUMENTATION
  "Install the documentation."
  ON
  BUILD_DOCUMENTATION
  OFF
)

option(BUILD_PYTHON_INTERFACE "Build the python bindings" ON)
cmake_dependent_option(
  BUILD_STANDALONE_PYTHON_INTERFACE
  "Build only the python bindings. Require the main part of the project to be already installed"
  OFF
  BUILD_PYTHON_INTERFACE
  OFF
)
cmake_dependent_option(
  INSTALL_GENERATED_HEADERS
  "Generate and install standard headers"
  ON
  "NOT BUILD_STANDALONE_PYTHON_INTERFACE"
  OFF
)
cmake_dependent_option(
  INSTALL_PKG_CONFIG_FILE
  "Generate and install standard .pc file"
  ON
  "NOT BUILD_STANDALONE_PYTHON_INTERFACE"
  OFF
)
cmake_dependent_option(
  PROJECT_USE_CMAKE_EXPORT
  "Generate and install CMake exports"
  OFF
  "NOT BUILD_STANDALONE_PYTHON_INTERFACE"
  OFF
)

include(CTest)
enable_testing()

LOGGING_INITIALIZE()

# FIXME: normalize naming to <MODULE>_SETUP()
if(COMMAND _setup_python_for_cython)
  _setup_python_for_cython()
endif()
_SETUP_PROJECT_WARNINGS()
_SETUP_PROJECT_HEADER()
_SETUP_PROJECT_DIST()
DISTCHECK_SETUP()
RELEASE_SETUP()
_SETUP_PROJECT_DEB()
_SETUP_PROJECT_UNINSTALL()
_SETUP_PROJECT_PKG_CONFIG()
if(BUILD_DOCUMENTATION)
  _SETUP_PROJECT_DOCUMENTATION()
endif(BUILD_DOCUMENTATION)
_SETUP_PROJECT_PACKAGE_INIT()
