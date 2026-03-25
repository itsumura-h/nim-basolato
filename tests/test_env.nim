discard """
  cmd: "nim c -r $file"
"""

import std/unittest
import std/os
import ../src/basolato/core/env


suite("env helpers"):
  test("requireEnv reads a value"):
    putEnv("BASOLATO_TEST_REQUIRE_ENV", "value")
    check requireEnv("BASOLATO_TEST_REQUIRE_ENV") == "value"

  test("optionalEnv falls back to default"):
    if existsEnv("BASOLATO_TEST_OPTIONAL_ENV"):
      delEnv("BASOLATO_TEST_OPTIONAL_ENV")
    check optionalEnv("BASOLATO_TEST_OPTIONAL_ENV", "fallback") == "fallback"

  test("parseBoolEnv parses booleans"):
    check parseBoolEnv("true")
    check parseBoolEnv("false") == false
