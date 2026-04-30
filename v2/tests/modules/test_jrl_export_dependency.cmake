# Set PROJECT_NAME as required by both jrl_export_dependency and jrl_add_export_component
set(PROJECT_NAME test_project)

jrl_test_case(
  NAME "Single dependency is stored in JSON"
  CODE [[
    set_property(GLOBAL PROPERTY _jrl_${PROJECT_NAME}_package_dependencies "")

    jrl_export_dependency(
      PACKAGE_NAME Eigen3
      FIND_PACKAGE_ARGS "Eigen3;3.4;REQUIRED"
      PACKAGE_TARGETS "Eigen3::Eigen"
    )

    get_property(pd_json GLOBAL PROPERTY _jrl_${PROJECT_NAME}_package_dependencies)
    if(NOT pd_json)
      message(FATAL_ERROR "FAIL: package_dependencies property is empty")
    endif()

    string(JSON num_deps LENGTH "${pd_json}" "package_dependencies")
    _jrl_check("${num_deps}" STREQUAL "1")

    string(JSON pkg_name GET "${pd_json}" "package_dependencies" 0 "package_name")
    _jrl_check("${pkg_name}" STREQUAL "Eigen3")

    string(JSON pkg_targets GET "${pd_json}" "package_dependencies" 0 "package_targets")
    _jrl_check("${pkg_targets}" STREQUAL "Eigen3::Eigen")
  ]]
)

jrl_test_case(
  NAME "Multiple dependencies accumulate"
  CODE [[
    set_property(GLOBAL PROPERTY _jrl_${PROJECT_NAME}_package_dependencies "")

    jrl_export_dependency(
      PACKAGE_NAME Eigen3
      FIND_PACKAGE_ARGS "Eigen3;3.4;REQUIRED"
      PACKAGE_TARGETS "Eigen3::Eigen"
    )
    jrl_export_dependency(
      PACKAGE_NAME Boost
      FIND_PACKAGE_ARGS "Boost;1.70;REQUIRED"
      PACKAGE_TARGETS "Boost::filesystem;Boost::system"
    )

    get_property(pd_json GLOBAL PROPERTY _jrl_${PROJECT_NAME}_package_dependencies)

    string(JSON num_deps LENGTH "${pd_json}" "package_dependencies")
    _jrl_check("${num_deps}" STREQUAL "2")

    string(JSON pkg2_name GET "${pd_json}" "package_dependencies" 1 "package_name")
    _jrl_check("${pkg2_name}" STREQUAL "Boost")
  ]]
)

jrl_test_case(
  NAME "FIND_PACKAGE_ARGS are stored"
  CODE [[
    set_property(GLOBAL PROPERTY _jrl_${PROJECT_NAME}_package_dependencies "")

    jrl_export_dependency(
      PACKAGE_NAME Eigen3
      FIND_PACKAGE_ARGS "Eigen3;3.4;REQUIRED"
      PACKAGE_TARGETS "Eigen3::Eigen"
    )

    get_property(pd_json GLOBAL PROPERTY _jrl_${PROJECT_NAME}_package_dependencies)

    string(JSON fp_args GET "${pd_json}" "package_dependencies" 0 "find_package_args")
    set(_expected_fp_args "Eigen3;3.4;REQUIRED")
    _jrl_check(fp_args STREQUAL _expected_fp_args)
  ]]
)

jrl_test_case(
  NAME "Minimal call with only PACKAGE_NAME"
  CODE [[
    set_property(GLOBAL PROPERTY _jrl_${PROJECT_NAME}_package_dependencies "")

    jrl_export_dependency(PACKAGE_NAME MinimalPkg)

    get_property(pd_json GLOBAL PROPERTY _jrl_${PROJECT_NAME}_package_dependencies)

    string(JSON num_deps LENGTH "${pd_json}" "package_dependencies")
    _jrl_check("${num_deps}" STREQUAL "1")

    string(JSON pkg_name GET "${pd_json}" "package_dependencies" 0 "package_name")
    _jrl_check("${pkg_name}" STREQUAL "MinimalPkg")
  ]]
)

jrl_test_case(
  NAME "Fatal error when PACKAGE_NAME is missing"
  CODE [[
    set(PROJECT_NAME test_project)
    jrl_export_dependency(PACKAGE_TARGETS SomeLib::SomeLib)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Component is registered in global property"
  CODE [[
    set(PROJECT_NAME test_export_project)
    set_property(GLOBAL PROPERTY _jrl_${PROJECT_NAME}_export_components "")

    jrl_add_export_component(NAME mylib TARGETS mylib_target)

    get_property(components GLOBAL PROPERTY _jrl_${PROJECT_NAME}_export_components)
    if(NOT "mylib" IN_LIST components)
      message(FATAL_ERROR "FAIL: 'mylib' not found in export components: ${components}")
    endif()

    get_property(targets GLOBAL PROPERTY _jrl_${PROJECT_NAME}_mylib_targets)
    if(NOT "mylib_target" IN_LIST targets)
      message(FATAL_ERROR "FAIL: 'mylib_target' not found in component targets: ${targets}")
    endif()
  ]]
)

jrl_test_case(
  NAME "Multiple components can be added"
  CODE [[
    set(PROJECT_NAME test_export_project)
    set_property(GLOBAL PROPERTY _jrl_${PROJECT_NAME}_export_components "")

    jrl_add_export_component(NAME mylib TARGETS mylib_target)
    jrl_add_export_component(NAME mylib_python TARGETS mylib_python_target)

    get_property(components GLOBAL PROPERTY _jrl_${PROJECT_NAME}_export_components)
    list(LENGTH components num_components)
    _jrl_check("${num_components}" STREQUAL "2")
  ]]
)

jrl_test_case(
  NAME "Fatal error for duplicate component name"
  CODE [[
    set(PROJECT_NAME dup_project)
    jrl_add_export_component(NAME comp_a TARGETS target_a)
    jrl_add_export_component(NAME comp_a TARGETS target_b)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error when same target added to two components"
  CODE [[
    set(PROJECT_NAME conflict_project)
    jrl_add_export_component(NAME comp_x TARGETS shared_target)
    jrl_add_export_component(NAME comp_y TARGETS shared_target)
  ]]
  WILL_FAIL
)
