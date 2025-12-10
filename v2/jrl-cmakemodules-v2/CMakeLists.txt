cmake_minimum_required(VERSION 3.22...4.2)
project(jrl-cmakemodules-v2 VERSION 2.0.0)

include(${CMAKE_CURRENT_SOURCE_DIR}/modules/jrl.cmake)

if(CMAKE_UTILS_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

if(NOT PROJECT_IS_TOP_LEVEL)
    return()
endif()

include(GNUInstallDirs)

# Where to install the <project>-config.cmake and related files
# Here we choose <prefix>/share/cmake/<project>
set(CMAKE_FILES_INSTALL_DIR ${CMAKE_INSTALL_DATAROOTDIR}/cmake/${PROJECT_NAME})

install(
    DIRECTORY external-modules find-modules modules templates
    DESTINATION ${CMAKE_FILES_INSTALL_DIR}
)

jrl_export_package(
    PACKAGE_CONFIG_TEMPLATE
        ${CMAKE_CURRENT_SOURCE_DIR}/templates/config-basic.cmake.in
    PACKAGE_CONFIG_EXTRA_CONTENT
        [[include("${CMAKE_CURRENT_LIST_DIR}/modules/jrl.cmake")]]
    CMAKE_FILES_INSTALL_DIR
        ${CMAKE_FILES_INSTALL_DIR}
)
