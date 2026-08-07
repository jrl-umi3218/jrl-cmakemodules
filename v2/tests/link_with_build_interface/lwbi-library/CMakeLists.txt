cmake_minimum_required(VERSION 3.22)

project(lwbi-library VERSION 1.0.0 LANGUAGES CXX)

find_package(jrl-cmakemodules 1.2.0 CONFIG REQUIRED)
jrl_configure_defaults()

# Declares <name>::<name> as an imported target and registers it as a package dependency,
# so that a find_dependency(<name>) is expected whenever a consumer links it.
function(lwbi_declare_dependency name)
    add_library(${name}::${name} INTERFACE IMPORTED GLOBAL)
    jrl_export_dependency(
        PACKAGE_NAME ${name}
        FIND_PACKAGE_ARGS "${name};REQUIRED"
        PACKAGE_TARGETS "${name}::${name}"
        EXPECTED_TARGETS "${name}::${name}"
    )
endfunction()

lwbi_declare_dependency(PublicDep)
lwbi_declare_dependency(BuildOnlyDep)
lwbi_declare_dependency(InstallOnlyDep)
lwbi_declare_dependency(CondOnDep)
lwbi_declare_dependency(CondOffDep)
lwbi_declare_dependency(BuildOnlyCondDep)
lwbi_declare_dependency(InstallOnlyCondDep)
lwbi_declare_dependency(ConfigDep)
lwbi_declare_dependency(NotConfigDep)
lwbi_declare_dependency(MultilineDep)
lwbi_declare_dependency(QuotedMultilineDep)
lwbi_declare_dependency(MultilineBuildOnlyDep)
lwbi_declare_dependency(NestedIfDep)
lwbi_declare_dependency(NestedElseDep)
lwbi_declare_dependency(PrivateStaticDep)
lwbi_declare_dependency(PrivateSharedDep)
lwbi_declare_dependency(MultiConfigDep)
lwbi_declare_dependency(LinkLangDep)
lwbi_declare_dependency(NotLinkLangDep)
lwbi_declare_dependency(LinkLangIdDep)
lwbi_declare_dependency(TargetPropDep)
lwbi_declare_dependency(CompilerIdDep)
lwbi_declare_dependency(WholeArchiveDep)
lwbi_declare_dependency(WholeArchiveDep2)
lwbi_declare_dependency(BuildOnlyWholeArchiveDep)

add_library(lwbi INTERFACE)

# Every form a dependency can take in INTERFACE_LINK_LIBRARIES. Only the ones a consumer
# of the installed package ends up linking must get a find_dependency().
target_link_libraries(
    lwbi
    INTERFACE
        # Always linked.
        PublicDep::PublicDep
        # Build tree only.
        $<BUILD_INTERFACE:BuildOnlyDep::BuildOnlyDep>
        # Installed package only.
        $<INSTALL_INTERFACE:InstallOnlyDep::InstallOnlyDep>
        # Conditions the consumer does not see, they are resolved here.
        $<$<BOOL:ON>:CondOnDep::CondOnDep>
        $<$<BOOL:OFF>:CondOffDep::CondOffDep>
        # Nested: the interface marker wins over the condition.
        $<BUILD_INTERFACE:$<$<BOOL:ON>:BuildOnlyCondDep::BuildOnlyCondDep>>
        $<INSTALL_INTERFACE:$<$<BOOL:ON>:InstallOnlyCondDep::InstallOnlyCondDep>>
        # Conditions the consumer resolves, in whatever configuration they build in.
        # Both branches have to be exported, we cannot know which one they will take.
        $<$<CONFIG:Debug>:ConfigDep::ConfigDep>
        $<$<NOT:$<CONFIG:Debug>>:NotConfigDep::NotConfigDep>
        # A condition can list several configurations at once.
        $<$<CONFIG:Debug,Release>:MultiConfigDep::MultiConfigDep>
        # The language the consumer links with is unknown here too, and these conditions
        # cannot even be evaluated outside of a link context.
        $<$<LINK_LANGUAGE:CXX>:LinkLangDep::LinkLangDep>
        $<$<NOT:$<LINK_LANGUAGE:CXX>>:NotLinkLangDep::NotLinkLangDep>
        $<$<LINK_LANG_AND_ID:CXX,GNU,Clang,AppleClang,MSVC>:LinkLangIdDep::LinkLangIdDep>
        # Read from whichever target is being linked. Only our own answer is available
        # here, so that is the one exported.
        $<$<BOOL:$<TARGET_PROPERTY:TYPE>>:TargetPropDep::TargetPropDep>
        $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang,MSVC,IntelLLVM>:CompilerIdDep::CompilerIdDep>
        # A link feature. Its first parameter names the feature, the others are libraries.
        "$<LINK_LIBRARY:WHOLE_ARCHIVE,WholeArchiveDep::WholeArchiveDep,WholeArchiveDep2::WholeArchiveDep2>"
        $<BUILD_INTERFACE:"$<LINK_LIBRARY:WHOLE_ARCHIVE,BuildOnlyWholeArchiveDep::BuildOnlyWholeArchiveDep>">
)

