discard """
  cmd: "nim c $file"
  matrix: "--putenv:APP_ENV=test"
"""

import std/unittest
import ../sample/app

suite("test app"):
  test("test"):
    check app() == "test"
