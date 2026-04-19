#include <mcg-library/Base/a.hpp>
#include <mcg-library/Extra/c.hpp>

#if !defined(MCG_HAS_EXTRA)
#error "MCG_HAS_EXTRA should be defined when MCG_BUILD_WITH_EXTRA is ON"
#endif

auto main() -> int {
  constexpr auto a = mcg_library::a<int>();
  constexpr auto c = mcg_library::c<int>();

  static_assert(a == 1, "a() should return 1");
  static_assert(c == 2, "c() should return 2");
  return 0;
}
