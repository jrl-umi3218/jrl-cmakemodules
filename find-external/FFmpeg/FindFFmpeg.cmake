find_package(PkgConfig QUIET REQUIRED)
include(FindPackageHandleStandardArgs)

if(DEFINED FFmpeg_FIND_COMPONENTS)
  message(STATUS "Looking for FFmpeg with components ${FFmpeg_FIND_COMPONENTS}")
else()
  set(FFmpeg_FIND_COMPONENTS avcodec avformat avutil)
endif()

add_library(FFmpeg INTERFACE IMPORTED GLOBAL)
foreach(_component IN LISTS FFmpeg_FIND_COMPONENTS)
  pkg_check_modules(pc_${_component} IMPORTED_TARGET lib${_component})

  if(${pc_${_component}_FOUND})
    target_link_libraries(FFmpeg INTERFACE PkgConfig::pc_${_component})
    add_library(FFmpeg::${_component} ALIAS PkgConfig::pc_${_component})
    set(FFmpeg_${_component}_FOUND True)
  endif()
endforeach()

find_package_handle_standard_args(
  FFmpeg
  FAIL_MESSAGE DEFAULT_MSG
  HANDLE_COMPONENTS
)
