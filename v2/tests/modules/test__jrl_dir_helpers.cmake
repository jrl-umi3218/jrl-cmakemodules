jrl_test_case(
  NAME "_JRL_TOP_DIR is an existing directory"
  CODE [[
    if(NOT IS_DIRECTORY "${_JRL_TOP_DIR}")
      message(FATAL_ERROR "_JRL_TOP_DIR is not an existing directory: '${_JRL_TOP_DIR}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_JRL_TOP_DIR contains modules/ subdirectory"
  CODE [[
    if(NOT IS_DIRECTORY "${_JRL_TOP_DIR}/modules")
      message(FATAL_ERROR "Expected modules/ inside _JRL_TOP_DIR '${_JRL_TOP_DIR}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_JRL_MODULES_DIR is an existing directory"
  CODE [[
    if(NOT IS_DIRECTORY "${_JRL_MODULES_DIR}")
      message(FATAL_ERROR "_JRL_MODULES_DIR is not an existing directory: '${_JRL_MODULES_DIR}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_JRL_MODULES_DIR is inside _JRL_TOP_DIR"
  CODE [[
    string(FIND "${_JRL_MODULES_DIR}" "${_JRL_TOP_DIR}" pos)
    if(NOT pos EQUAL 0)
      message(FATAL_ERROR "_JRL_MODULES_DIR '${_JRL_MODULES_DIR}' is not inside _JRL_TOP_DIR '${_JRL_TOP_DIR}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_JRL_TEMPLATES_DIR is an existing directory"
  CODE [[
    if(NOT IS_DIRECTORY "${_JRL_TEMPLATES_DIR}")
      message(FATAL_ERROR "_JRL_TEMPLATES_DIR is not an existing directory: '${_JRL_TEMPLATES_DIR}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_JRL_TEMPLATES_DIR is inside _JRL_TOP_DIR"
  CODE [[
    string(FIND "${_JRL_TEMPLATES_DIR}" "${_JRL_TOP_DIR}" pos)
    if(NOT pos EQUAL 0)
      message(FATAL_ERROR "_JRL_TEMPLATES_DIR '${_JRL_TEMPLATES_DIR}' is not inside _JRL_TOP_DIR '${_JRL_TOP_DIR}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_JRL_DOCS_DIR is an existing directory"
  CODE [[
    if(NOT IS_DIRECTORY "${_JRL_DOCS_DIR}")
      message(FATAL_ERROR "_JRL_DOCS_DIR is not an existing directory: '${_JRL_DOCS_DIR}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_JRL_EXTERNAL_MODULES_DIR is an existing directory"
  CODE [[
    if(NOT IS_DIRECTORY "${_JRL_EXTERNAL_MODULES_DIR}")
      message(FATAL_ERROR "_JRL_EXTERNAL_MODULES_DIR is not an existing directory: '${_JRL_EXTERNAL_MODULES_DIR}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_JRL_FIND_MODULES_DIR is an existing directory"
  CODE [[
    if(NOT IS_DIRECTORY "${_JRL_FIND_MODULES_DIR}")
      message(FATAL_ERROR "_JRL_FIND_MODULES_DIR is not an existing directory: '${_JRL_FIND_MODULES_DIR}'")
    endif()
  ]]
)

jrl_test_case(
  NAME "_JRL_FIND_MODULES_DIR contains at least one FindXxx.cmake file"
  CODE [[
    file(GLOB find_modules "${_JRL_FIND_MODULES_DIR}/Find*.cmake")
    list(LENGTH find_modules count)
    if(count EQUAL 0)
      message(FATAL_ERROR "_JRL_FIND_MODULES_DIR '${_JRL_FIND_MODULES_DIR}' contains no Find*.cmake files")
    endif()
  ]]
)
