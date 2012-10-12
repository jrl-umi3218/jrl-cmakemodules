cmake_minimum_required(VERSION 2.8)
project(jrl-cmake NONE)
if(UNIX)
  set(_install_dest
    ${CMAKE_INSTALL_PREFIX}/share/cmake
  )
else()
  # No need to try /usr/local/share/
  # on windows:
  set(_install_dest
    ${CMAKE_ROOT}/Modules
  )
endif()

# list of files to install: all executable files
# Hint: keep this list up-to-date using
# git ls-tree -r HEAD | grep "^100755" | cut -f 2
set(_programs
bootstrap
compile.py
git-archive-all.sh
github/update-doxygen-doc.sh
)

# list of files to install: all but CMakeLists.txt and executable ones
# we cannot install the whole directory or a glob because that would install
# the build directory too if it happens to be inside the source directory.
# Hint: keep this list up-to-date using
# git ls-tree -r HEAD | grep "^100644" | cut -f 2 | grep -v CMakeLists.txt
set(_files
FindOpenRTM.cmake
README.md
base.cmake
boost.cmake
cmake_uninstall.cmake.in
compiler.cmake
config.h.cmake
config.hh.cmake
cpack.cmake
createshexe.cmake
debian.cmake
deprecated.hh.cmake
dist.cmake
distcheck.cmake
doxygen.cmake
doxygen/Doxyfile.in
doxygen/doxygen.css
doxygen/footer.html
doxygen/header.html
doxygen/header.tex
doxygen/style.rtf
doxygen/style.tex
doxygen/tabs.css
dynamic_graph/python-module-py.cc
dynamic_graph/submodule/__init__.py.cmake
eigen.cmake
header.cmake
idl.cmake
idlrtc.cmake
image/visp.cmake
install-data.cmake
jrl-cmake-config.cmake
kineo.cmake
lapack.cmake
logging.cmake
man.cmake
openhrpcontroller.cmake
openrtm.cmake
pkg-config.cmake
pkg-config.pc.cmake
portability.cmake
pthread.cmake
python.cmake
release.cmake
ros.cmake
shared-library.cmake
sphinx.cmake
sphinx/conf.py.in
sphinx/index.rst.in
test.cmake
uninstall.cmake
version.cmake
warning.hh.cmake
)
foreach(_file ${_programs})
  get_filename_component(_subdir ${_file} PATH)
  install(
    PROGRAMS  ${_file}
    DESTINATION "${_install_dest}/${PROJECT_NAME}/${_subdir}")
endforeach()
foreach(_file ${_files})
  get_filename_component(_subdir ${_file} PATH)
  install(
  FILES ${_file}
  DESTINATION "${_install_dest}/${PROJECT_NAME}/${_subdir}")
endforeach()
