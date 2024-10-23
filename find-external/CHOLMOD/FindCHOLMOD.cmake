# This file has been imported from Eigen. See
# https://gitlab.com/libeigen/eigen/-/blob/master/cmake/FindCHOLMOD.cmake It has
# been then adapted by Justin Carpentier <justin.carpentier@inria.fr> to comply
# with the API of the JRL CMake module.

# CHOLMOD lib usually requires linking to a blas and lapack library. It is up to
# the user of this module to find a BLAS and link to it.

if(CHOLMOD_INCLUDES AND CHOLMOD_LIBRARIES)
  set(CHOLMOD_FIND_QUIETLY TRUE)
endif()

find_path(
  CHOLMOD_INCLUDES
  NAMES cholmod.h
  PATHS $ENV{CHOLMODDIR} ${INCLUDE_INSTALL_DIR}
  PATH_SUFFIXES suitesparse ufsparse
)

find_library(
  CHOLMOD_LIBRARIES
  cholmod
  PATHS $ENV{CHOLMODDIR} ${LIB_INSTALL_DIR}
)

if(CHOLMOD_LIBRARIES)
  get_filename_component(CHOLMOD_LIBDIR ${CHOLMOD_LIBRARIES} PATH)

  find_library(
    AMD_LIBRARY
    amd
    PATHS ${CHOLMOD_LIBDIR} $ENV{CHOLMODDIR} ${LIB_INSTALL_DIR}
  )
  if(AMD_LIBRARY)
    list(APPEND CHOLMOD_DEPENDENCIES ${AMD_LIBRARY})
  else()
    set(CHOLMOD_LIBRARIES FALSE)
  endif()
endif()

if(CHOLMOD_LIBRARIES)
  find_library(
    COLAMD_LIBRARY
    colamd
    PATHS ${CHOLMOD_LIBDIR} $ENV{CHOLMODDIR} ${LIB_INSTALL_DIR}
  )
  if(COLAMD_LIBRARY)
    list(APPEND CHOLMOD_DEPENDENCIES ${COLAMD_LIBRARY})
  else()
    set(CHOLMOD_LIBRARIES FALSE)
  endif()
endif()

if(CHOLMOD_LIBRARIES)
  find_library(
    CAMD_LIBRARY
    camd
    PATHS ${CHOLMOD_LIBDIR} $ENV{CHOLMODDIR} ${LIB_INSTALL_DIR}
  )
  if(CAMD_LIBRARY)
    list(APPEND CHOLMOD_DEPENDENCIES ${CAMD_LIBRARY})
  else()
    set(CHOLMOD_LIBRARIES FALSE)
  endif()
endif()

if(CHOLMOD_LIBRARIES)
  find_library(
    CCOLAMD_LIBRARY
    ccolamd
    PATHS ${CHOLMOD_LIBDIR} $ENV{CHOLMODDIR} ${LIB_INSTALL_DIR}
  )
  if(CCOLAMD_LIBRARY)
    list(APPEND CHOLMOD_DEPENDENCIES ${CCOLAMD_LIBRARY})
  else()
    set(CHOLMOD_LIBRARIES FALSE)
  endif()
endif()

if(CHOLMOD_LIBRARIES)
  find_library(
    CHOLMOD_METIS_LIBRARY
    metis
    PATHS ${CHOLMOD_LIBDIR} $ENV{CHOLMODDIR} ${LIB_INSTALL_DIR}
  )
  if(CHOLMOD_METIS_LIBRARY)
    list(APPEND CHOLMOD_DEPENDENCIES ${CHOLMOD_METIS_LIBRARY})
  endif()
endif()

if(CHOLMOD_LIBRARIES)
  find_library(
    SUITESPARSE_LIBRARY
    SuiteSparse
    PATHS ${CHOLMOD_LIBDIR} $ENV{CHOLMODDIR} ${LIB_INSTALL_DIR}
  )
  if(SUITESPARSE_LIBRARY)
    list(APPEND CHOLMOD_DEPENDENCIES ${SUITESPARSE_LIBRARY})
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  CHOLMOD
  DEFAULT_MSG
  CHOLMOD_INCLUDES
  CHOLMOD_LIBRARIES
  CHOLMOD_DEPENDENCIES
)

if(CHOLMOD_LIBRARIES AND NOT TARGET CHOLMOD::CHOLMOD)
  add_library(CHOLMOD::CHOLMOD SHARED IMPORTED)
  set_target_properties(
    CHOLMOD::CHOLMOD
    PROPERTIES
      INTERFACE_LINK_LIBRARIES "${CHOLMOD_DEPENDENCIES}"
      INTERFACE_INCLUDE_DIRECTORIES "${CHOLMOD_INCLUDES}"
      IMPORTED_CONFIGURATIONS "RELEASE"
  )
  if(WIN32)
    set_target_properties(
      CHOLMOD::CHOLMOD
      PROPERTIES IMPORTED_IMPLIB_RELEASE "${CHOLMOD_LIBRARIES}"
    )
  else()
    set_target_properties(
      CHOLMOD::CHOLMOD
      PROPERTIES IMPORTED_LOCATION_RELEASE "${CHOLMOD_LIBRARIES}"
    )
  endif()
endif()

mark_as_advanced(
  CHOLMOD_INCLUDES
  CHOLMOD_LIBRARIES
  CHOLMOD_DEPENDENCIES
  AMD_LIBRARY
  COLAMD_LIBRARY
  SUITESPARSE_LIBRARY
  CAMD_LIBRARY
  CCOLAMD_LIBRARY
  CHOLMOD_METIS_LIBRARY
)
