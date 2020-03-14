import unittest, httpclient, strformat, strutils

const HOST = "http://0.0.0.0:5000"

suite "helper":
  setup:
    var client = newHttpClient(maxRedirects=0)

  test "dd":
    var response = client.get(&"{HOST}/dd")
    echo response.body
    check response.body.contains("""{"key1":"value1","key2":2}""")
    check response.body.contains("abc")
