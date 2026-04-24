#include <boost/python.hpp>
#include <boost/python/numpy.hpp>
#include <pb/Math.hpp>
#include <pb/StringUtils.hpp>

BOOST_PYTHON_MODULE(pb_pywrap_bp) {
  boost::python::class_<pb::Math>("Math")
      .def("add", &pb::Math::add)
      .def("multiply", &pb::Math::multiply);

  boost::python::class_<pb::StringUtils>("StringUtils", boost::python::init<>())
      .def("brackets", &pb::StringUtils::brackets)
      .def("reverse", &pb::StringUtils::reverse);
}
