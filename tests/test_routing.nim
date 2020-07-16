import unittest, strformat, httpclient
import ../src/basolato/security

const HOST = "http://0.0.0.0:5000"

suite "routing":
  setup:
    var client = newHttpClient()

  test "get":
    var response = client.get(&"{HOST}/test_routing")
    echo response.body
    check response.body == "get"

  test "post":
    client.headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})
    let csrfToken = newCsrfToken().getToken()
    var params = &"csrf_token={csrf_token}"
    var response = client.post(&"{HOST}/test_routing", body = $params)
    echo response.body
    check response.body == "post"

  test "patch":
    var response = client.patch(&"{HOST}/test_routing")
    echo response.body
    check response.body == "patch"

  test "put":
    var response = client.put(&"{HOST}/test_routing")
    echo response.body
    check response.body == "put"

  test "delete":
    var response = client.delete(&"{HOST}/test_routing")
    echo response.body
    check response.body == "delete"

  test "favicon":
    var response = client.get(&"{HOST}/favicon.ico")
    check response.contentType == "image/x-icon"
    check response.code == Http200
