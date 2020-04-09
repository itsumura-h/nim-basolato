import unittest, strformat, httpclient, strutils, json
import basolato/security

const HOST = "http://0.0.0.0:5000"

proc toBody(body:openarray[tuple[key, value:string]]):string =
  result = ""
  for row in body:
    if result.len == 0:
      result.add(&"{row.key}={row.value}")
    else:
      result.add(&"&{row.key}={row.value}")

suite "form sign up":
  setup:
    var client = newHttpClient()

  test "a":
    # client.headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})
    # var data = %*{
    #   "csrf_token": newCsrfToken().getToken(),
    #   "name": "",
    #   "email": "user@invalid",
    #   "password": "foo",
    #   "password_confirm": "bar"
    # }
    # var response = client.post(&"{HOST}/users", body= $data)

    # var data = newMultipartData()
    # data["csrf_token"] = newCsrfToken().getToken()
    # data["name"] = ""
    # data["email"] = "user@invalid"
    # data["password"] = "foo"
    # data["password_confirm"] = "bar"
    let data = @[
      ("csrf_token", newCsrfToken().getToken()),
      ("name", ""),
      ("email", "user@invalid"),
      ("password", "foo"),
      ("password_confirm", "bar"),
    ]
    # var response = client.post(&"{HOST}/users", multipart=data)
    echo data.toBody()
    var response = client.post(&"{HOST}/users", body=data.toBody())

    echo response.status
    echo response.body
