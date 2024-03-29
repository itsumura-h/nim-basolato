discard """
  cmd: "nim c -r $file"
  matrix: "; -d:httpbeast"
"""

import std/unittest
import std/tables
import std/httpcore
import std/strformat
from strutils import join, contains
import ../src/basolato/core/base
import ../src/basolato/core/security/cookie
import ../src/basolato/core/header


suite("test header"):
  test("header table"):
    let header = [
      ("a", @["a", "b"])
    ].newHttpHeaders()
    check header.table["a"][0] == "a"
    check header.table["a"][1] == "b"

  test("setDefaultHeaders"):
    let header = newHttpHeaders()
    header.setDefaultHeaders()
    check header["server"] == fmt"Basolato/Nim"

  test("header add"):
    let header = newHttpHeaders()
    header.add("a", "a")
    check header["a"] == "a"
    header.add("a", "b")
    check header.table["a"][1] == "b"

  test("header &"):
    let header1 = newHttpHeaders()
    header1.add("a", "a")
    let header2 = newHttpHeaders()
    header2.add("b", "b")
    let header = header1 & header2
    check header["a"] == "a"
    check header["b"] == "b"

  test("header [key]"):
    let header1 = newHttpHeaders()
    header1.add("a", "a")
    let header2 = newHttpHeaders()
    header2.add("b", "b")
    header1 &= header2
    check header1["a"] == "a"
    check header1["b"] == "b"

  test("header [key, index]"):
    var headers = newHttpHeaders()
    headers.add("key", "val1")
    headers.add("key", "val2")
    headers.add("set-cookie", Cookie.new("key1", "val1").toCookieStr())
    headers.add("set-cookie", Cookie.new("key2", "val2").toCookieStr())
    headers.setDefaultHeaders()
    check headers["Key", 0] == "val1"
    check headers["Key", 1] == "val2"
    check headers["Set-Cookie", 0].contains("key1=val1")
    check headers["Set-Cookie", 1].contains("key2=val2")
    echo headers.format()
    echo headers.format().toString()

  test("header format"):
    var headers = newHttpHeaders()
    headers.add("date", "date1")
    headers.add("date", "date2")
    headers = headers.format()
    check headers.table == {"Date": @["date1"]}.newTable

  test("header &="):
    var header1 = {
      "Cache-Control": @["no-cache"],
      "Access-Control-Allow-Origin": @["http://localhost:3000", "http://localhost:3001"],
    }.newHttpHeaders()

    var header2 = {
      "Access-Control-Allow-Credentials": @["true"],
      "Access-Control-Allow-Origin": @["http://localhost:3001", "http://localhost:3002"],
    }.newHttpHeaders()

    var expected = {
      "Cache-Control": @["no-cache"],
      "Access-Control-Allow-Credentials": @["true"],
      "Access-Control-Allow-Origin": @["http://localhost:3000", "http://localhost:3001", "http://localhost:3002"],
    }.newHttpHeaders()

    header1 &= header2

    check header1 == expected
