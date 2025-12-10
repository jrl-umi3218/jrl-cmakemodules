find_path(simde_INCLUDE_DIR NAMES simde/simde-common.h)

# Read the version number from simde-common.h
if(simde_INCLUDE_DIR)
    file(READ ${simde_INCLUDE_DIR}/simde/simde-common.h simde_common_h)
    string(REGEX MATCH "#define SIMDE_VERSION_MAJOR[ \t]+([0-9]+)" _match_major ${simde_common_h})
    set(simde_VERSION_MAJOR ${CMAKE_MATCH_1})
    string(REGEX MATCH "#define SIMDE_VERSION_MINOR[ \t]+([0-9]+)" _match_minor ${simde_common_h})
    set(simde_VERSION_MINOR ${CMAKE_MATCH_1})
    string(REGEX MATCH "#define SIMDE_VERSION_MICRO[ \t]+([0-9]+)" _match_micro ${simde_common_h})
    set(simde_VERSION_MICRO ${CMAKE_MATCH_1})
    set(simde_VERSION ${simde_VERSION_MAJOR}.${simde_VERSION_MINOR}.${simde_VERSION_MICRO})
endif()

mark_as_advanced(simde_INCLUDE_DIR simde_VERSION)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(simde REQUIRED_VARS simde_INCLUDE_DIR VERSION_VAR simde_VERSION)

if(simde_FOUND)
    add_library(simde::simde INTERFACE IMPORTED)
    set_target_properties(
        simde::simde
        PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES ${simde_INCLUDE_DIR}
            INTERFACE_VERSION ${simde_VERSION}
    )
endif()
