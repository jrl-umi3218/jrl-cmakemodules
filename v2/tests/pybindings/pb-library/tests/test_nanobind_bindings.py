import pb


def test_brackets():
    print("Running Nanobind bindings test...")
    ret = pb.StringUtils().brackets("HelloWorld!")
    assert ret == "[HelloWorld!]"
