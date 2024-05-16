discard """
  cmd: "nim c -r $file"
"""

import std/httpclient
import std/strformat
import std/unittest
import ../src/basolato/core/security/csrf_token

const HOST = "http://0.0.0.0:8000"
let client = newHttpClient()

suite("test routing"):
  test("get"):
    let response = client.get(&"{HOST}/test_routing")
    echo response.body
    check response.body == "get"

  test("post"):
    client.headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})
    var response = client.post(&"{HOST}/test_routing")
    echo response.body
    check response.body == "post"

  test("patch"):
    let response = client.patch(&"{HOST}/test_routing")
    echo response.body
    check response.body == "patch"

  test("put"):
    let response = client.put(&"{HOST}/test_routing")
    echo response.body
    check response.body == "put"

  test("delete"):
    let response = client.delete(&"{HOST}/test_routing")
    echo response.body
    check response.body == "delete"

  test("favicon"):
    let response = client.get(&"{HOST}/favicon.ico")
    check response.contentType == "image/x-icon"
    check response.code == Http200

  test("404"):
    let response = client.get(&"{HOST}/404")
    check response.code == Http404
