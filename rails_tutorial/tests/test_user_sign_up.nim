import unittest, strformat, httpclient, strutils
import basolato/security
import basolato/test/helper

const HOST = "http://0.0.0.0:5000"

suite "form sign up":
  setup:
    var client = newHttpClient()

  test "success":
    let data = @[
      ("csrf_token", newCsrfToken().getToken()),
      ("name", ""),
      ("email", "user@invalid"),
      ("password", "foo"),
      ("password_confirm", "bar"),
    ]
    var response = client.formpost(&"{HOST}/users", data)
    echo response.status
    echo response.body
    check response.status == Http500
    check response.body.contains("password is not match")
