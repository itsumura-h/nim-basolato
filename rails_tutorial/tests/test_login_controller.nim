import unittest, httpclient, strformat

const HOST = "http://0.0.0.0:5000"

suite "LoginController":
  setup:
    var client = newHttpClient()

  test "should get create":
    var response = client.get(&"{HOST}/login")
    echo response.code()
    check response.code() == Http200
