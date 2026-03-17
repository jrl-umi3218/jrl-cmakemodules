add_cmake_test(NAME multitargets-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME multitargets-consumer DEPENDS multitargets-library BUILD_TARGET all)
