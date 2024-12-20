# Copyright (C) 2008-2014 LAAS-CNRS, JRL AIST-CNRS.
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.

include(CheckCXXCompilerFlag)

macro(_SETUP_PROJECT_WARNINGS)
  # -Wmissing-declarations is disabled for now as older GCC version does not
  # support it but CMake doest not check for the flag acceptance correctly.

  set(
    GNU_FLAGS
    -pedantic
    -Wno-long-long
    -Wall
    -Wextra
    -Wcast-align
    -Wcast-qual
    -Wformat
    -Wwrite-strings
    -Wconversion
  )
  if(NOT DEFINED CXX_DISABLE_WERROR)
    list(APPEND GNU_FLAGS -Werror)
  endif(NOT DEFINED CXX_DISABLE_WERROR)

  # For win32 systems, it is impossible to use Wall, especially with boost,
  # which is way too verbose The default levels (W3/W4) are enough The next
  # macro remove warnings on deprecations due to stl.
  set(
    MSVC_FLAGS
    -D_SCL_SECURE_NO_WARNINGS
    -D_CRT_SECURE_NO_WARNINGS
    -D_CRT_SECURE_NO_DEPRECATE
    # -- The following warnings are removed to highlight the output C4101 The
    # local variable is never used removed since happens frequently in
    # headers.
    /wd4101
    # C4250 'class1' : inherits 'class2::member' via dominance
    /wd4250
    # C4251 class 'type' needs to have dll-interface to be used by clients of
    # class 'type2' ~ in practice, raised by the classes that have non-dll
    # attribute (such as std::vector)
    /wd4251
    # C4275 non - DLL-interface used as base for DLL-interface
    /wd4275
    # C4355 "this" used in base member initializer list
    /wd4355
  )

  CXX_FLAGS_BY_COMPILER_FRONTEND(
    GNU ${GNU_FLAGS}
    MSVC ${MSVC_FLAGS}
    OUTPUT WARNING_CXX_FLAGS_LIST
    FILTER
  )
  string(REPLACE ";" " " WARNING_CXX_FLAGS "${WARNING_CXX_FLAGS_LIST}")

  set(CMAKE_CXX_FLAGS "${WARNING_CXX_FLAGS} ${CMAKE_CXX_FLAGS}")

  list(APPEND LOGGING_WATCHED_VARIABLES WARNING_CXX_FLAGS)
endmacro(_SETUP_PROJECT_WARNINGS)

#[=======================================================================[.rst:
.. command:: CXX_FLAGS_BY_COMPILER_FRONTEND(<GCC   [<flags1>...]>
                                            <MSVC  [<flags1>...]>
                                            OUTPUT flags
                                            <FILTER>)

Detect the compiler frontend (the command line interface) and output the
corresponding ``CXX_FLAGS``.

The following arguments allow to specify ``CXX_FLAGS`` for a compiler
frontend:

:param GNU: List of flags for GNU compiler frontend (Gcc, G++)
:param MSVC: List of flags for MSVC compiler frontend (MSVC, ClangCl)

Detected compiler frontend flags are then outputed in the ``OUTPUT``
parameter.

Optional ``FILTER`` parameter filter outputed flags with check_cxx_compiler_flag.

.. warning:: When ``FILTER`` option is activated, definition should by passed with
-D prefix to be valid compiler parameter.

Example
^^^^^^^

.. code-block:: cmake
  CXX_FLAGS_BY_COMPILER_FRONTEND(
    GNU -Wno-conversion -Wno-comment -Wno-self-assign-overloaded
    MSVC  "/bigobj"
    OUTPUT COMPLIE_OPTIONS
    FILTER)
#]=======================================================================]

function(CXX_FLAGS_BY_COMPILER_FRONTEND)
  set(options FILTER)
  set(oneValueArgs OUTPUT)
  set(multiValueArgs GNU MSVC)
  cmake_parse_arguments(
    ARGS
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  # Before CMake 3.14, the CMAKE_CXX_COMPILER_FRONTEND_VARIANT doesn't exists.
  # Before CMake 3.26, when CMAKE_CXX_COMPILER_ID is set to GNU, MSVC or
  # AppleClang, CMAKE_CXX_COMPILER_FRONTEND_VARIANT doesn't exists either
  if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT)
    if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "GNU")
      set(FLAGS ${ARGS_GNU})
    elseif(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
      set(FLAGS ${ARGS_MSVC})
    else()
      message(
        WARNING
        "Unknown compiler frontend for '${CMAKE_CXX_COMPILER_ID}' "
        "with frontend '${CMAKE_CXX_COMPILER_FRONTEND_VARIANT}'\n"
        "No flags outputed"
      )
    endif()
  else()
    if(
      CMAKE_CXX_COMPILER_ID MATCHES "Clang"
      AND CMAKE_CXX_SIMULATE_ID MATCHES "MSVC"
    )
      set(FLAGS ${ARGS_MSVC})
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
      set(FLAGS ${ARGS_MSVC})
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
      set(FLAGS ${ARGS_GNU})
    else()
      message(
        WARNING
        "Unknown compiler frontend for '${CMAKE_CXX_COMPILER_ID}' "
        "with simulated ID '${CMAKE_CXX_SIMULATED_ID}'\n"
        "No flags outputed"
      )
    endif()
  endif()

  if(ARGS_FILTER)
    foreach(FLAG ${FLAGS})
      check_cxx_compiler_flag(${FLAG} res_${FLAG})
      if(${res_${FLAG}})
        list(APPEND FILTERED_FLAGS ${FLAG})
      endif()
    endforeach()
  else()
    set(FILTERED_FLAGS ${FLAGS})
  endif()

  set(${ARGS_OUTPUT} ${FILTERED_FLAGS} PARENT_SCOPE)
endfunction()
