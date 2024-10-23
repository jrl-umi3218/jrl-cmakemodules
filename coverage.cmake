#
# Copyright 2022 CNRS
#
# Author: Guilhem Saurel
#

# .rst: .. ifmode:: internal
#
# .. variable:: ENABLE_COVERAGE
#
# When this is ON, coverage compiler flags are enabled. Disabled for MSVC.

if(NOT MSVC)
  option(ENABLE_COVERAGE "Enable C++ and Python code coverage" OFF)
else()
  set(ENABLE_COVERAGE OFF)
endif()

# .rst: .. ifmode:: internal
#
# .. command:: enable_coverage
#
# Deprecated and useless.
function(enable_coverage target)
  message(
    WARNING
    "the 'enable_coverage' CMake function is deprecated and does nothing."
  )
endfunction()

if(ENABLE_COVERAGE)
  set(
    CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} -O0 -g --coverage"
    CACHE STRING
    "coverage flags"
  )
  find_program(
    KCOV
    kcov
    DOC "kcov is required for use with -DENABLE_COVERAGE=ON"
    REQUIRED
  )
  set(KCOV_DIR "${CMAKE_BINARY_DIR}/kcov")
  file(MAKE_DIRECTORY ${KCOV_DIR})
endif()

macro(_SETUP_COVERAGE_FINALIZE)
  if(NOT TARGET coverage)
    add_custom_target(
      coverage
      COMMENT "Generating HTML report for code coverage"
    )
    add_custom_target(
      ${PROJECT_NAME}-coverage
      COMMAND ${KCOV} --merge ${CMAKE_BINARY_DIR}/coverage ${KCOV_DIR}/*
      COMMENT "Generating HTML report for code coverage"
    )
    add_dependencies(coverage ${PROJECT_NAME}-coverage)
  endif()
endmacro()
