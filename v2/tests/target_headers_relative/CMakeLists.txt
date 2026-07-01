add_cmake_test(NAME thr-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME thr-consumer DEPENDS thr-library BUILD_TARGET all)
