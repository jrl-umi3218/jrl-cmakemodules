add_cmake_test(NAME MinP-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME MinP-consumer DEPENDS MinP-library BUILD_TARGET all)
