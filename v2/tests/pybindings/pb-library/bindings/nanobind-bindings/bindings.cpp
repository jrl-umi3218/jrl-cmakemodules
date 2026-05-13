#include <nanobind/nanobind.h>
#include <nanobind/stl/string.h>

#include <pb/Math.hpp>
#include <pb/StringUtils.hpp>

namespace nb = nanobind;

NB_MODULE(pb_pywrap, m) {
  nb::class_<pb::Math>(m, "Math")
      .def("add", &pb::Math::add)
      .def("multiply", &pb::Math::multiply);

  nb::class_<pb::StringUtils>(m, "StringUtils")
      .def(nb::init())
      .def("brackets", &pb::StringUtils::brackets)
      .def("reverse", &pb::StringUtils::reverse);
}
