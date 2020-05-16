import unittest, strformat, httpclient, strutils, httpcore, json
import basolato/security
import ../../src/basolato/test
import allographer/query_builder
import ../migrations/migration20200331065251users

const HOST = "http://0.0.0.0:5000"

migration20200331065251users()

suite "form sign up":
  setup:
    var client = newHttpClient()

  test "fail":
    let data = {
      "csrf_token": newCsrfToken().getToken(),
      "name": "",
      "email": "user@invalid",
      "password": "foo",
      "password_confirm": "bar",
    }
    var response = client.formpost(&"{HOST}/users", data)
    check response.status == Http500
    echo response.body
    echo response.bodyStream
    check response.body.contains("password is not match")
