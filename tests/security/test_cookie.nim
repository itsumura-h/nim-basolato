discard """
  cmd: "nim c -d:test $file"
"""

# nim c -r -d:test ./security/test_cookie.nim

import std/unittest
import std/httpcore
import std/tables
import ../../src/basolato/core/security/cookie
import ../../src/basolato/core/libservers/std/request

suite("cookie"):
  test("get parses value with equals using first equals only"):
    var r: Request
    r.headers = newHttpHeaders()
    r.headers["Cookie"] = "name=value=with=equals"
    let cookies = Cookies.new(r)
    check cookies.get("name") == "value=with=equals"

  test("getAll parses value with equals using first equals only"):
    var r: Request
    r.headers = newHttpHeaders()
    r.headers["Cookie"] = "sess=abc=def; foo=bar"
    let cookies = Cookies.new(r)
    let all = cookies.getAll()
    check tables.`[]`(all, "sess") == "abc=def"
    check tables.`[]`(all, "foo") == "bar"

  test("get returns empty when no Cookie header"):
    var r: Request
    r.headers = newHttpHeaders()
    let cookies = Cookies.new(r)
    check cookies.get("any") == ""

  test("get single cookie"):
    var r: Request
    r.headers = newHttpHeaders()
    r.headers["Cookie"] = "single=one"
    let cookies = Cookies.new(r)
    check cookies.get("single") == "one"
