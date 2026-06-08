add_cmake_test(NAME mc-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME mc-consumer DEPENDS mc-library BUILD_TARGET all)
add_cmake_test(NAME mc-consumer-all DEPENDS mc-library BUILD_TARGET all)