# Generator expressions can be spread over several lines. Unquoted, the line breaks become
# list separators; quoted, they stay inside the expression.
# gersemi: off
target_link_libraries(
    lwbi
    INTERFACE
        $<INSTALL_INTERFACE:
            MultilineDep::MultilineDep
        >
        "$<INSTALL_INTERFACE:
            QuotedMultilineDep::QuotedMultilineDep
        >"
        $<BUILD_INTERFACE:$<$<BOOL:ON>:
            MultilineBuildOnlyDep::MultilineBuildOnlyDep
        >>
        # Nested $<IF:>/$<AND:>, wrapped in $<INSTALL_INTERFACE:> so that the indentation
        # of the values is allowed: outside of it, a link library with leading or trailing
        # whitespace is refused by CMP0004. The condition itself has to stay on one line,
        # CMake rejects whitespace around the parameters of $<AND:>.
        "$<INSTALL_INTERFACE:$<IF:$<AND:$<CONFIG:Debug>,$<BOOL:ON>>,
            NestedIfDep::NestedIfDep,
            NestedElseDep::NestedElseDep
        >>"
)
# gersemi: on

# $<BUILD_LOCAL_INTERFACE:> needs CMake 3.26.
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.26)
    lwbi_declare_dependency(LocalOnlyDep)
    target_link_libraries(lwbi INTERFACE $<BUILD_LOCAL_INTERFACE:LocalOnlyDep::LocalOnlyDep>)
endif()

# A private dependency of a static library: CMake records it as $<LINK_ONLY:...> in the
# INTERFACE_LINK_LIBRARIES of the target, all by itself. A consumer of the installed
# library still links it.
add_library(lwbi-static STATIC src/lwbi.cpp)
target_link_libraries(lwbi-static PRIVATE PrivateStaticDep::PrivateStaticDep)

# The same private dependency on a shared library: it is resolved when the library itself is
# linked, so CMake puts nothing in INTERFACE_LINK_LIBRARIES and a consumer of the installed
# library never links it. The mirror image of lwbi-static above.
add_library(lwbi-shared SHARED src/lwbi.cpp)
target_link_libraries(lwbi-shared PRIVATE PrivateSharedDep::PrivateSharedDep)
# Without an exported symbol MSVC writes no import library, which install(TARGETS ARCHIVE)
# then fails to find.
set_target_properties(lwbi-shared PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)

jrl_add_export_component(NAME lwbi TARGETS lwbi lwbi-static lwbi-shared)
jrl_export_package()

########## TESTS ##########

jrl_include_ctest()
enable_testing()

add_test(
    NAME "link_with_build_interface: exported dependencies"
    COMMAND
        ${CMAKE_COMMAND}
        -DDEPENDENCIES_FILE=${CMAKE_INSTALL_PREFIX}/lib/cmake/lwbi-library/lwbi/dependencies.cmake
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/check_dependencies.cmake"
)

# Same check on a staged install, which moves the whole install tree.
set(staged_dir "${CMAKE_CURRENT_BINARY_DIR}/staged")

add_test(
    NAME "link_with_build_interface: staged install (DESTDIR)"
    COMMAND
        ${CMAKE_COMMAND} -E env DESTDIR=${staged_dir} ${CMAKE_COMMAND} --install
        "${CMAKE_CURRENT_BINARY_DIR}"
)

add_test(
    NAME "link_with_build_interface: exported dependencies (DESTDIR)"
    COMMAND
        ${CMAKE_COMMAND}
        -DDEPENDENCIES_FILE=${staged_dir}${CMAKE_INSTALL_PREFIX}/lib/cmake/lwbi-library/lwbi/dependencies.cmake
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/check_dependencies.cmake"
)
set_tests_properties(
    "link_with_build_interface: exported dependencies (DESTDIR)"
    PROPERTIES DEPENDS "link_with_build_interface: staged install (DESTDIR)"
)
