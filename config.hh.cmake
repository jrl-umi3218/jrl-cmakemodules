// Copyright (C) 2008, 2009 by Thomas Moulard, CNRS.
//
// This file is part of the hpp-util.
//
// This software is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the
// implied warranties of fitness for a particular purpose.
//
// See the COPYING file for more information.

#ifndef ${PACKAGE_CPPNAME}_CONFIG_HH
# define ${PACKAGE_CPPNAME}_CONFIG_HH

// Package version (header).
# define ${PACKAGE_CPPNAME}_VERSION "${PROJECT_VERSION}"

# ifdef ${PACKAGE_CPPNAME}_STATIC
// If one is using the library statically, get rid of
// extra information.
#  define ${PACKAGE_CPPNAME}_DLLAPI
#  define ${PACKAGE_CPPNAME}_LOCAL
# else
// Depending on whether one is building or using the
// library define DLLAPI to import or export.
#  ifdef BUILDING_${PACKAGE_CPPNAME}
#   define ${PACKAGE_CPPNAME}_DLLAPI HPP_DLLEXPORT
#  else
#   define ${PACKAGE_CPPNAME}_DLLAPI HPP_DLLIMPORT
#  endif // BUILDING_${PACKAGE_CPPNAME}
#  define ${PACKAGE_CPPNAME}_LOCAL HPP_DLLLOCAL
# endif // ${PACKAGE_CPPNAME}_STATIC
#endif //! ${PACKAGE_CPPNAME}_CONFIG_HH
