// Copyright (C) 2008-2014 LAAS-CNRS, JRL AIST-CNRS.
//
// This file is part of jrl-cmakemodules.
// jrl-mathtools is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// jrl-mathtools is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// You should have received a copy of the GNU Lesser General Public License
// along with jrl-mathtools.  If not, see <http://www.gnu.org/licenses/>.

#include <Python.h>

/**
   \brief List of python functions
*/
static PyMethodDef functions[] = {
  {NULL, NULL, 0, NULL}        /* Sentinel */
};

#if PY_MAJOR_VERSION >= 3
static struct PyModuleDef module = {
    PyModuleDef_HEAD_INIT,
    "wrap",
    NULL,
    0,
    functions,
    NULL,
    NULL,
    NULL,
    NULL};
#endif

#ifdef __cplusplus
extern "C" {
#endif

#if PY_MAJOR_VERSION >= 3
PyMODINIT_FUNC PyInit_wrap(void)
#else
void initwrap(void)
#endif
{
    PyObject *m;

#if PY_MAJOR_VERSION >= 3
    m = PyModule_Create(&module);
#else
    m = Py_InitModule("wrap", functions);
#endif
    if (m == NULL)
#if PY_MAJOR_VERSION >= 3
        return NULL;
#else
        return;
#endif

#if PY_MAJOR_VERSION >= 3
    return m;
#endif
}


#ifdef __cplusplus
}  // extern "C"
#endif
