if(NOT APPLE)
    message(WARNING "Accelerate support is only available on APPLE systems")
endif()

find_path(Accelerate_INCLUDE_DIR NAMES Accelerate.h)
find_library(Accelerate_LIBRARY NAMES Accelerate)

# Determine if the Accelerate framework detected includes the sparse solvers.
# ref: https://ceres-solver.googlesource.com/ceres-solver/+/refs/heads/master/cmake/FindAccelerateSparse.cmake
include(CheckCXXSourceCompiles)
set(CMAKE_REQUIRED_INCLUDES ${Accelerate_INCLUDE_DIR})
set(CMAKE_REQUIRED_LIBRARIES ${Accelerate_LIBRARY})
check_cxx_source_compiles(
    "#include <Accelerate/Accelerate.h>
   int main() {
     SparseMatrix_Double A;
     SparseFactor(SparseFactorizationCholesky, A);
     return 0;
   }"
    Accelerate_HAS_SPARSE_SUPPORT
)
unset(CMAKE_REQUIRED_INCLUDES)
unset(CMAKE_REQUIRED_LIBRARIES)

mark_as_advanced(Accelerate_INCLUDE_DIR Accelerate_LIBRARY Accelerate_HAS_SPARSE_SUPPORT)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    Accelerate
    REQUIRED_VARS Accelerate_INCLUDE_DIR Accelerate_LIBRARY Accelerate_HAS_SPARSE_SUPPORT
)

if(Accelerate_FOUND)
    add_library(Accelerate::Accelerate INTERFACE IMPORTED)
    set_target_properties(
        Accelerate::Accelerate
        PROPERTIES
            INTERFACE_LINK_LIBRARIES "-framework Accelerate"
            INTERFACE_INCLUDE_DIRECTORIES ${Accelerate_INCLUDE_DIR}
    )
    # https://cmake.org/cmake/help/latest/prop_tgt/IMPORTED_LOCATION.html
    # Added in version 3.28: For ordinary frameworks on Apple platforms,
    # this may be the location of the .framework folder itself. For XCFrameworks,
    # it may be the location of the .xcframework folder, in which case any target
    # that links against it will get the selected library's Headers directory as a usage requirement.
endif()
