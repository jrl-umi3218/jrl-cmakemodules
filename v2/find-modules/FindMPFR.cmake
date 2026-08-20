# Copyright 2026 Inria

# Finds MPFR (https://www.mpfr.org) and its GMP dependency, defining MPFR::MPFR and GMP::GMP.

# An existing target (e.g. built in-tree) is enough, unless a version has to be checked below.
if(TARGET MPFR::MPFR AND NOT MPFR_FIND_VERSION)
    set(MPFR_FOUND TRUE)
    return()
endif()

find_path(MPFR_INCLUDE_DIR NAMES mpfr.h)
find_library(MPFR_LIBRARY NAMES mpfr libmpfr)

mark_as_advanced(MPFR_INCLUDE_DIR MPFR_LIBRARY)

if(MPFR_INCLUDE_DIR)
    # `#define MPFR_VERSION_MAJOR 4`
    # `#define MPFR_VERSION_MINOR 2`
    # `#define MPFR_VERSION_PATCHLEVEL 2`
    file(READ "${MPFR_INCLUDE_DIR}/mpfr.h" mpfr_h)
    string(REGEX MATCH "#[ \t]*define[ \t]+MPFR_VERSION_MAJOR[ \t]+([0-9]+)" _ "${mpfr_h}")
    set(MPFR_VERSION_MAJOR "${CMAKE_MATCH_1}")
    string(REGEX MATCH "#[ \t]*define[ \t]+MPFR_VERSION_MINOR[ \t]+([0-9]+)" _ "${mpfr_h}")
    set(MPFR_VERSION_MINOR "${CMAKE_MATCH_1}")
    string(REGEX MATCH "#[ \t]*define[ \t]+MPFR_VERSION_PATCHLEVEL[ \t]+([0-9]+)" _ "${mpfr_h}")
    set(MPFR_VERSION_PATCH "${CMAKE_MATCH_1}")
    unset(mpfr_h)

    if(
        MPFR_VERSION_MAJOR
        AND NOT MPFR_VERSION_MINOR STREQUAL ""
        AND NOT MPFR_VERSION_PATCH STREQUAL ""
    )
        set(MPFR_VERSION "${MPFR_VERSION_MAJOR}.${MPFR_VERSION_MINOR}.${MPFR_VERSION_PATCH}")
    endif()
endif()

set(mpfr_required_vars MPFR_LIBRARY MPFR_INCLUDE_DIR)

if(NOT TARGET GMP::GMP)
    find_path(GMP_INCLUDE_DIR NAMES gmp.h)
    find_library(GMP_LIBRARY NAMES gmp libgmp)
    mark_as_advanced(GMP_INCLUDE_DIR GMP_LIBRARY)
    list(APPEND mpfr_required_vars GMP_LIBRARY GMP_INCLUDE_DIR)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MPFR REQUIRED_VARS ${mpfr_required_vars} VERSION_VAR MPFR_VERSION)
unset(mpfr_required_vars)

# Define GMP::GMP if not already defined.
if(MPFR_FOUND AND NOT TARGET GMP::GMP)
    add_library(GMP::GMP UNKNOWN IMPORTED)
    set_target_properties(
        GMP::GMP
        PROPERTIES
            IMPORTED_LOCATION "${GMP_LIBRARY}"
            INTERFACE_INCLUDE_DIRECTORIES "${GMP_INCLUDE_DIR}"
    )
endif()

if(MPFR_FOUND AND NOT TARGET MPFR::MPFR)
    add_library(MPFR::MPFR UNKNOWN IMPORTED)
    set_target_properties(
        MPFR::MPFR
        PROPERTIES
            IMPORTED_LOCATION "${MPFR_LIBRARY}"
            VERSION "${MPFR_VERSION}"
            INTERFACE_INCLUDE_DIRECTORIES "${MPFR_INCLUDE_DIR}"
            INTERFACE_LINK_LIBRARIES GMP::GMP
    )
endif()
