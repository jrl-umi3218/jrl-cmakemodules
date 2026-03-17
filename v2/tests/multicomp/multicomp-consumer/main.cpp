#include <multicomp-library/BaseMath.hpp>
#include <multicomp-library/ExtraFormatter.hpp>
#include <multicomp-library/ExtraUtils.hpp>

auto main() -> int {
  multicomp::BaseMath math;
  multicomp::ExtraUtils utils;
  multicomp::ExtraFormatter formatter;

  const auto sum = math.add(3, 5);
  const auto hi = utils.hi();
  const auto brackets = formatter.brackets("hello");

  return 0;
}
