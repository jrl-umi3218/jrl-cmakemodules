# Copyright 2026 Inria
#
# FindCHOLMOD.cmake
# ----------------
# Finds the CHOLMOD library when the config file CHOLMODConfig.cmake (SuiteSparse >= 6.0) is not available.
# For example, Ubuntu 22.04 ships SuiteSparse 5.x (libsuitesparse-dev), which does not generate a CHOLMODConfig.cmake.
#
# Usage:
#   find_package(CHOLMOD REQUIRED)
#   target_link_libraries(my_app PRIVATE SuiteSparse::CHOLMOD)
#
# Imported targets:
#   SuiteSparse::CHOLMOD
#   SuiteSparse::SuiteSparseConfig
#   SuiteSparse::AMD
#   SuiteSparse::CAMD
#   SuiteSparse::COLAMD
#   SuiteSparse::CCOLAMD
#

# Prefer a config-file package if available.
find_package(CHOLMOD ${CHOLMOD_FIND_VERSION} QUIET NO_MODULE)
if(CHOLMOD_FOUND AND TARGET SuiteSparse::CHOLMOD)
    if(NOT CHOLMOD_FIND_QUIETLY)
        message(STATUS "Found CHOLMOD via CHOLMODConfig.cmake: ${CHOLMOD_VERSION}")
    endif()
    return()
endif()

set(cholmod_hint_prefixes
    ${CHOLMOD_ROOT}
    $ENV{CHOLMOD_ROOT}
    ${SuiteSparse_ROOT}
    $ENV{SuiteSparse_ROOT}
)

find_path(
    CHOLMOD_INCLUDE_DIR
    NAMES cholmod.h
    HINTS ${cholmod_hint_prefixes}
    PATH_SUFFIXES suitesparse
)

find_library(CHOLMOD_LIBRARY NAMES cholmod HINTS ${cholmod_hint_prefixes})
find_library(AMD_LIBRARY NAMES amd HINTS ${cholmod_hint_prefixes})
find_library(CAMD_LIBRARY NAMES camd HINTS ${cholmod_hint_prefixes})
find_library(COLAMD_LIBRARY NAMES colamd HINTS ${cholmod_hint_prefixes})
find_library(CCOLAMD_LIBRARY NAMES ccolamd HINTS ${cholmod_hint_prefixes})
find_library(SUITESPARSECONFIG_LIBRARY NAMES suitesparseconfig HINTS ${cholmod_hint_prefixes})

if(CHOLMOD_INCLUDE_DIR)
    # SuiteSparse <= 5.x keeps the version macros in cholmod_core.h
    # >= 6.0 ships cholmod.h.
    if(EXISTS ${CHOLMOD_INCLUDE_DIR}/cholmod_core.h)
        set(cholmod_header ${CHOLMOD_INCLUDE_DIR}/cholmod_core.h)
    elseif(EXISTS ${CHOLMOD_INCLUDE_DIR}/cholmod.h)
        set(cholmod_header ${CHOLMOD_INCLUDE_DIR}/cholmod.h)
    else()
        message(
            FATAL_ERROR
            "FindCHOLMOD: could not find CHOLMOD version header cholmod_core.h or cholmod.h.
            CHOLMOD_INCLUDE_DIR=${CHOLMOD_INCLUDE_DIR}.
            "
        )
    endif()

    file(READ "${cholmod_header}" cholmod_header_text)

    string(REGEX MATCH "CHOLMOD_MAIN_VERSION[ \t]+([0-9]+)" _ "${cholmod_header_text}")
    set(cholmod_main "${CMAKE_MATCH_1}")

    string(REGEX MATCH "CHOLMOD_SUB_VERSION[ \t]+([0-9]+)" _ "${cholmod_header_text}")
    set(cholmod_sub "${CMAKE_MATCH_1}")

    string(REGEX MATCH "CHOLMOD_SUBSUB_VERSION[ \t]+([0-9]+)" _ "${cholmod_header_text}")
    set(cholmod_subsub "${CMAKE_MATCH_1}")

    if(cholmod_main STREQUAL "" OR cholmod_sub STREQUAL "" OR cholmod_subsub STREQUAL "")
        message(
            FATAL_ERROR
            "FindCHOLMOD: could not parse CHOLMOD_{MAIN,SUB,SUBSUB}_VERSION from header '${cholmod_header}'
            cholmod_main='${cholmod_main}'
            cholmod_sub='${cholmod_sub}'
            cholmod_subsub='${cholmod_subsub}'
            "
        )
    endif()

    set(CHOLMOD_VERSION "${cholmod_main}.${cholmod_sub}.${cholmod_subsub}")

    unset(cholmod_main)
    unset(cholmod_sub)
    unset(cholmod_subsub)
    unset(cholmod_header_text)
    unset(cholmod_header)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    CHOLMOD
    REQUIRED_VARS
        CHOLMOD_LIBRARY
        CHOLMOD_INCLUDE_DIR
        AMD_LIBRARY
        CAMD_LIBRARY
        COLAMD_LIBRARY
        CCOLAMD_LIBRARY
        SUITESPARSECONFIG_LIBRARY
    VERSION_VAR CHOLMOD_VERSION
)

if(NOT CHOLMOD_FOUND)
    return()
endif()

