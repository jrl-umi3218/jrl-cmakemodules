# Try to find the GNU Multiple Precision Arithmetic Library (GMP) See
# http://gmplib.org/

if(GMP_INCLUDES AND GMP_LIBRARIES)
  set(GMP_FIND_QUIETLY TRUE)
endif(GMP_INCLUDES AND GMP_LIBRARIES)

find_path(
  GMP_INCLUDES
  NAMES gmp.h
  PATHS $ENV{GMPDIR} ${INCLUDE_INSTALL_DIR})

find_library(
  GMP_LIBRARIES
  NAMES gmp
  PATHS $ENV{GMPDIR} ${LIB_INSTALL_DIR})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GMP DEFAULT_MSG GMP_INCLUDES GMP_LIBRARIES)

# Set gmp target
if(GMP_FOUND)
  add_library(gmp SHARED IMPORTED)
  set_target_properties(
    gmp PROPERTIES IMPORTED_LOCATION ${GMP_LIBRARIES}
                   INTERFACE_INCLUDE_DIRECTORIES "${GMP_INCLUDE_DIR}")
endif()

mark_as_advanced(GMP_INCLUDES GMP_LIBRARIES)
