cmake_minimum_required(VERSION 3.22)

set(PROJECT_NAME "jrl-cmakemodules")
set(PROJECT_DESCRIPTION "CMake utility toolbox")
set(PROJECT_URL "http://github.com/jrl-umi3218/${PROJECT_NAME}")

project(${PROJECT_NAME} DESCRIPTION ${PROJECT_DESCRIPTION} LANGUAGES CXX)

if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
  set(PROJECT_JRL_CMAKE_MODULE_DIR ${CMAKE_CURRENT_LIST_DIR})
  include(base.cmake)
  COMPUTE_PROJECT_ARGS(PROJECT_ARGS LANGUAGES CXX)
  project(${PROJECT_NAME} ${PROJECT_ARGS})

  # Add a dummy library with a useful INTERFACE_INCLUDE_DIRECTORIES
  add_library(${PROJECT_NAME} INTERFACE)
  set(INSTALL_DIR "${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}")
  target_include_directories(
    ${PROJECT_NAME}
    INTERFACE $<INSTALL_INTERFACE:${INSTALL_DIR}>
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
      ./_unittests
    DESTINATION ${INSTALL_DIR}
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
    DESTINATION ${INSTALL_DIR}
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
    DESTINATION ${INSTALL_DIR}
  )

  install(TARGETS ${PROJECT_NAME} EXPORT ${TARGETS_EXPORT_NAME})

  SETUP_PROJECT_PACKAGE_FINALIZE()
endif()
