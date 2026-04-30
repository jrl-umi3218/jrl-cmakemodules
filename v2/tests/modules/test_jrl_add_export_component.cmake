jrl_test_case(
  NAME "Add a single export component and verify global properties"
  CODE [[
    set(PROJECT_NAME my_project)

    jrl_add_export_component(NAME core TARGETS my_target)

    get_property(components GLOBAL PROPERTY _jrl_my_project_export_components)
    if(NOT "core" IN_LIST components)
      message(FATAL_ERROR "Component 'core' not found in export components: ${components}")
    endif()

    get_property(targets GLOBAL PROPERTY _jrl_my_project_core_targets)
    if(NOT "my_target" IN_LIST targets)
      message(FATAL_ERROR "Target 'my_target' not found in core targets: ${targets}")
    endif()
  ]]
)

jrl_test_case(
  NAME "Add two export components with different targets"
  CODE [[
    set(PROJECT_NAME my_project)

    jrl_add_export_component(NAME comp_a TARGETS lib_a)
    jrl_add_export_component(NAME comp_b TARGETS lib_b)

    get_property(components GLOBAL PROPERTY _jrl_my_project_export_components)
    if(NOT "comp_a" IN_LIST components)
      message(FATAL_ERROR "comp_a not found in: ${components}")
    endif()
    if(NOT "comp_b" IN_LIST components)
      message(FATAL_ERROR "comp_b not found in: ${components}")
    endif()

    get_property(targets_a GLOBAL PROPERTY _jrl_my_project_comp_a_targets)
    _jrl_check_strequal("${targets_a}" "lib_a")
    get_property(targets_b GLOBAL PROPERTY _jrl_my_project_comp_b_targets)
    _jrl_check_strequal("${targets_b}" "lib_b")
  ]]
)

jrl_test_case(
  NAME "Fatal error when adding duplicate component name"
  CODE [[
    set(PROJECT_NAME my_project)

    jrl_add_export_component(NAME core TARGETS my_target)
    jrl_add_export_component(NAME core TARGETS another_target)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error when target already belongs to another component"
  CODE [[
    set(PROJECT_NAME my_project)

    jrl_add_export_component(NAME comp_a TARGETS shared_target)
    jrl_add_export_component(NAME comp_b TARGETS shared_target)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error when TARGETS argument is missing"
  CODE [[
    set(PROJECT_NAME my_project)
    jrl_add_export_component(NAME core)
  ]]
  WILL_FAIL
)

jrl_test_case(
  NAME "Fatal error when NAME argument is missing"
  CODE [[
    set(PROJECT_NAME my_project)
    jrl_add_export_component(TARGETS my_target)
  ]]
  WILL_FAIL
)
