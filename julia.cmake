# .rst: .. command:: JULIA_CHECK_PACKAGE (PKG_NAME)
#
# Test if package PKG_NAME is installed in Julia. This will define
# Julia_${PKG_NAME}_found.
#
# :param PKG_NAME: the package to check :param :return Julia_${PKG_NAME}_found
# :return:
macro(JULIA_CHECK_PACKAGE PKG_NAME)
  set(file_content
      "try\n@eval import ${PKG_NAME}\nprintln(1)\ncatch\nprintln(0)\nend")
  file(WRITE ${PROJECT_SOURCE_DIR}/_tmp_cmake_julia/test_julia_package.jl
       ${file_content})
  execute_process(
    COMMAND ${Julia_EXECUTABLE}
            ${PROJECT_SOURCE_DIR}/_tmp_cmake_julia/test_julia_package.jl
    OUTPUT_VARIABLE Julia_${PKG_NAME}_found)
  file(REMOVE_RECURSE ${PROJECT_SOURCE_DIR}/_tmp_cmake_julia/)
endmacro(JULIA_CHECK_PACKAGE PKG_NAME)
