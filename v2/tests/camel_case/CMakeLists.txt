add_cmake_test(NAME CamelCase-library DEPENDS jrl-cmakemodules)
add_cmake_test(NAME CamelCase-consumer DEPENDS CamelCase-library BUILD_TARGET all)
