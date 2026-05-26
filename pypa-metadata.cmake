# .rst: .. ifmode:: user
#
# Generate PEP 643 ${PYTHON_SITELIB}/${PROJECT_NAME}-${PROJECT_VERSION}.dist-info/METADATA
# from PEP 621 pyproject.toml
macro(GENERATE_PYPROJECT_METADATA)
  message(STATUS "Generate PEP 643 metadata from PEP 621 pyproject.toml")

  execute_process(
    COMMAND
      "${PYTHON_EXECUTABLE}" "${PROJECT_JRL_CMAKE_MODULE_DIR}/pypa-metadata.py"
      "${PROJECT_SOURCE_DIR}/pyproject.toml"
      "${PROJECT_BINARY_DIR}/pypa-metadata"
    RESULT_VARIABLE _PYPROJECT_METADATA_RESULT
    ERROR_VARIABLE _PYPROJECT_METADATA_ERROR
    OUTPUT_VARIABLE _PYPROJECT_METADATA_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if(_PYPROJECT_METADATA_RESULT EQUAL 0)
    install(
      DIRECTORY "${_PYPROJECT_METADATA_DIR}"
      DESTINATION "${PYTHON_SITELIB}"
    )
  else()
    message(
      WARNING
      "can't generate PEP 643 metadata: ${_PYPROJECT_METADATA_ERROR}"
    )
  endif()
endmacro()