# BLAS / LAPACK are required to resolve CHOLMOD's symbols at link time.
if(NOT TARGET BLAS::BLAS)
    find_package(BLAS QUIET)
endif()
if(NOT TARGET LAPACK::LAPACK)
    find_package(LAPACK QUIET)
endif()

# Detect whether CHOLMOD was built against OpenMP. The upstream config package
# (SuiteSparse >= 6.0) propagates OpenMP::OpenMP_C through its imported targets,
# so we replicate that here or downstream links will fail on omp_*/__kmpc_*/GOMP_*.
set(CHOLMOD_HAS_OPENMP false)

# 1) SuiteSparse >= 6.0 records build options in cholmod.h, where a bare
# "#define CHOLMOD_HAS_OPENMP" (rather than "/* #undef ... */") means OpenMP is on.
if(EXISTS ${CHOLMOD_INCLUDE_DIR}/cholmod.h)
    file(READ ${CHOLMOD_INCLUDE_DIR}/cholmod.h cholmod_h_text)
    if(cholmod_h_text MATCHES "#define CHOLMOD_HAS_OPENMP")
        set(CHOLMOD_HAS_OPENMP true)
    endif()
    unset(cholmod_h_text)
endif()

# 2) SuiteSparse <= 5.x has no such macro, so scan the library with the built-in
# file(STRINGS) (no otool/readelf/nm needed) for the OpenMP runtime dependency
# (libgomp/libomp/libiomp5) or its symbols (GOMP_, __kmpc_, omp_get_*_threads).
if(NOT CHOLMOD_HAS_OPENMP AND EXISTS "${CHOLMOD_LIBRARY}")
    file(
        STRINGS "${CHOLMOD_LIBRARY}"
        cholmod_omp_refs
        REGEX "lib(g?omp|iomp5)|GOMP_|__kmpc_|omp_get_(max|num)_threads"
        LIMIT_COUNT 1
    )
    if(cholmod_omp_refs)
        set(CHOLMOD_HAS_OPENMP true)
    endif()
    unset(cholmod_omp_refs)
endif()

if(CHOLMOD_HAS_OPENMP AND NOT TARGET OpenMP::OpenMP_C)
    find_package(OpenMP QUIET COMPONENTS C)
endif()

if(NOT TARGET SuiteSparse::SuiteSparseConfig)
    add_library(SuiteSparse::SuiteSparseConfig UNKNOWN IMPORTED)
    set_target_properties(
        SuiteSparse::SuiteSparseConfig
        PROPERTIES
            IMPORTED_LOCATION ${SUITESPARSECONFIG_LIBRARY}
            INTERFACE_INCLUDE_DIRECTORIES ${CHOLMOD_INCLUDE_DIR}
    )
    # All SuiteSparse components link SuiteSparseConfig, so attaching OpenMP here
    # propagates it everywhere (matching the config-package behaviour).
    if(CHOLMOD_HAS_OPENMP AND TARGET OpenMP::OpenMP_C)
        set_target_properties(
            SuiteSparse::SuiteSparseConfig
            PROPERTIES INTERFACE_LINK_LIBRARIES OpenMP::OpenMP_C
        )
    endif()
endif()

foreach(comp AMD CAMD COLAMD CCOLAMD)
    if(NOT TARGET SuiteSparse::${comp})
        add_library(SuiteSparse::${comp} UNKNOWN IMPORTED)
        set_target_properties(
            SuiteSparse::${comp}
            PROPERTIES
                IMPORTED_LOCATION ${${comp}_LIBRARY}
                INTERFACE_INCLUDE_DIRECTORIES ${CHOLMOD_INCLUDE_DIR}
                INTERFACE_LINK_LIBRARIES SuiteSparse::SuiteSparseConfig
        )
    endif()
endforeach()

if(NOT TARGET SuiteSparse::CHOLMOD)
    add_library(SuiteSparse::CHOLMOD UNKNOWN IMPORTED)

    set(cholmod_link_libs
        SuiteSparse::AMD
        SuiteSparse::CAMD
        SuiteSparse::COLAMD
        SuiteSparse::CCOLAMD
        SuiteSparse::SuiteSparseConfig
    )
    if(TARGET BLAS::BLAS)
        list(APPEND cholmod_link_libs BLAS::BLAS)
    elseif(BLAS_LIBRARIES)
        list(APPEND cholmod_link_libs ${BLAS_LIBRARIES})
    endif()

    if(TARGET LAPACK::LAPACK)
        list(APPEND cholmod_link_libs LAPACK::LAPACK)
    elseif(LAPACK_LIBRARIES)
        list(APPEND cholmod_link_libs ${LAPACK_LIBRARIES})
    endif()

    set_target_properties(
        SuiteSparse::CHOLMOD
        PROPERTIES
            IMPORTED_LOCATION ${CHOLMOD_LIBRARY}
            INTERFACE_INCLUDE_DIRECTORIES ${CHOLMOD_INCLUDE_DIR}
            INTERFACE_LINK_LIBRARIES ${cholmod_link_libs}
    )
    unset(cholmod_link_libs)
endif()

mark_as_advanced(
    CHOLMOD_INCLUDE_DIR
    CHOLMOD_LIBRARY
    AMD_LIBRARY
    CAMD_LIBRARY
    COLAMD_LIBRARY
    CCOLAMD_LIBRARY
    SUITESPARSECONFIG_LIBRARY
)
