import
  unittest, strformat, httpclient

const HOST = "http://0.0.0.0:5000"

# =============================================================================

suite "response":
  setup:
    var client = newHttpClient()

  test "renderStr":
    var response = client.getContent(&"{HOST}/renderStr")
    echo response
    check response == "test"
