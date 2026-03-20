#include <nanobind/nanobind.h>
#include <nanobind/stl/string.h>

#include <test_project/Math.hpp>
#include <test_project/StringUtils.hpp>

namespace nb = nanobind;

NB_MODULE(test_project_pywrap, m) {
  nb::class_<test_project::Math>(m, "Math")
      .def("add", &test_project::Math::add)
      .def("multiply", &test_project::Math::multiply);

  nb::class_<test_project::StringUtils>(m, "StringUtils")
      .def(nb::init())
      .def("brackets", &test_project::StringUtils::brackets)
      .def("reverse", &test_project::StringUtils::reverse);
}
