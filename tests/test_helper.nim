discard """
  cmd: "nim c -r $file"
"""

# nim c -r tests/test_helper.nim

import std/unittest
import std/httpclient
import std/strformat
import std/strutils
import std/cgi

const HOST = "http://0.0.0.0:8000"

suite("test helper"):
  test("dd"):
    let client = newHttpClient(maxRedirects=0)
    let response = client.get(&"{HOST}/dd")
    check response.body.contains("""
{
  "key1": "value1",
  "key2": 2
}""".xmlEncode
    )
    check response.body.contains("abc")
