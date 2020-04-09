import unittest, strformat, httpclient, strutils

const HOST = "http://0.0.0.0:5000"

suite "form sign up":
  setup:
    var client = newHttpClient()

  test "a":
    var response = client.postContent(&"{HOST}/user")
    echo response
    check response == "test"