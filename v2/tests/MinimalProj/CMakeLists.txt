add_cmake_test(NAME MinimalProj-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME MinimalProj-consumer DEPENDS MinimalProj-library BUILD_TARGET all)
