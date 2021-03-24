import
  unittest,
  httpclient,
  strformat,
  strutils

const HOST = "http://0.0.0.0:5000"

block:
  let client = newHttpClient(maxRedirects=0)
  let response = client.get(&"{HOST}/dd")
  check response.body.contains("""{"key1":"value1","key2":2}""")
  check response.body.contains("abc")
