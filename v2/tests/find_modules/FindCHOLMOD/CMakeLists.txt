cmake_minimum_required(VERSION 3.22)
project(FindCHOLMODTest)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../find-modules")

find_package(CHOLMOD REQUIRED)

message(
    STATUS
    "
CHOLMOD_FOUND=${CHOLMOD_FOUND}
CHOLMOD_VERSION=${CHOLMOD_VERSION}
CHOLMOD_INCLUDE_DIR=${CHOLMOD_INCLUDE_DIR}
CHOLMOD_LIBRARY=${CHOLMOD_LIBRARY}
"
)

if(NOT CHOLMOD_FOUND)
    message(FATAL_ERROR "CHOLMOD_FOUND is false after find_package(CHOLMOD REQUIRED)")
endif()

# The module must create the documented imported target, plus the SuiteSparse
# component targets it links against (whether resolved via CHOLMODConfig.cmake
# or via the manual fallback).
foreach(
    target
    IN
    ITEMS
        SuiteSparse::CHOLMOD
        SuiteSparse::SuiteSparseConfig
        SuiteSparse::AMD
        SuiteSparse::CAMD
        SuiteSparse::COLAMD
        SuiteSparse::CCOLAMD
)
    if(NOT TARGET ${target})
        message(FATAL_ERROR "${target} imported target was not created")
    endif()
endforeach()
