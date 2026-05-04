jrl_test_case(
  NAME "Log buffer starts empty after clear"
  CODE [[
    _jrl_log_clear()

    _jrl_log_get(result)

    _jrl_check(NOT result)
  ]]
)

jrl_test_case(
  NAME "Single message is stored"
  CODE [[
    _jrl_log_clear()

    _jrl_log("hello world")
    _jrl_log_get(result)

    _jrl_check("${result}" STREQUAL "hello world\n")
  ]]
)

jrl_test_case(
  NAME "Multiple messages accumulate in order"
  CODE [[
    _jrl_log_clear()

    _jrl_log("first")
    _jrl_log("second")
    _jrl_log("third")
    _jrl_log_get(result)

    _jrl_check("${result}" STREQUAL "first\nsecond\nthird\n")
  ]]
)

jrl_test_case(
  NAME "_jrl_log_clear resets accumulated messages"
  CODE [[
    _jrl_log_clear()
    _jrl_log("before clear")
    _jrl_log("also before clear")

    _jrl_log_clear()
    _jrl_log_get(result)

    _jrl_check(NOT result)
  ]]
)

jrl_test_case(
  NAME "Log after clear only contains new messages"
  CODE [[
    _jrl_log_clear()
    _jrl_log("old message")
    _jrl_log_clear()

    _jrl_log("new message")
    _jrl_log_get(result)

    _jrl_check("${result}" STREQUAL "new message\n")
  ]]
)

jrl_test_case(
  NAME "Log with empty string message"
  CODE [[
    _jrl_log_clear()

    _jrl_log("")
    _jrl_log_get(result)

    _jrl_check("${result}" STREQUAL "\n")
  ]]
)

jrl_test_case(
  NAME "_jrl_log_get does not clear the buffer"
  CODE [[
    _jrl_log_clear()

    _jrl_log("persistent")
    _jrl_log_get(first_read)
    _jrl_log_get(second_read)

    _jrl_check("${first_read}" STREQUAL "persistent\n")
    _jrl_check("${second_read}" STREQUAL "persistent\n")
  ]]
)
