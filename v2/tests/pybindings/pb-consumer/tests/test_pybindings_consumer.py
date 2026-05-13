import pb
import pb_bp


def test_nanobind_string_utils():
    utils = pb.StringUtils()
    assert utils.brackets("hello") == "[hello]"
    assert utils.reverse("abc") == "cba"


def test_boostpy_math():
    math = pb_bp.Math()
    assert math.add(2, 3) == 5
    assert math.multiply(3, 4) == 12


def test_boostpy_string_utils():
    utils = pb_bp.StringUtils()
    assert utils.brackets("hello") == "[hello]"
    assert utils.reverse("abc") == "cba"


if __name__ == "__main__":
    tests = [
        test_nanobind_string_utils,
        test_boostpy_math,
        test_boostpy_string_utils,
    ]
    failed = 0
    for test in tests:
        try:
            test()
            print(f"PASS: {test.__name__}")
        except AssertionError as e:
            print(f"FAIL: {test.__name__}: {e}")
            failed += 1
        except Exception as e:
            print(f"ERROR: {test.__name__}: {e}")
            failed += 1
    if failed:
        raise SystemExit(f"{failed} test(s) failed")
    print("All tests passed.")
