// Copyright (C) 2008, 2009 by Thomas Moulard, CNRS.
//
// This file is part of the jrl-cmakemodules.
//
// This software is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the
// implied warranties of fitness for a particular purpose.
//
// See the COPYING file for more information.

#ifndef @PACKAGE_CPPNAME@_CONFIG_HH
# define @PACKAGE_CPPNAME@_CONFIG_HH

// Package version (header).
# define @PACKAGE_CPPNAME@_VERSION "@PROJECT_VERSION@"

// Handle portable symbol export.
// Defining manually which symbol should be exported is required
// under Windows whether MinGW or MSVC is used.
//
// The headers then have to be able to work in two different modes:
// - dllexport when one is building the library,
// - dllimport for clients using the library.
//
// On Linux, set the visibility accordingly. If C++ symbol visibility
// is handled by the compiler, see: http://gcc.gnu.org/wiki/Visibility
# if defined _WIN32 || defined __CYGWIN__
// On Microsoft Windows, use dllimport and dllexport to tag symbols.
#  define @PACKAGE_CPPNAME@_DLLIMPORT __declspec(dllimport)
#  define @PACKAGE_CPPNAME@_DLLEXPORT __declspec(dllexport)
#  define @PACKAGE_CPPNAME@_DLLLOCAL
# else
// On Linux, for GCC >= 4, tag symbols using GCC extension.
#  if __GNUC__ >= 4
#   define @PACKAGE_CPPNAME@_DLLIMPORT __attribute__ ((visibility("default")))
#   define @PACKAGE_CPPNAME@_DLLEXPORT __attribute__ ((visibility("default")))
#   define @PACKAGE_CPPNAME@_DLLLOCAL  __attribute__ ((visibility("hidden")))
#  else
// Otherwise (GCC < 4 or another compiler is used), export everything.
#   define @PACKAGE_CPPNAME@_DLLIMPORT
#   define @PACKAGE_CPPNAME@_DLLEXPORT
#   define @PACKAGE_CPPNAME@_DLLLOCAL
#  endif // __GNUC__ >= 4
# endif // defined _WIN32 || defined __CYGWIN__

# ifdef @PACKAGE_CPPNAME@_STATIC
// If one is using the library statically, get rid of
// extra information.
#  define @PACKAGE_CPPNAME@_DLLAPI
#  define @PACKAGE_CPPNAME@_LOCAL
# else
// Depending on whether one is building or using the
// library define DLLAPI to import or export.
#  ifdef BUILDING_@PACKAGE_CPPNAME@
#   define @PACKAGE_CPPNAME@_DLLAPI @PACKAGE_CPPNAME@_DLLEXPORT
#  else
#   define @PACKAGE_CPPNAME@_DLLAPI @PACKAGE_CPPNAME@_DLLIMPORT
#  endif // BUILDING_@PACKAGE_CPPNAME@
#  define @PACKAGE_CPPNAME@_LOCAL @PACKAGE_CPPNAME@_DLLLOCAL
# endif // @PACKAGE_CPPNAME@_STATIC
#endif //! @PACKAGE_CPPNAME@_CONFIG_HH
