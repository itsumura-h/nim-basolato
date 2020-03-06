import unittest, strformat, httpclient

const HOST = "http://0.0.0.0:5000"

suite "routing":
  setup:
    var client = newHttpClient()

  test "get":
    var response = client.get(&"{HOST}/test_routing")
    echo response.body
    check response.body == "get"

  test "post":
    var response = client.post(&"{HOST}/test_routing")
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
