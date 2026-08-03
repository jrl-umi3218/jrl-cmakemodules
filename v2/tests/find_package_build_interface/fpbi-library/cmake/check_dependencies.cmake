# Invoked as: cmake -DDEPENDENCIES_FILE=<file> -DEXPECTED_FILE=<file> -P check_dependencies.cmake

file(READ "${DEPENDENCIES_FILE}" content)
message(STATUS "${DEPENDENCIES_FILE}:\n${content}")

# Dependencies a consumer of the installed package links, and must therefore find.
set(expected
    PublicDep
    InstallOnlyDep
    CondOnDep
    InstallOnlyCondDep
    ConfigDep
    NotConfigDep
    MultilineDep
    QuotedMultilineDep
    NestedIfDep
    NestedElseDep
    PrivateStaticDep
    MultiConfigDep
    LinkLangDep
    NotLinkLangDep
    LinkLangIdDep
    TargetPropDep
    CompilerIdDep
    WholeArchiveDep
    WholeArchiveDep2
)

# Dependencies a consumer never links, and must not be forced to find.
set(unexpected
    WHOLE_ARCHIVE
    BuildOnlyDep
    CondOffDep
    BuildOnlyCondDep
    LocalOnlyDep
    MultilineBuildOnlyDep
    BuildOnlyWholeArchiveDep
    PrivateSharedDep
)

set(errors "")

foreach(dep IN LISTS expected)
    string(FIND "${content}" "find_dependency(${dep} " found)
    if(found LESS 0)
        list(APPEND errors "  - ${dep} is linked by a consumer but was not exported")
    endif()
endforeach()

foreach(dep IN LISTS unexpected)
    string(FIND "${content}" "${dep}" found)
    if(found GREATER_EQUAL 0)
        list(APPEND errors "  - ${dep} is never linked by a consumer but was exported")
    endif()
endforeach()

if(errors)
    string(REPLACE ";" "\n" errors "${errors}")
    message(FATAL_ERROR "Wrong dependencies exported by jrl_export_package():\n${errors}")
endif()

# The file must also match the one the link_with_build_interface test produces, character
# for character: importing a dependency with jrl_find_package() instead of declaring it by
# hand must not change anything in the exported package.
file(READ "${EXPECTED_FILE}" expected_content)

# Line endings and the final newline depend on the git checkout and on the formatting hooks,
# not on jrl_export_package().
string(REPLACE "\r\n" "\n" content "${content}")
string(REPLACE "\r\n" "\n" expected_content "${expected_content}")
string(STRIP "${content}" content)
string(STRIP "${expected_content}" expected_content)

if(NOT content STREQUAL expected_content)
    message(
        FATAL_ERROR
        "${DEPENDENCIES_FILE} differs from ${EXPECTED_FILE}.
Expected:
${expected_content}
Got:
${content}"
    )
endif()
