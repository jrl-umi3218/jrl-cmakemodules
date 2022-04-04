#
#   Copyright 2022 CNRS
#
#   Author: Guilhem Saurel
#
#

set_property(GLOBAL PROPERTY JRL_CMAKEMODULES_HAS_CPP_COVERAGE OFF)
set_property(GLOBAL PROPERTY JRL_CMAKEMODULES_HAS_PYTHON_COVERAGE OFF)

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

#.rst:
# .. ifmode:: internal
#
#   .. command:: enable_coverage
#
#      Configure a target with --coverage compilation and link flags
#      if the ENABLE_COVERAGE option is ON
function(enable_coverage target)
  set_property(GLOBAL PROPERTY JRL_CMAKEMODULES_HAS_CPP_COVERAGE ON)
  target_compile_options(${target} PRIVATE $<$<BOOL:ENABLE_COVERAGE>:--coverage>)
  target_link_options(${target} PRIVATE $<$<BOOL:ENABLE_COVERAGE>:--coverage>)
endfunction()

macro(_SETUP_COVERAGE_FINALIZE)
  get_property(_CPP_COVERAGE GLOBAL PROPERTY JRL_CMAKEMODULES_HAS_CPP_COVERAGE)
  get_property(_PYTHON_COVERAGE GLOBAL PROPERTY JRL_CMAKEMODULES_HAS_PYTHON_COVERAGE)

  if(ENABLE_COVERAGE AND (_CPP_COVERAGE OR _PYTHON_COVERAGE))
    find_program(GENHTML genhtml)
    if(NOT GENHTML)
      message(FATAL_ERROR "genhtml is required with ENABLE_COVERAGE=ON")
    endif()

    set(_COVERAGE_DIR "coverage")
    set(_COVERAGE_HTML ${GENHTML})
    set(_COVERAGE_FILES "")

    if(_CPP_COVERAGE)
      find_program(LCOV lcov)
      if(NOT LCOV)
        message(FATAL_ERROR "lcov is required with ENABLE_COVERAGE=ON and enable_coverage() on C/C++ target")
      endif()
      add_custom_command(OUTPUT cpp.lcov
        COMMAND ${LCOV} --include "${PROJECT_SOURCE_DIR}/\\*" -c -d ${PROJECT_SOURCE_DIR} -o cpp.lcov
        COMMENT "Generating code coverage data for C++")
      set(_COVERAGE_HTML ${_COVERAGE_HTML} -p ${PROJECT_SOURCE_DIR})
      set(_COVERAGE_FILES ${_COVERAGE_FILES} cpp.lcov)
      message(STATUS "C/C++ coverage will be generated for enabled targets")
    endif()

    if(_PYTHON_COVERAGE)
      execute_process(COMMAND ${PYTHON_EXECUTABLE} -m coverage RESULT_VARIABLE _cov_ret)
      if(_cov_ret EQUAL 1)
        message(FATAL_ERROR "coverage.py required for python with ENABLE_COVERAGE=ON")
      endif()
      add_custom_command(OUTPUT python.lcov
        COMMAND ${PYTHON_EXECUTABLE} -m coverage combine
        COMMAND ${PYTHON_EXECUTABLE} -m coverage lcov -o python.lcov
        BYPRODUCTS .coverage
        COMMENT "Generating code coverage data for Python")
      set(_COVERAGE_HTML ${_COVERAGE_HTML} -p ${CMAKE_INSTALL_PREFIX}/${PYTHON_SITELIB})
      set(_COVERAGE_FILES ${_COVERAGE_FILES} python.lcov)
      message(STATUS "Python coverage will be generated")
    endif()

    add_custom_target(coverage
      COMMAND ${_COVERAGE_HTML} -o ${_COVERAGE_DIR} ${_COVERAGE_FILES}
      DEPENDS ${_COVERAGE_FILES}
      BYPRODUCTS ${_COVERAGE_DIR}
      COMMENT "Generating HTML report for code coverage")
  endif()
endmacro()
