#include <cg-library/Base/a.hpp>
#include <cg-library/Extra/c.hpp>

#if !defined(CG_HAS_EXTRA)
#error "CG_HAS_EXTRA should be defined when CG_BUILD_WITH_EXTRA is ON"
#endif

auto main() -> int {
  constexpr auto a = cg_library::a<int>();
  constexpr auto c = cg_library::c<int>();

  static_assert(a == 1, "a() should return 1");
  static_assert(c == 2, "c() should return 2");
  return 0;
}
