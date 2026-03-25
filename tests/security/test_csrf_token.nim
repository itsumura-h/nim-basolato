discard """
  cmd: "nim c -d:test $file"
"""

# nim c -r -d:test --putenv:SESSION_TYPE=file --putenv:SESSION_PATH=./session.db ./security/test_csrf_token.nim

import std/unittest
import std/strutils
import ../../src/basolato/core/security/csrf_token

suite("csrf_token"):
  test("toString escapes HTML in value"):
    let t = CsrfToken.new("plain")
    check t.toString().contains("value=\"plain\"")

  test("toString escapes double quote"):
    let t = CsrfToken.new("a\"b")
    let s = t.toString()
    check "&quot;" in s
    check "a&quot;b" in s or s.contains("value=\"a&quot;b\"")

  test("toString escapes less than and greater than"):
    let t = CsrfToken.new("<script>")
    let s = t.toString()
    check "&lt;" in s
    check "&gt;" in s
    check "&lt;script&gt;" in s or s.contains("script")

  test("toString escapes ampersand"):
    let t = CsrfToken.new("a&b")
    let s = t.toString()
    check "&amp;" in s
    check "a&amp;b" in s or s.contains("value=")

  test("getToken returns stored token"):
    let t = CsrfToken.new("my-token-123")
    check t.getToken() == "my-token-123"
