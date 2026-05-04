#include <catch2/catch_test_macros.hpp>
#include <pb/StringUtils.hpp>

TEST_CASE("StringUtils::brackets adds brackets", "[StringUtils]") {
  pb::StringUtils utils;
  REQUIRE(utils.brackets("text") == "[text]");
  REQUIRE(utils.brackets("") == "[]");
}

TEST_CASE("StringUtils::reverse reverses string", "[StringUtils]") {
  pb::StringUtils utils;
  REQUIRE(utils.reverse("abc") == "cba");
  REQUIRE(utils.reverse("") == "");
}
