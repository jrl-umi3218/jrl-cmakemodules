# .rst: .. command:: JULIA_CHECK_PACKAGE (PKG_NAME)
#
# Test if package PKG_NAME is installed in Julia.
#
macro(JULIA_CHECK_PACKAGE PKG_NAME)
  set(text
      "try\n@eval import ${PKG_NAME}\nprintln(\"1\")\ncatch\nprintln(\"0\")\nend"
  )
  file(WRITE ${PROJECT_SOURCE_DIR}/_tmp/test_julia_package.jl ${text})
  execute_process(
    COMMAND ${Julia_EXECUTABLE} ${PROJECT_SOURCE_DIR}/_tmp/test_julia_package.jl
    OUTPUT_VARIABLE found_pkg)
  if(found_pkg)
    set(${PKG_NAME}_found 1)
  else()
    set(${PKG_NAME}_found 0)
  endif()
  file(REMOVE_RECURSE ${PROJECT_SOURCE_DIR}/_tmp/)
endmacro(JULIA_CHECK_PACKAGE PKG_NAME)
