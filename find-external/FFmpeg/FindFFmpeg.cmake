#[=====[
FindFFmpeg
----------

Finds the FFmpeg libraries.

Provides the following variables:
* FFmpeg_FOUND
* FFmpeg_VERSION

#]=====]
find_package(PkgConfig QUIET REQUIRED)

if(DEFINED FFmpeg_FIND_COMPONENTS)
  if(NOT "avutil" IN_LIST FFmpeg_FIND_COMPONENTS)
    message(DEBUG "The avutil component is mandatory - it will be added")
    list(APPEND FFmpeg_FIND_COMPONENTS avutil)
  endif()
else()
  set(FFmpeg_FIND_COMPONENTS avcodec avformat avutil)
endif()
string(REPLACE ";" " " _ffmpeg_components "${FFmpeg_FIND_COMPONENTS}")
message(STATUS "Looking for FFmpeg with components ${_ffmpeg_components}")
unset(_ffmpeg_components)

foreach(_comp IN LISTS FFmpeg_FIND_COMPONENTS)
  pkg_check_modules(pc_${_comp} IMPORTED_TARGET lib${_comp})
  set(FFmpeg_${_comp}_FOUND ${pc_${_comp}_FOUND})

  if(${FFmpeg_${_comp}_FOUND})
    add_library(FFmpeg::${_comp} ALIAS PkgConfig::pc_${_comp})
    message(STATUS "  - found component ${_comp}")
    get_target_property(
      FFmpeg_${_comp}_INCLUDE_DIR
      PkgConfig::pc_${_comp}
      INTERFACE_INCLUDE_DIRECTORIES
    )
    mark_as_advanced(FFmpeg_${_comp}_INCLUDE_DIR)
  endif()
endforeach()

if(TARGET FFmpeg::avutil)
  set(
    _ffmpeg_version_header_path
    "${FFmpeg_avutil_INCLUDE_DIR}/libavutil/ffversion.h"
  )
  message(STATUS "FFmpeg version header is at ${_ffmpeg_version_header_path}")
  if(EXISTS "${_ffmpeg_version_header_path}")
    file(
      STRINGS
      "${_ffmpeg_version_header_path}"
      _ffmpeg_version
      REGEX "FFMPEG_VERSION"
    )
    string(
      REGEX REPLACE
      ".*\"n?\(.*\)\""
      "\\1"
      FFmpeg_VERSION
      "${_ffmpeg_version}"
    )
    unset(_ffmpeg_version)
  else()
    set(FFmpeg_VERSION FFMPEG_VERSION-NOTFOUND)
  endif()
  unset(_ffmpeg_version_header_path)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  FFmpeg
  HANDLE_VERSION_RANGE
  HANDLE_COMPONENTS
  VERSION_VAR FFmpeg_VERSION
)
