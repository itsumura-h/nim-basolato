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
    client.headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})
    let token = newCsrfToken("").getToken()
    var params = &"csrf_token={token}"
    let response = client.post(&"{HOST}/with_middleware/test_routing", body = $params)
    check response.code == Http200

  test "checkCsrfToken invalid":
    client.headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})
    var params = &"csrf_token=invalid_token"
    let response = client.post(&"{HOST}/with_middleware/test_routing", body = $params)
    # echo response.body
    check response.code == Http403
    check response.body.contains("Invalid csrf token")

  test "checkAuthToken":
    let auth_id = newAuth().getToken()
    echo auth_id
    client.headers = newHttpHeaders({
      "Cookie": &"session_id={auth_id}",
      "Content-Type": "application/x-www-form-urlencoded"
    })
    let csrf_token = newCsrfToken("").getToken()
    var params = &"csrf_token={csrf_token}"
    let response = client.post(&"{HOST}/with_middleware/test_routing", body = $params)
    # echo response.body
    check response.code == Http200

  test "checkAuthToken invalid":
    let auth_id = "invalid_auth_id".encryptCtr()
    echo auth_id
    client.headers = newHttpHeaders({
      "Cookie": &"session_id={auth_id}",
      "Content-Type": "application/x-www-form-urlencoded"
    })
    let csrf_token = newCsrfToken("").getToken()
    var params = &"csrf_token={csrf_token}"
    let response = client.post(&"{HOST}/with_middleware/test_routing", body = $params)
    # echo response.body
    check response.code == Http403
