# Copyright 2026 Inria

# Finds GMP (https://gmplib.org), which ships no GMPConfig.cmake, and defines GMP::GMP.

# An existing target (e.g. built in-tree) is enough, unless a version has to be checked below.
if(TARGET GMP::GMP AND NOT GMP_FIND_VERSION)
    set(GMP_FOUND TRUE)
    return()
endif()

find_path(GMP_INCLUDE_DIR NAMES gmp.h)
find_library(GMP_LIBRARY NAMES gmp libgmp)

mark_as_advanced(GMP_INCLUDE_DIR GMP_LIBRARY)

if(GMP_INCLUDE_DIR)
    # `#define __GNU_MP_VERSION            6`
    # `#define __GNU_MP_VERSION_MINOR      3`
    # `#define __GNU_MP_VERSION_PATCHLEVEL 0`
    file(READ "${GMP_INCLUDE_DIR}/gmp.h" gmp_h)
    string(REGEX MATCH "#[ \t]*define[ \t]+__GNU_MP_VERSION[ \t]+([0-9]+)" _ "${gmp_h}")
    set(GMP_VERSION_MAJOR "${CMAKE_MATCH_1}")
    string(REGEX MATCH "#[ \t]*define[ \t]+__GNU_MP_VERSION_MINOR[ \t]+([0-9]+)" _ "${gmp_h}")
    set(GMP_VERSION_MINOR "${CMAKE_MATCH_1}")
    string(REGEX MATCH "#[ \t]*define[ \t]+__GNU_MP_VERSION_PATCHLEVEL[ \t]+([0-9]+)" _ "${gmp_h}")
    set(GMP_VERSION_PATCH "${CMAKE_MATCH_1}")
    unset(gmp_h)

    # Some distributions (e.g. Fedora) only include an arch specific header here, so
    # leave GMP_VERSION empty rather than reporting a bogus ".." version.
    if(GMP_VERSION_MAJOR AND GMP_VERSION_MINOR AND NOT GMP_VERSION_PATCH STREQUAL "")
        set(GMP_VERSION "${GMP_VERSION_MAJOR}.${GMP_VERSION_MINOR}.${GMP_VERSION_PATCH}")
    endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    GMP
    REQUIRED_VARS GMP_LIBRARY GMP_INCLUDE_DIR
    VERSION_VAR GMP_VERSION
)

if(GMP_FOUND AND NOT TARGET GMP::GMP)
    add_library(GMP::GMP UNKNOWN IMPORTED)
    set_target_properties(
        GMP::GMP
        PROPERTIES
            IMPORTED_LOCATION "${GMP_LIBRARY}"
            VERSION "${GMP_VERSION}"
            INTERFACE_INCLUDE_DIRECTORIES "${GMP_INCLUDE_DIR}"
    )
endif()
