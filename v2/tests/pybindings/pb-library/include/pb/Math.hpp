#pragma once

#include <pb/config.hpp>

#ifndef PB_DLLAPI
#pragma error "PB_DLLAPI must be defined before including this header"
#endif

namespace pb {

class PB_DLLAPI Math {
 public:
  int add(int a, int b);
  int multiply(int a, int b);
};

}  // namespace pb
