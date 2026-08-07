# Invoked as: cmake -DDEPENDENCIES_FILE=<file> -P check_dependencies.cmake

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
