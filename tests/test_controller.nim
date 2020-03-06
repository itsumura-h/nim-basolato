import
  unittest, strformat, httpclient, strutils

const HOST = "http://0.0.0.0:5000"

suite "controller":
  setup:
    var client = newHttpClient()

  test "renderStr":
    var response = client.getContent(&"{HOST}/renderStr")
    echo response
    check response == "test"

  test "renderHtml":
    var response = client.getContent(&"{HOST}/renderHtml")
    echo response
    check response.strip == "<h1>test</h1>"

  test "renderTemplate":
    var response = client.getContent(&"{HOST}/renderTemplate")
    echo response
    check response.strip == "<h1>test template</h1>"

  test "renderJson":
    var response = client.getContent(&"{HOST}/renderJson")
    echo response
    check response == """{"key":"test"}"""

  test "status500":
    var response = client.get(&"{HOST}/status500")
    echo response.code()
    check response.code() == Http500

  test "status500json":
    var response = client.get(&"{HOST}/status500json")
    echo response.code()
    echo response.body()
    check response.code() == Http500
    check response.body() == """{"key":"test"}"""

  test "redirect":
    client = newHttpClient(maxRedirects=0)
    var response = client.get(&"{HOST}/redirect")
    echo response.code()
    echo response.headers
    check response.headers["location"] == "/new_url"
    check response.code() == Http303

  test "error redirect":
    client = newHttpClient(maxRedirects=0)
    var response = client.get(&"{HOST}/error_redirect")
    echo response.code()
    echo response.headers
    check response.headers["location"] == "/new_url"
    check response.code() == Http302
