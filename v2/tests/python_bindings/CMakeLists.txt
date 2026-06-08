add_cmake_test(NAME pb-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME pb-consumer DEPENDS pb-library BUILD_TARGET all)
