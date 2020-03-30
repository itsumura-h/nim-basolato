import unittest, strformat, strutils, httpclient, htmlparser, xmltree

const HOST = "http://0.0.0.0:5000"

suite "users controller":
  setup:
    var client = newHttpClient()

  test "should get create":
    var response = client.get(&"{HOST}/users/create")
    echo response.code()
    check response.code() == Http200
