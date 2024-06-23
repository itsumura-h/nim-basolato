discard """
  cmd: "nim c -r $file"
"""

import std/unittest
import std/times
import std/asyncdispatch
include ../../src/basolato/core/security/random_string


suite("random string"):
  test("secureRandStr"):
    var str = secureRandStr(10)
    check str.len == 10

    str = secureRandStr(100)
    check str.len == 100

    str = secureRandStr(256)
    check str.len == 256

  test("randStr"):
    var str = randStr(10)
    check str.len == 10

    str = randStr(100)
    check str.len == 100

    str = randStr(256)
    check str.len == 256
