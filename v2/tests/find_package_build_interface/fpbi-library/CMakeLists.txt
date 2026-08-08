cmake_minimum_required(VERSION 3.22)

project(fpbi-library VERSION 1.0.0 LANGUAGES CXX)

find_package(jrl-cmakemodules 2.0.0 CONFIG REQUIRED)
jrl_configure_defaults()

# The fake packages live in the build tree, under a prefix laid out the way find_package()
# expects it: <prefix>/<name>*/(lib*|share)/cmake/<name>*/ is searched on every platform.
set(fake_packages_dir "${CMAKE_CURRENT_BINARY_DIR}/fake-packages")
list(APPEND CMAKE_PREFIX_PATH "${fake_packages_dir}")

# Writes a config file for a package providing <name>::<name>, then imports it through
# jrl_find_package(), which records it as a dependency of the project.
# No Find<name>.cmake exists, so find_package() falls back to config mode on its own: the
# recorded arguments stay '<name> REQUIRED' and no find module has to be reinstalled.
macro(fpbi_find_fake_package name)
    file(
        WRITE "${fake_packages_dir}/${name}/share/cmake/${name}/${name}Config.cmake"
        "set(${name}_FOUND TRUE)
if(NOT TARGET ${name}::${name})
    add_library(${name}::${name} INTERFACE IMPORTED)
endif()
"
    )
    jrl_find_package(${name} REQUIRED EXPECTED_TARGETS ${name}::${name})
endmacro()

fpbi_find_fake_package(PublicDep)
fpbi_find_fake_package(BuildOnlyDep)
fpbi_find_fake_package(InstallOnlyDep)
fpbi_find_fake_package(CondOnDep)
fpbi_find_fake_package(CondOffDep)
fpbi_find_fake_package(BuildOnlyCondDep)
fpbi_find_fake_package(InstallOnlyCondDep)
fpbi_find_fake_package(ConfigDep)
fpbi_find_fake_package(NotConfigDep)
fpbi_find_fake_package(MultilineDep)
fpbi_find_fake_package(QuotedMultilineDep)
fpbi_find_fake_package(MultilineBuildOnlyDep)
fpbi_find_fake_package(NestedIfDep)
fpbi_find_fake_package(NestedElseDep)
fpbi_find_fake_package(PrivateStaticDep)
fpbi_find_fake_package(PrivateSharedDep)
fpbi_find_fake_package(MultiConfigDep)
fpbi_find_fake_package(LinkLangDep)
fpbi_find_fake_package(NotLinkLangDep)
fpbi_find_fake_package(LinkLangIdDep)
fpbi_find_fake_package(TargetPropDep)
fpbi_find_fake_package(CompilerIdDep)
fpbi_find_fake_package(WholeArchiveDep)
fpbi_find_fake_package(WholeArchiveDep2)
fpbi_find_fake_package(BuildOnlyWholeArchiveDep)

add_library(fpbi INTERFACE)

# Every form a dependency can take in INTERFACE_LINK_LIBRARIES. Only the ones a consumer
# of the installed package ends up linking must get a find_dependency().
target_link_libraries(
    fpbi
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
    fpbi
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
    fpbi_find_fake_package(LocalOnlyDep)
    target_link_libraries(fpbi INTERFACE $<BUILD_LOCAL_INTERFACE:LocalOnlyDep::LocalOnlyDep>)
endif()

# A private dependency of a static library: CMake records it as $<LINK_ONLY:...> in the
# INTERFACE_LINK_LIBRARIES of the target, all by itself. A consumer of the installed
# library still links it.
add_library(fpbi-static STATIC src/fpbi.cpp)
target_link_libraries(fpbi-static PRIVATE PrivateStaticDep::PrivateStaticDep)

# The same private dependency on a shared library: it is resolved when the library itself is
# linked, so CMake puts nothing in INTERFACE_LINK_LIBRARIES and a consumer of the installed
# library never links it. The mirror image of fpbi-static above.
add_library(fpbi-shared SHARED src/fpbi.cpp)
target_link_libraries(fpbi-shared PRIVATE PrivateSharedDep::PrivateSharedDep)
# Without an exported symbol MSVC writes no import library, which install(TARGETS ARCHIVE)
# then fails to find.
set_target_properties(fpbi-shared PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)

jrl_add_export_component(NAME fpbi TARGETS fpbi fpbi-static fpbi-shared)
jrl_export_package()

########## TESTS ##########

jrl_include_ctest()
enable_testing()

# The reference is the file generated by the link_with_build_interface test, which declares
# the very same dependencies by hand instead of finding them.
set(expected_file "${CMAKE_CURRENT_SOURCE_DIR}/cmake/expected-dependencies.txt")

add_test(
    NAME "find_package_build_interface: exported dependencies"
    COMMAND
        ${CMAKE_COMMAND}
        -DDEPENDENCIES_FILE=${CMAKE_INSTALL_PREFIX}/lib/cmake/fpbi-library/fpbi/dependencies.cmake
        -DEXPECTED_FILE=${expected_file} -P
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/check_dependencies.cmake"
)

# Same check on a staged install, which moves the whole install tree.
set(staged_dir "${CMAKE_CURRENT_BINARY_DIR}/staged")

add_test(
    NAME "find_package_build_interface: staged install (DESTDIR)"
    COMMAND
        ${CMAKE_COMMAND} -E env DESTDIR=${staged_dir} ${CMAKE_COMMAND} --install
        "${CMAKE_CURRENT_BINARY_DIR}"
)

add_test(
    NAME "find_package_build_interface: exported dependencies (DESTDIR)"
    COMMAND
        ${CMAKE_COMMAND}
        -DDEPENDENCIES_FILE=${staged_dir}${CMAKE_INSTALL_PREFIX}/lib/cmake/fpbi-library/fpbi/dependencies.cmake
        -DEXPECTED_FILE=${expected_file} -P
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/check_dependencies.cmake"
)
set_tests_properties(
    "find_package_build_interface: exported dependencies (DESTDIR)"
    PROPERTIES DEPENDS "find_package_build_interface: staged install (DESTDIR)"
)
