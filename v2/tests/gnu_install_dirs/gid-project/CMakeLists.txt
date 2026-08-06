cmake_minimum_required(VERSION 3.22)

project(gid-project VERSION 1.0.0 LANGUAGES CXX)

find_package(jrl-cmakemodules 2.0.0 CONFIG REQUIRED)

jrl_configure_defaults()

# GNUInstallDirs only creates cache entries for its root dirs (BINDIR, LIBDIR, ...).
# The derived ones (DATADIR, DOCDIR, MANDIR, INFODIR, LOCALEDIR) and every
# CMAKE_INSTALL_FULL_* are plain variables, lost if GNUInstallDirs is included
# from inside a function(). They must all be usable in the caller's scope.
set(expected_install_dirs
    BINDIR
    SBINDIR
    LIBEXECDIR
    SYSCONFDIR
    SHAREDSTATEDIR
    LOCALSTATEDIR
    LIBDIR
    INCLUDEDIR
    OLDINCLUDEDIR
    DATAROOTDIR
    DATADIR
    INFODIR
    LOCALEDIR
    MANDIR
    DOCDIR
)

foreach(dir IN LISTS expected_install_dirs)
    foreach(var CMAKE_INSTALL_${dir} CMAKE_INSTALL_FULL_${dir})
        if(NOT DEFINED ${var})
            message(FATAL_ERROR "${var} is not defined after jrl_configure_defaults()")
        endif()
        if(${var} STREQUAL "")
            message(FATAL_ERROR "${var} is empty after jrl_configure_defaults()")
        endif()
    endforeach()
    message(
        STATUS
        "CMAKE_INSTALL_${dir}=${CMAKE_INSTALL_${dir}} (full: ${CMAKE_INSTALL_FULL_${dir}})"
    )
endforeach()

if(NOT CMAKE_INSTALL_DOCDIR STREQUAL "${CMAKE_INSTALL_DATAROOTDIR}/doc/${PROJECT_NAME}")
    message(
        FATAL_ERROR
        "Expected CMAKE_INSTALL_DOCDIR to be '${CMAKE_INSTALL_DATAROOTDIR}/doc/${PROJECT_NAME}', got: '${CMAKE_INSTALL_DOCDIR}'"
    )
endif()

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/test.txt" "OK\n")
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/test.txt" DESTINATION ${CMAKE_INSTALL_DOCDIR})

enable_testing()

add_test(
    NAME "gnu_install_dirs: test.txt is installed in CMAKE_INSTALL_DOCDIR"
    COMMAND ${CMAKE_COMMAND} -E cat "${CMAKE_INSTALL_FULL_DOCDIR}/test.txt"
)
