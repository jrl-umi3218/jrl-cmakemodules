#include <multitargets-library/Math.hpp>
#include <multitargets-library/StringUtils.hpp>

auto main() -> int {
  multitargets_library::Math math;
  multitargets_library::StringUtils string_utils;

  const auto sum = math.add(3, 5);
  const auto product = math.multiply(4, 6);

  const auto bracketed = string_utils.brackets("Hello");
  const auto reversed = string_utils.reverse("Hello");

  return 0;
}
