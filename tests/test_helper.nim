import
  unittest,
  httpclient,
  strformat,
  strutils,
  cgi

const HOST = "http://0.0.0.0:5000"

block:
  let client = newHttpClient(maxRedirects=0)
  let response = client.get(&"{HOST}/dd")
  echo response.body
  check response.body.contains("""
  {
    "key1": "value1",
    "key2": 2
  }""".xmlEncode)
  check response.body.contains("abc")
