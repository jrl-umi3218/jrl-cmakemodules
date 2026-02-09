import test_project


def test_brackets():
    print("Running Nanobind bindings test...")
    ret = test_project.StringUtils().brackets("HelloWorld!")
    assert ret == "[HelloWorld!]"
