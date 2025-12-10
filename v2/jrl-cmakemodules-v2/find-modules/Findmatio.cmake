find_library(matio_LIBRARY NAMES matio libmatio REQUIRED)
find_path(matio_INCLUDE_DIR matio.h matio_pubconf.h REQUIRED)

mark_as_advanced(matio_LIBRARY matio_INCLUDE_DIR)

# read the version from the matio_pubconf.h file
if(NOT TARGET matio::matio)
    file(READ "${matio_INCLUDE_DIR}/matio_pubconf.h" matio_pubconf_h)
    string(REGEX MATCH "#define[ \t]+MATIO_MAJOR_VERSION[ \t]+([0-9]+)" _ ${matio_pubconf_h})
    set(MATIO_MAJOR_VERSION "${CMAKE_MATCH_1}")
    string(REGEX MATCH "#define[ \t]+MATIO_MINOR_VERSION[ \t]+([0-9]+)" _ ${matio_pubconf_h})
    set(MATIO_MINOR_VERSION "${CMAKE_MATCH_1}")
    string(REGEX MATCH "#define[ \t]+MATIO_RELEASE_LEVEL[ \t]+([0-9]+)" _ ${matio_pubconf_h})
    set(MATIO_RELEASE_LEVEL "${CMAKE_MATCH_1}")
    set(matio_VERSION ${MATIO_MAJOR_VERSION}.${MATIO_MINOR_VERSION}.${MATIO_RELEASE_LEVEL})
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    matio
    REQUIRED_VARS matio_LIBRARY matio_INCLUDE_DIR
    VERSION_VAR matio_VERSION
)

if(NOT TARGET matio::matio)
    add_library(matio::matio UNKNOWN IMPORTED)
    set_target_properties(
        matio::matio
        PROPERTIES
            IMPORTED_LOCATION ${matio_LIBRARY}
            VERSION ${matio_VERSION}
            INCLUDE_DIRECTORIES ${matio_INCLUDE_DIR}
    )
endif()
