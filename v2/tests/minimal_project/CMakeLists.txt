add_cmake_test(NAME mp-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME mp-consumer DEPENDS mp-library BUILD_TARGET all)
