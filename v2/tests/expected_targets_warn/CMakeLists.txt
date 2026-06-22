add_cmake_test(
    NAME etw-project
    DEPENDS jrl-cmakemodules
    PASS_REGULAR_EXPRESSION
        "EXPECTED_TARGETS Dummy::A Dummy::B|EXPECTED_TARGETS Yummy::B Yummy::A"
)
