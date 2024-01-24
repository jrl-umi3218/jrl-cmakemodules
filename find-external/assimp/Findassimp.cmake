# Skip if assimp::assimp is already defined
if(TARGET assimp::assimp)
  return()
endif()

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(ASSIMP_ARCHITECTURE "64")
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
  set(ASSIMP_ARCHITECTURE "32")
endif(CMAKE_SIZEOF_VOID_P EQUAL 8)

if(WIN32)
  set(ASSIMP_ROOT_DIR CACHE PATH "ASSIMP root directory")

  # Find path of each library
  find_path(
    ASSIMP_INCLUDE_DIR
    NAMES assimp/anim.h
    HINTS ${ASSIMP_ROOT_DIR}/include)
  set(assimp_INCLUDE_DIRS ${ASSIMP_INCLUDE_DIR})

  if(MSVC12)
    set(ASSIMP_MSVC_VERSIONS "vc120")
  elseif(MSVC14)
    set(ASSIMP_MSVC_VERSIONS "vc140;vc141")
  endif(MSVC12)

  if(MSVC12 OR MSVC14)

    foreach(ASSIMP_MSVC_VERSION ${ASSIMP_MSVC_VERSIONS})
      find_path(
        ASSIMP_LIBRARY_DIR
        NAMES assimp-${ASSIMP_MSVC_VERSION}-mt.lib
              assimp-${ASSIMP_MSVC_VERSION}-mtd.lib
        HINTS ${ASSIMP_ROOT_DIR}/lib${ASSIMP_ARCHITECTURE})

      find_library(ASSIMP_LIBRARY_RELEASE assimp-${ASSIMP_MSVC_VERSION}-mt.lib
                   PATHS ${ASSIMP_LIBRARY_DIR})
      find_library(ASSIMP_LIBRARY_DEBUG assimp-${ASSIMP_MSVC_VERSION}-mtd.lib
                   PATHS ${ASSIMP_LIBRARY_DIR})

      if(NOT ASSIMP_LIBRARY_RELEASE AND NOT ASSIMP_LIBRARY_DEBUG)
        continue()
      endif()

      if(ASSIMP_LIBRARY_DEBUG)
        set(ASSIMP_LIBRARY optimized ${ASSIMP_LIBRARY_RELEASE} debug
                           ${ASSIMP_LIBRARY_DEBUG})
      else()
        set(ASSIMP_LIBRARY optimized ${ASSIMP_LIBRARY_RELEASE})
      endif()

      set(ASSIMP_LIBRARIES ${ASSIMP_LIBRARY_RELEASE} ${ASSIMP_LIBRARY_DEBUG})

      function(ASSIMP_COPY_BINARIES TargetDirectory)
        add_custom_target(
          AssimpCopyBinaries
          COMMAND
            ${CMAKE_COMMAND} -E copy
            ${ASSIMP_ROOT_DIR}/bin${ASSIMP_ARCHITECTURE}/assimp-${ASSIMP_MSVC_VERSION}-mtd.dll
            ${TargetDirectory}/Debug/assimp-${ASSIMP_MSVC_VERSION}-mtd.dll
          COMMAND
            ${CMAKE_COMMAND} -E copy
            ${ASSIMP_ROOT_DIR}/bin${ASSIMP_ARCHITECTURE}/assimp-${ASSIMP_MSVC_VERSION}-mt.dll
            ${TargetDirectory}/Release/assimp-${ASSIMP_MSVC_VERSION}-mt.dll
          COMMENT "Copying Assimp binaries to '${TargetDirectory}'"
          VERBATIM)
      endfunction(ASSIMP_COPY_BINARIES)

      set(assimp_LIBRARIES ${ASSIMP_LIBRARY})
    endforeach()
  endif()

else(WIN32)

  find_path(
    assimp_INCLUDE_DIRS
    NAMES assimp/postprocess.h assimp/scene.h assimp/version.h assimp/config.h
          assimp/cimport.h
    PATHS /usr/local/include
    PATHS /usr/include/)

  find_library(
    assimp_LIBRARIES
    NAMES assimp
    PATHS /usr/local/lib/
    PATHS /usr/lib64/
    PATHS /usr/lib/)

  if(assimp_INCLUDE_DIRS AND assimp_LIBRARIES)
    set(assimp_FOUND TRUE)
  endif(assimp_INCLUDE_DIRS AND assimp_LIBRARIES)

  if(assimp_FOUND)
    if(NOT assimp_FIND_QUIETLY)
      message(STATUS "Found asset importer library: ${assimp_LIBRARIES}")
    endif(NOT assimp_FIND_QUIETLY)
  else(assimp_FOUND)
    if(assimp_FIND_REQUIRED)
      message(FATAL_ERROR "Could not find asset importer library")
    endif(assimp_FIND_REQUIRED)
  endif(assimp_FOUND)

endif(WIN32)
