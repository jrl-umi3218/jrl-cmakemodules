cmake_minimum_required(VERSION 3.22)

project(
  jrl-cmakemodules
  DESCRIPTION "JRL CMake utility toolbox"
  HOMEPAGE_URL "http://github.com/jrl-umi3218/jrl-cmakemodules"
  VERSION 1.1.2
  LANGUAGES NONE
)

# The JRL CMake Modules V2 API
include(${CMAKE_CURRENT_SOURCE_DIR}/v2/modules/jrl.cmake)

# Stop here if this is not the top-level project (included via FetchContent or add_subdirectory)
if(NOT PROJECT_IS_TOP_LEVEL)
  return()
endif()

jrl_configure_defaults()

# JRL_CMAKE_FILES_INSTALL_DIR: Where to install the <project>-config.cmake and related files
# In CMake, 'share' is CMAKE_INSTALL_DATAROOTDIR
# Here we choose <install_prefix>/share/cmake/<project>
set(
  JRL_CMAKE_FILES_INSTALL_DIR
  ${CMAKE_INSTALL_DATAROOTDIR}/cmake/${PROJECT_NAME}
)

option(
  JRL_CMAKEMODULES_GENERATE_API_DOC
  "Generate the API documentation for jrl-cmakemodules (v2)"
  ${PROJECT_IS_TOP_LEVEL}
)

option(
  JRL_CMAKEMODULES_BUILD_TESTS
  "Build the tests for jrl-cmakemodules (v2)"
  ${PROJECT_IS_TOP_LEVEL}
)

if(JRL_CMAKEMODULES_GENERATE_API_DOC)
  _jrl_generate_api_doc(
    ${CMAKE_CURRENT_SOURCE_DIR}/v2/modules/jrl.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/v2/docs/api.md
  )
endif()

if(JRL_CMAKEMODULES_BUILD_TESTS)
  jrl_include_ctest()
  enable_testing()
  add_subdirectory(v2/tests)
endif()

# Add a dummy library with a useful INTERFACE_INCLUDE_DIRECTORIES
add_library(jrl-cmakemodules INTERFACE)
target_include_directories(
  jrl-cmakemodules
  INTERFACE $<INSTALL_INTERFACE:${JRL_CMAKE_FILES_INSTALL_DIR}>
)

# find . -maxdepth 1 -type d ! -path './.*' | sort
install(
  DIRECTORY
    ./boost
    ./cython
    ./doxygen
    ./dynamic_graph
    ./find-external
    ./github
    ./gtest
    ./hpp
    ./image
    ./sphinx
    ./stubgen
  # ./_unittests
  DESTINATION ${JRL_CMAKE_FILES_INSTALL_DIR}
)

# Install the v2 API
install(
  DIRECTORY
    v2/external-modules
    v2/find-modules
    v2/modules
    v2/templates
    v2/scripts
  DESTINATION ${JRL_CMAKE_FILES_INSTALL_DIR}
  PATTERN ".ruff_cache" EXCLUDE
  PATTERN "__pycache__" EXCLUDE
  PATTERN ".pytest_cache" EXCLUDE
)

# find . -maxdepth 1 -type f ! -perm 111 ! -path './.*' | sort
install(
  PROGRAMS
    ./announce-gen
    ./fix-license.sh
    ./git-archive-all.py
    ./git-archive-all.sh
    ./gitlog-to-changelog
    ./pixi.py
    ./pyproject.py
  DESTINATION ${JRL_CMAKE_FILES_INSTALL_DIR}
)

# find . -maxdepth 1 -type f ! -perm /111 ! -path './.*' | sort
install(
  FILES
    ./apple.cmake
    ./base.cmake
    ./boost.cmake
    ./catkin.cmake
    ./CMakeLists.txt
    ./cmake_reinstall.cmake.in
    ./cmake_uninstall.cmake.in
    ./compiler.cmake
    ./componentConfig.cmake.in
    ./Config.cmake.in
    ./config.h.cmake
    ./config.hh.cmake
    ./coverage.cmake
    ./cpack.cmake
    ./createshexe.cmake
    ./cxx11.cmake
    ./cxx-standard.cmake
    ./debian.cmake
    ./deprecated.hh.cmake
    ./distcheck.cmake
    ./dist.cmake
    ./doxygen.cmake
    ./eigen.cmake
    ./filefilter.txt
    ./flake.lock
    ./flake.nix
    ./geometric-tools.cmake
    ./GNUInstallDirs.cmake
    ./gtest.cmake
    ./header.cmake
    ./hpp.cmake
    ./ide.cmake
    ./idl.cmake
    ./idlrtc.cmake
    ./install-data.cmake
    ./install-helpers.cmake
    ./julia.cmake
    ./kineo.cmake
    ./lapack.cmake
    ./LICENSE
    ./logging.cmake
    ./man.cmake
    ./memorycheck_unit_test.cmake.in
    ./metapodfromurdf.cmake
    ./modernize-links.cmake
    ./msvc-specific.cmake
    ./msvc.vcxproj.user.in
    ./openhrp.cmake
    ./openhrpcontroller.cmake
    ./openrtm.cmake
    ./oscheck.cmake
    ./package-config.cmake
    ./package.xml
    ./pkg-config.cmake
    ./pkg-config.pc.cmake
    ./portability.cmake
    ./post-project.cmake
    ./pthread.cmake
    ./python.cmake
    ./python-helpers.cmake
    ./qhull.cmake
    ./README.md
    ./release.cmake
    ./relpath.cmake
    ./ros2.cmake
    ./ros.cmake
    ./sdformat.cmake
    ./setup.cfg
    ./shared-library.cmake
    ./sphinx.cmake
    ./stubs.cmake
    ./swig.cmake
    ./test.cmake
    ./tracy.cmake
    ./tracy.hh.cmake
    ./uninstall.cmake
    ./version.cmake
    ./version-script.cmake
    ./version-script-test.lds
    ./warning.hh.cmake
    ./xacro.cmake
  DESTINATION ${JRL_CMAKE_FILES_INSTALL_DIR}
)

jrl_export_package(
  PACKAGE_CONFIG_TEMPLATE
    ${CMAKE_CURRENT_SOURCE_DIR}/v2/templates/config-basic.cmake.in
  PACKAGE_CONFIG_EXTRA_CONTENT
    [[include("${CMAKE_CURRENT_LIST_DIR}/modules/jrl.cmake")]]
  CMAKE_FILES_INSTALL_DIR ${JRL_CMAKE_FILES_INSTALL_DIR}
)
