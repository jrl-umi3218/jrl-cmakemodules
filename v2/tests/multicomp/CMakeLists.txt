add_cmake_test(NAME multicomp-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME multicomp-consumer DEPENDS multicomp-library BUILD_TARGET all)
add_cmake_test(NAME multicomp-consumer-all DEPENDS multicomp-library BUILD_TARGET all)
