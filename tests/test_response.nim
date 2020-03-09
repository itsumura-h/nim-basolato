import unittest, strformat, httpclient

const HOST = "http://0.0.0.0:5000"

suite "response":
  setup:
    var client = newHttpClient(maxRedirects=0)

  test "setHeader":
    let response = client.get(&"{HOST}/set-header")
    echo response.headers
    check response.headers["key1"] == HttpHeaderValues(@["value1"])
    check response.headers["key2"] == HttpHeaderValues(@["value1, value2"])
