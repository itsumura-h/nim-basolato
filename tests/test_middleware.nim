discard """
  cmd: "nim c -r $file"
"""

import unittest, httpclient, strformat, json, strutils, asyncdispatch, htmlparser, xmltree
import ../src/basolato/middleware
include ../src/basolato/core/security/session
include ../src/basolato/core/security/csrf_token

const HOST = "http://localhost:5000"

let client = newHttpClient(maxRedirects=0)

proc loadCsrfToken():string =
  # create session
  let response = client.get(&"{HOST}/csrf/test_routing")
  check response.code == Http200
  let html = response.body().parseHtml()
  var s = newSeq[XmlNode]()
  html.findAll("input", s)
  return s[0].attr("value")

block:
  let session = waitFor genNewSession()
  let authId = waitFor session.db.getToken()
  client.headers = newHttpHeaders({
    "Cookie": &"session_id={authId}",
    "Content-Type": "application/x-www-form-urlencoded",
  })
  let csrfToken = loadCsrfToken()
  let params = &"csrf_token={csrfToken}"
  let response = client.post(&"{HOST}/csrf/test_routing", body = params)
  check response.code == Http200

block:
  client.headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})
  var params = &"csrf_token=invalid_token"
  let response = client.post(&"{HOST}/csrf/test_routing", body = params)
  check response.code == Http403
  check response.body.contains("Invalid csrf token")

block:
  let session = waitFor genNewSession()
  let authId = waitFor session.db.getToken()
  client.headers = newHttpHeaders({
    "Cookie": &"session_id={authId}",
    "Content-Type": "application/x-www-form-urlencoded"
  })
  let token = loadCsrfToken()
  var params = &"csrf_token={token}"
  let response = client.post(&"{HOST}/session/test_routing", body = params)
  check Http200 == response.code

block:
  let authId = "invalid_auth_id"
  client.headers = newHttpHeaders({
    "Cookie": &"session_id={authId}",
    "Content-Type": "application/x-www-form-urlencoded"
  })
  # let csrf_token = CsrfToken.new().getToken().getToken()
  let token = loadCsrfToken()
  var params = &"csrf_token={token}"
  let response = client.post(&"{HOST}/session/test_routing", body = params)
  check response.code == Http403
