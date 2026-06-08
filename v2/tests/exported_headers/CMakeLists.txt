add_cmake_test(NAME eh-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME eh-consumer DEPENDS eh-library BUILD_TARGET all)
