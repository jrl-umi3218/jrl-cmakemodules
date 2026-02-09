#pragma once

#include <string>

#include "test_project/config.hpp"

namespace test_project {

class TEST_PROJECT_DLLAPI StringUtils {
 public:
  std::string brackets(const std::string& str);
  std::string reverse(const std::string& str);
};

}  // namespace test_project
