add_cmake_test(NAME mt-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME mt-consumer DEPENDS mt-library BUILD_TARGET all)
