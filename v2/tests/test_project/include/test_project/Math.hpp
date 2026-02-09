#pragma once

#include <test_project/config.hpp>

#ifndef TEST_PROJECT_DLLAPI
#pragma error "TEST_PROJECT_DLLAPI must be defined before including this header"
#endif

namespace test_project {

class TEST_PROJECT_DLLAPI Math {
 public:
  int add(int a, int b);
  int multiply(int a, int b);
};

}  // namespace test_project
