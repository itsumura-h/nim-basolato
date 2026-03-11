discard """
  cmd: "nim c -r $file"
"""

import std/unittest
include ../../src/basolato/core/security/random_string


suite("random string"):
  test("secureRandStr"):
    var str = secureRandStr(10)
    check str.len == 10

    str = secureRandStr(100)
    check str.len == 100

    str = secureRandStr(256)
    check str.len == 256

  test("secureRandStr odd size gives size-1 chars"):
    let str = secureRandStr(21)
    check str.len == 20

  test("secureCompare"):
    check secureCompare("", "") == true
    check secureCompare("a", "a") == true
    check secureCompare("abc", "abc") == true
    check secureCompare("", "a") == false
    check secureCompare("a", "") == false
    check secureCompare("a", "b") == false
    check secureCompare("ab", "ac") == false
    check secureCompare("ab", "abc") == false
    check secureCompare("abc", "ab") == false

  test("randStr"):
    var str = randStr(10)
    check str.len == 10

    str = randStr(100)
    check str.len == 100

    str = randStr(256)
    check str.len == 256
