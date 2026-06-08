add_cmake_test(NAME nd-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME nd-consumer DEPENDS nd-library BUILD_TARGET all)
