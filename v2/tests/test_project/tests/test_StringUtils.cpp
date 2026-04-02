#include <catch2/catch_test_macros.hpp>
#include <test_project/StringUtils.hpp>

TEST_CASE("StringUtils::brackets adds brackets", "[StringUtils]") {
  test_project::StringUtils utils;
  REQUIRE(utils.brackets("text") == "[text]");
  REQUIRE(utils.brackets("") == "[]");
}

TEST_CASE("StringUtils::reverse reverses string", "[StringUtils]") {
  test_project::StringUtils utils;
  REQUIRE(utils.reverse("abc") == "cba");
  REQUIRE(utils.reverse("") == "");
}
