#pragma once

#include <string>

#include "pb/config.hpp"

namespace pb {

class PB_DLLAPI StringUtils {
 public:
  std::string brackets(const std::string& str);
  std::string reverse(const std::string& str);
};

}  // namespace pb
