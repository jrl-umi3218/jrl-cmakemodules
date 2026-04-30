jrl_test_case(
  NAME "_jrl_top_dir returns existing directory"
  CODE [[
    _jrl_top_dir(top_dir)
    if(NOT IS_DIRECTORY "${top_dir}")
      message(FATAL_ERROR "_jrl_top_dir returned non-existing directory: '${top_dir}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_jrl_top_dir contains modules/ subdirectory"
  CODE [[
    _jrl_top_dir(top_dir)
    if(NOT IS_DIRECTORY "${top_dir}/modules")
      message(FATAL_ERROR "Expected modules/ inside top_dir '${top_dir}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_jrl_templates_dir returns existing directory"
  CODE [[
    _jrl_templates_dir(templates_dir)
    if(NOT IS_DIRECTORY "${templates_dir}")
      message(FATAL_ERROR "_jrl_templates_dir returned non-existing directory: '${templates_dir}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_jrl_templates_dir is inside top_dir"
  CODE [[
    _jrl_top_dir(top_dir)
    _jrl_templates_dir(templates_dir)
    string(FIND "${templates_dir}" "${top_dir}" pos)
    if(NOT pos EQUAL 0)
      message(FATAL_ERROR "templates_dir '${templates_dir}' is not inside top_dir '${top_dir}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_jrl_docs_dir returns existing directory"
  CODE [[
    _jrl_docs_dir(docs_dir)
    if(NOT IS_DIRECTORY "${docs_dir}")
      message(FATAL_ERROR "_jrl_docs_dir returned non-existing directory: '${docs_dir}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_jrl_external_modules_dir returns existing directory"
  CODE [[
    _jrl_external_modules_dir(ext_dir)
    if(NOT IS_DIRECTORY "${ext_dir}")
      message(FATAL_ERROR "_jrl_external_modules_dir returned non-existing directory: '${ext_dir}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_jrl_find_modules_dir returns existing directory"
  CODE [[
    _jrl_find_modules_dir(find_dir)
    if(NOT IS_DIRECTORY "${find_dir}")
      message(FATAL_ERROR "_jrl_find_modules_dir returned non-existing directory: '${find_dir}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_jrl_find_modules_dir contains at least one FindXxx.cmake file"
  CODE [[
    _jrl_find_modules_dir(find_dir)
    file(GLOB find_modules "${find_dir}/Find*.cmake")
    list(LENGTH find_modules count)
    if(count EQUAL 0)
      message(FATAL_ERROR "find_modules_dir '${find_dir}' contains no Find*.cmake files")
    endif()
  ]]
)
