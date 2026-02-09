import test_project_bp


def test_bp_brackets():
    print("Running Boost.Python bindings test...")
    ret = test_project_bp.StringUtils().brackets("HelloWorld!")
    assert ret == "[HelloWorld!]"
