#include <mc-library/BaseMath.hpp>
#include <mc-library/ExtraFormatter.hpp>
#include <mc-library/ExtraUtils.hpp>

auto main() -> int {
  multicomp::BaseMath math;
  multicomp::ExtraUtils utils;
  multicomp::ExtraFormatter formatter;

  const auto sum = math.add(3, 5);
  const auto hi = utils.hi();
  const auto brackets = formatter.brackets("hello");

  return 0;
}
