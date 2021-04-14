import unittest, strformat, httpclient
import ../src/basolato/core/security/csrf_token

const HOST = "http://0.0.0.0:5000"
let client = newHttpClient()

block:
  let response = client.get(&"{HOST}/test_routing")
  echo response.body
  check response.body == "get"

block:
  client.headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})
  let csrfToken = newCsrfToken().getToken()
  var params = &"csrf_token={csrf_token}"
  var response = client.post(&"{HOST}/test_routing", body = $params)
  echo response.body
  check response.body == "post"

block:
  let response = client.patch(&"{HOST}/test_routing")
  echo response.body
  check response.body == "patch"

block:
  let response = client.put(&"{HOST}/test_routing")
  echo response.body
  check response.body == "put"

block:
  let response = client.delete(&"{HOST}/test_routing")
  echo response.body
  check response.body == "delete"

block:
  let response = client.get(&"{HOST}/favicon.ico")
  check response.contentType == "image/x-icon"
  check response.code == Http200

block:
  let response = client.get(&"{HOST}/404")
  check response.code == Http404
