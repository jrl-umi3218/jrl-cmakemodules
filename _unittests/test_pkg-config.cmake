include(cmake/pkg-config.cmake)

cmake_policy(SET CMP0054 NEW)
# cmake -P
macro(EXPECT_STREQUAL _lhs _rhs)
  if(NOT "${_lhs}" STREQUAL ${_rhs})
    message(SEND_ERROR "EXPECT_STREQUAL failed: \"${_lhs}\" != \"${_rhs}\"")
  endif()
endmacro()

macro(UNSET_TEST_VARS)
  unset(PKG_LIB_NAME)
  unset(PKG_PREFIX)
  unset(PKG_CONFIG_STRING_NOSPACE)
endmacro()

unset_test_vars()
_parse_pkg_config_string("my-package > 0.4" PKG_LIB_NAME PKG_PREFIX
                         PKG_CONFIG_STRING_NOSPACE)
expect_strequal("my-package" "${PKG_LIB_NAME}")
expect_strequal("MY_PACKAGE" "${PKG_PREFIX}")
expect_strequal("my-package>0.4" "${PKG_CONFIG_STRING_NOSPACE}")

unset_test_vars()
_parse_pkg_config_string("my-package >= 0.4" PKG_LIB_NAME PKG_PREFIX
                         PKG_CONFIG_STRING_NOSPACE)
expect_strequal("my-package" "${PKG_LIB_NAME}")
expect_strequal("MY_PACKAGE" "${PKG_PREFIX}")
expect_strequal("my-package>=0.4" "${PKG_CONFIG_STRING_NOSPACE}")

unset_test_vars()
_parse_pkg_config_string("my-package" PKG_LIB_NAME PKG_PREFIX
                         PKG_CONFIG_STRING_NOSPACE)
expect_strequal("my-package" "${PKG_LIB_NAME}")
expect_strequal("MY_PACKAGE" "${PKG_PREFIX}")
expect_strequal("my-package" "${PKG_CONFIG_STRING_NOSPACE}")

# it the input does not have spaces around the operator, the operator is
# considered as being part of the library name. This is expected and consistent
# with pkg-config's behavior.
unset_test_vars()
_parse_pkg_config_string("my-package>=0.4" PKG_LIB_NAME PKG_PREFIX
                         PKG_CONFIG_STRING_NOSPACE)
expect_strequal("my-package>=0.4" "${PKG_LIB_NAME}")
expect_strequal("MY_PACKAGE__0_4" "${PKG_PREFIX}")
expect_strequal("my-package>=0.4" "${PKG_CONFIG_STRING_NOSPACE}")
