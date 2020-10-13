import unittest, strformat, httpclient, strutils
import ../src/basolato/core/security

const HOST = "http://0.0.0.0:5000"

suite "response":
  setup:
    var client = newHttpClient(maxRedirects=0)

  test "setHeader":
    let response = client.get(&"{HOST}/set-header")
    echo response.headers
    check response.headers["key1"] == HttpHeaderValues(@["value1"])
    check response.headers["key2"] == HttpHeaderValues(@["value1, value2"])

  test "setCookie":
    let response = client.get(&"{HOST}/set-cookie")
    echo response.headers["set-cookie", 0]
    echo response.headers["set-cookie", 1]
    check response.headers["set-cookie", 0]
            .contains("key1=value1; Path=/;")
    check response.headers["set-cookie", 1]
            .contains("key2=value2; Path=/;")

  test "setAuth":
    let response = client.get(&"{HOST}/set-auth")
    let auth_id = response.headers["set-cookie", 0].split("; ")[0].split("=")[1]
    let sessionDb = newSessionDb(auth_id)
    check sessionDb.get("key1") == "value1"
    check sessionDb.get("key2") == "value2"

  test "destroyAuth":
    let response = client.get(&"{HOST}/destroy-auth")
    check response.headers.hasKey("set-cookie")
