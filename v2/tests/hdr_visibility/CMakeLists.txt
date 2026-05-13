# Build and install the hdr-visibility test project
add_cmake_test(NAME hdr-visibility DEPENDS jrl-cmakemodules)

# Check that the INTERFACE header is installed
add_test(
    NAME "hdr_visibility: INTERFACE header is installed"
    COMMAND ${CMAKE_COMMAND} -E cat "${hdr-visibility_INSTALL_DIR}/include/mylib/public_header.hpp"
)

# Check that the PRIVATE header is NOT installed
add_test(
    NAME "hdr_visibility: PRIVATE header is not installed"
    COMMAND
        ${CMAKE_COMMAND} -DFILEPATH=${hdr-visibility_INSTALL_DIR}/include/mylib/private_header.hpp
        -P ${CMAKE_CURRENT_SOURCE_DIR}/check_not_exists.cmake
)
