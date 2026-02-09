#include <boost/python.hpp>
#include <boost/python/numpy.hpp>
#include <test_project/Math.hpp>
#include <test_project/StringUtils.hpp>

BOOST_PYTHON_MODULE(test_project_pywrap_bp) {
  boost::python::class_<test_project::Math>("Math")
      .def("add", &test_project::Math::add)
      .def("multiply", &test_project::Math::multiply);

  boost::python::class_<test_project::StringUtils>("StringUtils",
                                                   boost::python::init<>())
      .def("brackets", &test_project::StringUtils::brackets)
      .def("reverse", &test_project::StringUtils::reverse);
}
