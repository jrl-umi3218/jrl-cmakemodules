add_cmake_test(NAME mcg-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME mcg-consumer DEPENDS mcg-library BUILD_TARGET all)
