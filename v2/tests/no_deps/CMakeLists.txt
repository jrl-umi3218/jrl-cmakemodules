add_cmake_test(NAME no_deps-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME no_deps-consumer DEPENDS no_deps-library BUILD_TARGET all)
