import unittest, httpclient, strformat, json, strutils
import ../src/basolato/middleware
import ../src/basolato/security

const HOST = "http://0.0.0.0:5000"

suite "middleware":
  setup:
    var client = newHttpClient(maxRedirects=0)

  test "catch":
    let check = Check(status:true)
    try:
      check.catch(Error500, "message1")
    except:
      check getCurrentException() is Error500
      check getCurrentExceptionMsg() == "message1"

    try:
      check.catch(Error403, "message2")
    except:
      check getCurrentException() is Error403
      check getCurrentExceptionMsg() == "message2"

  test "checkCsrfToken":
    client.headers = newHttpHeaders({ "Content-Type": "application/x-www-form-urlencoded"})
    let token = newCsrfToken("").getToken()
    echo token
    var params = &"csrf_token={token}"
    let response = client.post(&"{HOST}/test_routing", body = $params)
    check response.code == Http200

  test "checkCsrfToken invalid":
    client.headers = newHttpHeaders({ "Content-Type": "application/x-www-form-urlencoded"})
    let token = newCsrfToken("").getToken()
    echo token
    var params = &"csrf_token=invalid_token"
    let response = client.post(&"{HOST}/test_routing", body = $params)
    check response.code == Http403
    check response.body.contains("Invalid csrf token")
