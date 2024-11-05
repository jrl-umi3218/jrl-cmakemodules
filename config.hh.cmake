/*
 * This file has been automatically generated by the jrl-cmakemodules.
 * Please see https://github.com/jrl-umi3218/jrl-cmakemodules/blob/master/config.hh.cmake for details.
*/

#ifndef @LIBRARY_NAME@_CONFIG_HH
# define @LIBRARY_NAME@_CONFIG_HH

// Package version (header).
# define @LIBRARY_NAME@_VERSION_UNKNOWN_TAG 0 // Used to mention that the current version is unknown.
# define @LIBRARY_NAME@_VERSION "@PROJECT_VERSION@"
# define @LIBRARY_NAME@_MAJOR_VERSION @PROJECT_VERSION_MAJOR_CONFIG@
# define @LIBRARY_NAME@_MINOR_VERSION @PROJECT_VERSION_MINOR_CONFIG@
# define @LIBRARY_NAME@_PATCH_VERSION @PROJECT_VERSION_PATCH_CONFIG@

#define @LIBRARY_NAME@_VERSION_AT_LEAST(major, minor, patch) (@LIBRARY_NAME@_MAJOR_VERSION>major || (@LIBRARY_NAME@_MAJOR_VERSION>=major && \
                                                             (@LIBRARY_NAME@_MINOR_VERSION>minor || (@LIBRARY_NAME@_MINOR_VERSION>=minor && \
                                                                                                     @LIBRARY_NAME@_PATCH_VERSION>=patch))))

#define @LIBRARY_NAME@_VERSION_AT_MOST(major, minor, patch) (@LIBRARY_NAME@_MAJOR_VERSION<major || (@LIBRARY_NAME@_MAJOR_VERSION<=major && \
                                                            (@LIBRARY_NAME@_MINOR_VERSION<minor || (@LIBRARY_NAME@_MINOR_VERSION<=minor && \
                                                                                                     @LIBRARY_NAME@_PATCH_VERSION<=patch))))

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
//
// Explicit template instantiation on Windows need to add
// dllexport on the definition and dllimport on the declaration.
// The XXX_EXPLICIT_INSTANTIATION_DECLARATION_DLLAPI macro
// should be set on the declaration while
// the XXX_EXPLICIT_INSTANTIATION_DEFINITION_DLLAPI macro
// should be set on the definition.
# if defined _WIN32 || defined __CYGWIN__
// On Microsoft Windows, use dllimport and dllexport to tag symbols.
#  define @LIBRARY_NAME@_DLLIMPORT __declspec(dllimport)
#  define @LIBRARY_NAME@_DLLEXPORT __declspec(dllexport)
#  define @LIBRARY_NAME@_DLLLOCAL
#  define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DECLARATION_DLLIMPORT __declspec(dllimport)
#  define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DECLARATION_DLLEXPORT
#  define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DEFINITION_DLLIMPORT __declspec(dllimport)
#  define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DEFINITION_DLLEXPORT __declspec(dllexport)
# else
// On Linux, for GCC >= 4, tag symbols using GCC extension.
#  if __GNUC__ >= 4
// Use C++11 attribute if avaiable.
// This avoid issue when mixing old and C++11 attributes with GCC < 13
#   if defined(__cplusplus) && (__cplusplus >= 201103L)
#    define @LIBRARY_NAME@_DLLIMPORT [[gnu::visibility("default")]]
#    define @LIBRARY_NAME@_DLLEXPORT [[gnu::visibility("default")]]
#    define @LIBRARY_NAME@_DLLLOCAL  [[gnu::visibility("hidden")]]
// gnu::visibility is not working with clang and explicit template instantiation
#    define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DECLARATION_DLLIMPORT __attribute__ ((visibility("default")))
#    define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DECLARATION_DLLEXPORT __attribute__ ((visibility("default")))
#    define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DEFINITION_DLLIMPORT
#    define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DEFINITION_DLLEXPORT
#   else
#    define @LIBRARY_NAME@_DLLIMPORT __attribute__ ((visibility("default")))
#    define @LIBRARY_NAME@_DLLEXPORT __attribute__ ((visibility("default")))
#    define @LIBRARY_NAME@_DLLLOCAL  __attribute__ ((visibility("hidden")))
#    define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DECLARATION_DLLIMPORT __attribute__ ((visibility("default")))
#    define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DECLARATION_DLLEXPORT __attribute__ ((visibility("default")))
#    define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DEFINITION_DLLIMPORT
#    define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DEFINITION_DLLEXPORT
#   endif
#  else
// Otherwise (GCC < 4 or another compiler is used), export everything.
#   define @LIBRARY_NAME@_DLLIMPORT
#   define @LIBRARY_NAME@_DLLEXPORT
#   define @LIBRARY_NAME@_DLLLOCAL
#   define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DECLARATION_DLLIMPORT
#   define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DECLARATION_DLLEXPORT
#   define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DEFINITION_DLLIMPORT
#   define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DEFINITION_DLLEXPORT
#  endif // __GNUC__ >= 4
# endif // defined _WIN32 || defined __CYGWIN__

# ifdef @LIBRARY_NAME@_STATIC
// If one is using the library statically, get rid of
// extra information and use standard explicit template
// instantiation keyword.
#  define @LIBRARY_NAME@_DLLAPI
#  define @LIBRARY_NAME@_LOCAL
#  define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DECLARATION extern template
# else
// Depending on whether one is building or using the
// library define DLLAPI to import or export and
// define the right explicit template instantiation keyword.
#  ifdef @EXPORT_SYMBOL@
#   define @LIBRARY_NAME@_DLLAPI @LIBRARY_NAME@_DLLEXPORT
#   define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DECLARATION_DLLAPI @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DECLARATION_DLLEXPORT
#   define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DEFINITION_DLLAPI @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DEFINITION_DLLEXPORT
#  else
#   define @LIBRARY_NAME@_DLLAPI @LIBRARY_NAME@_DLLIMPORT
#   define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DECLARATION_DLLAPI @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DECLARATION_DLLIMPORT
#   define @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DEFINITION_DLLAPI @LIBRARY_NAME@_EXPLICIT_INSTANTIATION_DEFINITION_DLLIMPORT
#  endif // @LIBRARY_NAME@_EXPORTS
#  define @LIBRARY_NAME@_LOCAL @LIBRARY_NAME@_DLLLOCAL
# endif // @LIBRARY_NAME@_STATIC
#endif //! @LIBRARY_NAME@_CONFIG_HH
