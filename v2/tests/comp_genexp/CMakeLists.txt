add_cmake_test(NAME cg-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME cg-consumer DEPENDS cg-library BUILD_TARGET all)
