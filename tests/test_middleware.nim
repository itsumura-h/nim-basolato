discard """
  cmd: "nim c -r --putenv:SESSION_TYPE=file --putenv:SESSION_DB_PATH=./tests/server/session.db $file"
"""

# nim c -r --putenv:SESSION_TYPE=file --putenv:SESSION_DB_PATH=./tests/server/session.db tests/test_middleware.nim

import std/unittest
import std/asyncdispatch
import std/htmlparser
import std/httpclient
import std/json
import std/strformat
import std/strutils
import std/xmltree
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

suite("test middleware"):
  test("csrf token valid"):
    let session = Session.new().waitFor().get()
    let sessionId = session.db.getToken().waitFor()
    client.headers = newHttpHeaders({
      "Cookie": &"session_id={sessionId}",
      "Content-Type": "application/x-www-form-urlencoded",
    })
    let csrfToken = loadCsrfToken()
    let params = &"csrf_token={csrfToken}"
    let response = client.post(&"{HOST}/csrf/test_routing", body = params)
    check response.code == Http200

  test("csrf token invalid"):
    client.headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})
    var params = &"csrf_token=invalid_token"
    let response = client.post(&"{HOST}/csrf/test_routing", body = params)
    check response.code == Http403

  test("cookie valid"):
    let session = Session.new().waitFor().get()
    let authId = session.db.getToken().waitFor()
    client.headers = newHttpHeaders({
      "Cookie": &"session_id={authId}",
      "Content-Type": "application/x-www-form-urlencoded"
    })
    let token = loadCsrfToken()
    var params = &"csrf_token={token}"
    let response = client.post(&"{HOST}/session/test_routing", body = params)
    check Http200 == response.code

  test("cookie invalid"):
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
