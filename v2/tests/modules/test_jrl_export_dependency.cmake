# Set PROJECT_NAME as required by jrl_export_dependency
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
  NAME "EXPECTED_TARGETS are stored"
  CODE [[
    set_property(GLOBAL PROPERTY _jrl_${PROJECT_NAME}_package_dependencies "")

    jrl_export_dependency(
      PACKAGE_NAME Eigen3
      FIND_PACKAGE_ARGS "Eigen3;3.4;REQUIRED"
      PACKAGE_TARGETS "Eigen3::Eigen"
      EXPECTED_TARGETS "Eigen3::Eigen"
    )

    get_property(pd_json GLOBAL PROPERTY _jrl_${PROJECT_NAME}_package_dependencies)

    string(JSON exp_tgts GET "${pd_json}" "package_dependencies" 0 "expected_targets")
    _jrl_check(exp_tgts STREQUAL "Eigen3::Eigen")
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
