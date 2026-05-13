#include "pb/StringUtils.hpp"

#include <algorithm>

namespace pb {

std::string StringUtils::brackets(const std::string& str) {
  return "[" + str + "]";
}

std::string StringUtils::reverse(const std::string& str) {
  std::string result = str;
  std::reverse(result.begin(), result.end());
  return result;
}

}  // namespace pb
