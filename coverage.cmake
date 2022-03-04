#
#   Copyright 2022 CNRS
#
#   Author: Guilhem Saurel
#
#

#.rst:
# .. ifmode:: internal
#
#   .. variable:: ENABLE_COVERAGE
#
#      When this is ON, coverage compiler flags are enabled. Disabled for MSVC.

if(NOT MSVC)
  option(ENABLE_COVERAGE "Enable C++ and Python code coverage" OFF)
else()
  set(ENABLE_COVERAGE OFF)
endif()

macro(_SETUP_COVERAGE)
  if(ENABLE_COVERAGE)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --coverage")
    message(STATUS "Appending code coverage compiler flags: --coverage")
  endif()
endmacro()

macro(_SETUP_COVERAGE_FINALIZE)
  if(ENABLE_COVERAGE)
    set(_COVERAGE_DIR "${CMAKE_BINARY_DIR}/coverage")

    # use lcov to gether c++ coverage reports from sources,
    # and coverage.py to gather python coverage reports from installed files,
    # and then generate HTML by removing the source prefix and python sitelib install prefix
    add_custom_target(coverage
      COMMAND lcov --include "${PROJECT_SOURCE_DIR}/\\*" -c -d ${PROJECT_SOURCE_DIR} -o cpp.lcov
      COMMAND ${PYTHON_EXECUTABLE} -m coverage combine
      COMMAND ${PYTHON_EXECUTABLE} -m coverage lcov -o python.lcov
      COMMAND genhtml -p ${PROJECT_SOURCE_DIR} -p "${CMAKE_INSTALL_PREFIX}/${PYTHON_SITELIB}"
              -o ${_COVERAGE_DIR} cpp.lcov python.lcov
      BYPRODUCTS .coverage cpp.lcov python.lcov ${_COVERAGE_DIR}
      WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
      COMMENT "Generating code coverage data")
  endif()
endmacro()
