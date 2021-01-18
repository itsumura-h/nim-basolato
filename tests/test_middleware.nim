import unittest, httpclient, strformat, json, strutils, asyncdispatch
import ../src/basolato/middleware
include ../src/basolato/core/security

const HOST = "http://0.0.0.0:5000"

suite "middleware":
  setup:
    var client = newHttpClient(maxRedirects=0)

  test "checkCsrfToken":
    client.headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})
    let token = newCsrfToken().getToken()
    var params = &"csrf_token={token}"
    let response = client.post(&"{HOST}/csrf/test_routing", body = $params)
    check response.code == Http200

  test "checkCsrfToken invalid":
    client.headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})
    var params = &"csrf_token=invalid_token"
    let response = client.post(&"{HOST}/csrf/test_routing", body = $params)
    # echo response.body
    check response.code == Http403
    check response.body.contains("Invalid csrf token")

  test "checkSessionId":
    let auth_id = waitFor getToken(waitFor newSession())
    echo auth_id
    client.headers = newHttpHeaders({
      "Cookie": &"session_id={auth_id}",
      "Content-Type": "application/x-www-form-urlencoded"
    })
    let csrf_token = newCsrfToken().getToken()
    var params = &"csrf_token={csrf_token}"
    let response = client.post(&"{HOST}/session/test_routing", body = $params)
    # echo response.body
    check Http200 == response.code

  test "checkSessionId invalid":
    let auth_id = "invalid_auth_id".encryptCtr()
    echo auth_id
    client.headers = newHttpHeaders({
      "Cookie": &"session_id={auth_id}",
      "Content-Type": "application/x-www-form-urlencoded"
    })
    let csrf_token = newCsrfToken().getToken()
    var params = &"csrf_token={csrf_token}"
    let response = client.post(&"{HOST}/session/test_routing", body = $params)
    # echo response.body
    check response.code == Http403
