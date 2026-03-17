#include "multitargets-library/StringUtils.hpp"

#include <algorithm>

namespace multitargets_library {

std::string StringUtils::brackets(const std::string& str) {
  return "[" + str + "]";
}

std::string StringUtils::reverse(const std::string& str) {
  std::string result = str;
  std::reverse(result.begin(), result.end());
  return result;
}

}  // namespace multitargets_library
