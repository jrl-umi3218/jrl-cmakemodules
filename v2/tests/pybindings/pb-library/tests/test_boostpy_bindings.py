import pb_bp


def test_bp_brackets():
    print("Running Boost.Python bindings test...")
    ret = pb_bp.StringUtils().brackets("HelloWorld!")
    assert ret == "[HelloWorld!]"
