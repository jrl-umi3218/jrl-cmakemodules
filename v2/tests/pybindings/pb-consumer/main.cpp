#include <pb/Math.hpp>

auto main() -> int {
  pb::Math math;
  if (math.add(2, 3) != 5) {
    return 1;
  }
  if (math.multiply(3, 4) != 12) {
    return 1;
  }
  return 0;
}
