add_cmake_test(NAME ExpHdr-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME ExpHdr-consumer DEPENDS ExpHdr-library BUILD_TARGET all)
